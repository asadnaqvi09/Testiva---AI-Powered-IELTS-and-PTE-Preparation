import { syncQueue } from "./sync.queue.js";
import * as Progress from "../M4_Progress/models/progress.model.js";
import pool from "../../config/db.js";
import { cacheDelByPrefix } from "../../utils/redisCache.js";
import { computeAttemptBandScores } from "../../utils/bandScore.js";
import * as writingEvaluation from "../M6_AI/evaluators/writing.evaluator.js";
import * as speakingEvaluation from "../M6_AI/evaluators/speaking.evaluator.js";
import { getSocketServer } from "../../config/socket.js";
import { handleTestResultSyncedNotification } from "../M9_Notification/engine/notification.engine.js";

syncQueue.process(async (job) => {
  const userId = job.data.userId || job.data.userID;
  const testData = job.data.testData;
  const isOnlineAsyncHook = job.data.isOnlineAsyncHook || false;
  let attemptId = job.data.attemptId || null;
  const client = await pool.connect();
  try {
    const checkQuery = `
      SELECT id, status, sync_status 
      FROM test_attempts 
      WHERE user_id = $1::uuid 
        AND test_id = $2::uuid 
        AND client_started_at = $3::timestamp
      LIMIT 1
    `;
    const existingAttemptCheck = await client.query(checkQuery, [
      userId, 
      testData.test_id, 
      testData.client_started_at
    ]);
    let attemptRecord = existingAttemptCheck.rows[0];
    if (attemptRecord && attemptRecord.sync_status === 'synced') {
      console.log(`[IDEMPOTENCY ALERT]: Attempt ${attemptRecord.id} already processed and synced. Skipping duplicate worker processing.`);
      client.release();
      return { success: true, attemptId: attemptRecord.id, status: "already_synced" };
    }
    if (!attemptRecord && !isOnlineAsyncHook) {
      await client.query("BEGIN");
      const attempt = await Progress.startNewAttempt(
        {
          user_id: userId,
          test_id: testData.test_id,
          client_started_at: testData.client_started_at,
          is_offline: true,
        },
        client,
      );
      attemptId = attempt.id;
      for (const resp of testData.responses) {
        await Progress.saveUserResponse(
          {
            attempt_id: attemptId,
            question_id: resp.question_id,
            user_answer: resp.user_answer,
            audio_response_url: resp.audio_response_url ?? resp.audio_url ?? null,
            time_spent_seconds: resp.time_spent_seconds ?? resp.time_taken_seconds ?? 0,
            word_count: resp.word_count ?? 0,
            client_created_at: resp.client_created_at || new Date(),
          },
          client,
        );
      }
      const scoreMeta = await Progress.getAttemptScoreMeta(attemptId, client);
      const gradedResponses = await Progress.getAttemptResponses(attemptId, client);
      const computed = computeAttemptBandScores(gradedResponses, {
        examType: scoreMeta.exam_type,
        testCategory: scoreMeta.test_category,
      });
      await Progress.finalizeAttempt(
        attemptId,
        {
          overall_band_score: testData.overall_band_score ?? computed.overall_band_score,
          reading_score: testData.reading_score ?? computed.reading_score,
          listening_score: testData.listening_score ?? computed.listening_score,
          writing_score: testData.writing_score ?? computed.writing_score,
          speaking_score: testData.speaking_score ?? computed.speaking_score,
          feedback: "Offline data synchronized. Running AI Evaluators...",
          client_completed_at: testData.client_completed_at,
          status: "pending",
          sync_status: "pending",
        },
        client,
      );
      await client.query("COMMIT");
    } else {
      attemptId = attemptRecord ? attemptRecord.id : attemptId;
      console.log(`[RESUMING WORKER]: Processing AI pipelines for attempt scope id: ${attemptId}`);
    }
    client.release();
    const responses = await Progress.getAttemptResponses(attemptId);
    const testMeta = await Progress.getAttemptById(attemptId);
    const isPte = (testMeta?.test_type || "").toUpperCase() === "PTE";
    let calculatedWritingScore = Number(testData.writing_score) || 0;
    let calculatedSpeakingScore = Number(testData.speaking_score) || 0;
    let cumulativeFeedback = [];
    for (const resp of responses) {
      const qType = (resp.question_type || "").toLowerCase();
      if (qType === "writing") {
        try {
          const essayText = resp.user_answer?.text_essay || (typeof resp.user_answer === "string" ? resp.user_answer : "");
          const fb = await writingEvaluation.evaluateWriting(userId, attemptId, testMeta?.test_type, resp.question_text, essayText, { skipScoreUpdate: true });
          calculatedWritingScore = fb.overall_band_score;
          cumulativeFeedback.push(`[Writing Feedback]: ${fb.general_critique || fb.improvement_suggestions}`);
        } catch (err) {
          console.error(`[AI RECOVERY ERROR]: Attempt ID ${attemptId} Writing Evaluation failure: `, err);
        }
      } else if (qType === "speaking") {
        try {
          const transcript = resp.user_answer?.transcribed_text || (typeof resp.user_answer === "string" ? resp.user_answer : "");
          const sData = { transcribedText: transcript, durationSeconds: resp.time_spent_seconds || 0 };
          const fb = await speakingEvaluation.evaluateSpeakingTask(userId, attemptId, sData, { skipScoreUpdate: true });
          calculatedSpeakingScore = fb.overall_band_score;
          cumulativeFeedback.push(`[Speaking Feedback]: ${fb.general_critique || fb.improvement_suggestions}`);
        } catch (err) {
          console.error(`[AI RECOVERY ERROR]: Attempt ID ${attemptId} Speaking Evaluation failure: `, err);
        }
      }
    }
    const rScore = Number(testMeta?.reading_score) || Number(testData.reading_score) || 0;
    const lScore = Number(testMeta?.listening_score) || Number(testData.listening_score) || 0;
    const wScore = calculatedWritingScore || Number(testData.writing_score) || 0;
    const sScore = calculatedSpeakingScore || Number(testData.speaking_score) || 0;
    let computedBand = (rScore + lScore + wScore + sScore) / 4;
    if (!isPte) {
      computedBand = Math.round(computedBand * 2) / 2;
    } else {
      computedBand = Math.round(computedBand);
    }
    await Progress.updateAttemptScores(attemptId, {
      overall_band_score: computedBand,
      reading_score: rScore,
      listening_score: lScore,
      writing_score: wScore,
      speaking_score: sScore,
      feedback: cumulativeFeedback.join("\n\n") || "Test data compiled and synchronized successfully by Testiva AI.",
      status: "completed",
    });
    const finalClient = await pool.connect();
    await finalClient.query(
      "UPDATE test_attempts SET sync_status = 'synced', status = 'completed', updated_at = NOW() WHERE id = $1::uuid", 
      [attemptId]
    );
    finalClient.release();
    await Progress.updateUserStats(userId);
    await cacheDelByPrefix(`test:mobile:${userId}:`);

    const titleRow = await pool.query(
      `SELECT t.title FROM test_attempts ta JOIN tests t ON ta.test_id = t.id WHERE ta.id = $1::uuid`,
      [attemptId],
    );
    const testTitle = titleRow.rows[0]?.title || "Mock Test";
    try {
      await handleTestResultSyncedNotification(getSocketServer(), {
        userId,
        attemptId,
        testTitle,
      });
    } catch (notifyErr) {
      console.error("[SYNC NOTIFY ERROR]:", notifyErr.message);
    }

    return { success: true, attemptId };

  } catch (error) {
    try {
      if (client && client.processID) {
        await client.query("ROLLBACK");
      }
    } catch (e) {}
    console.error(`[WORKER RUNTIME CRASH]: Job failed for user ${userId}: `, error);
    throw error;
  } finally {
    if (client && client.processID) {
      client.release();
    }
  }
});