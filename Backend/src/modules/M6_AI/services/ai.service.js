import * as writingEvaluation from "../evaluators/writing.evaluator.js";
import * as speakingEvaluation from "../evaluators/speaking.evaluator.js";
import { processAudioToText } from "../processors (Input Cleaning)/speaking.processor.js";
import pool from "../../../config/db.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";

const formatFeedbackText = (value) => {
  if (value == null) return "";
  if (Array.isArray(value)) return value.map(String).filter(Boolean).join(" ");
  if (typeof value === "object") {
    try {
      return JSON.stringify(value);
    } catch {
      return String(value);
    }
  }
  return String(value).trim();
};

const resolveSpeakingTranscript = async (resp) => {
  const existing =
    resp.user_answer?.transcribed_text ||
    (typeof resp.user_answer === "string" ? resp.user_answer : "") ||
    "";
  const trimmed = String(existing).trim();
  const audioUrl = resp.audio_response_url || null;
  if (trimmed) {
    return {
      transcribedText: trimmed,
      durationSeconds: resp.time_spent_seconds || 0,
    };
  }
  if (!audioUrl) {
    return {
      transcribedText: "No speech detected",
      durationSeconds: resp.time_spent_seconds || 0,
    };
  }
  const stt = await processAudioToText(audioUrl);
  return {
    transcribedText: stt.transcribedText || "No speech detected",
    durationSeconds: stt.durationSeconds ?? resp.time_spent_seconds ?? 0,
  };
};

// Purana single entry point (Maintained for backward compatibility or single question triggers)
export const processEvaluation = async (userId, attemptId, testType, moduleType, data) => {
  const mod = (moduleType || "writing").toLowerCase();
  if (mod === "writing") {
    return await writingEvaluation.evaluateWriting(userId, attemptId, testType, data.question_text, data.student_response);
  }
  if (mod === "speaking") {
    return await speakingEvaluation.evaluateSpeakingTask(userId, attemptId, data);
  }
  throw new Error(`Unsupported module type: ${moduleType}`);
};

// =================================================================
// Alternate full-test AI path (manual/API). Live mocks use M5 sync.worker.js.
// Kept for backward compatibility — averages multi-task bands like the worker.
// =================================================================
export const processFullTestAI = async (attemptId) => {
  const attempt = await progressModel.getAttemptById(attemptId);
  if (!attempt) throw new Error("Attempt not found for AI processing");

  const responses = await progressModel.getAttemptResponses(attemptId);
  
  console.log(`[AI Service] Processing asynchronous payload for Test Type: ${attempt.test_type}`);

  const writingScores = [];
  const speakingScores = [];
  let feedbackTexts = [];

  const writingResponses = responses.filter((r) => {
    const qt = (r.question_type || "").toLowerCase();
    const sub = (r.sub_question_type || "").toLowerCase();
    return (
      qt === "writing" ||
      qt === "essay" ||
      [
        "chart_description",
        "opinion",
        "discussion",
        "problem_solution",
        "advantages_disadvantages",
        "two_part_question",
        "request_information",
        "explain_situation",
        "provide_opinion",
        "task_1",
        "task_2",
      ].includes(sub)
    );
  });
  for (const wr of writingResponses) {
    try {
      console.log(`[AI Service] Evaluating Writing Question ID: ${wr.question_id}`);
      const fb = await writingEvaluation.evaluateWriting(
        attempt.user_id, 
        attemptId, 
        attempt.test_type, 
        wr.question_text, 
        wr.user_answer?.text_essay || wr.user_answer,
        { skipScoreUpdate: true }
      );
      const band = Number(fb.overall_band_score) || 0;
      if (band > 0) writingScores.push(band);
      const critique = formatFeedbackText(fb.improvement_suggestions || fb.detailed_analysis);
      feedbackTexts.push(`Writing Feedback: ${critique}`);
      await progressModel.updateResponseAiFeedback(
        attemptId,
        wr.question_id,
        critique || `Writing band ${band}`,
      ).catch(() => {});
    } catch (err) {
      console.error("Async Mock Writing Processing Failed:", err);
    }
  }

  const speakingResponses = responses.filter((r) => {
    const qt = (r.question_type || "").toLowerCase();
    const sub = (r.sub_question_type || "").toLowerCase();
    return qt === "speaking" || ["part_1", "part_2", "part_3"].includes(sub);
  });
  for (const sr of speakingResponses) {
    try {
      console.log(`[AI Service] Evaluating Speaking Question ID: ${sr.question_id}`);
      const transcriptionData = await resolveSpeakingTranscript(sr);
      const fb = await speakingEvaluation.evaluateSpeakingTask(
        attempt.user_id, 
        attemptId, 
        transcriptionData,
        { skipScoreUpdate: true }
      );
      const band = Number(fb.overall_band_score) || 0;
      if (band > 0) speakingScores.push(band);
      const critique = formatFeedbackText(fb.improvement_suggestions || fb.detailed_analysis);
      feedbackTexts.push(`Speaking Feedback: ${critique}`);
      await progressModel.updateResponseAiFeedback(
        attemptId,
        sr.question_id,
        critique || `Speaking band ${band}`,
      ).catch(() => {});
    } catch (err) {
      console.error("Async Mock Speaking Processing Failed:", err);
    }
  }

  const freshAttempt = await progressModel.getAttemptById(attemptId);
  const scoreMeta = await progressModel.getAttemptScoreMeta(attemptId);
  const examType = (scoreMeta?.exam_type || attempt.test_type || "").toUpperCase();
  const isPte = examType === "PTE";
  const isSingular = (scoreMeta?.test_category || "") === "singular_module";

  const avgOrZero = (scores) => {
    if (!scores.length) return 0;
    const mean = scores.reduce((a, b) => a + b, 0) / scores.length;
    return isPte ? Math.round(mean) : Math.round(mean * 2) / 2;
  };
  
  const rScore = Number(freshAttempt.reading_score) || 0;
  const lScore = Number(freshAttempt.listening_score) || 0;
  const wScore = avgOrZero(writingScores) || Number(freshAttempt.writing_score) || 0;
  const sScore = avgOrZero(speakingScores) || Number(freshAttempt.speaking_score) || 0;

  let overallBand = isSingular
    ? (sScore || wScore || rScore || lScore || 0)
    : (rScore + lScore + wScore + sScore) / 4;
  if (!isPte) {
    overallBand = Math.round(overallBand * 2) / 2;
  } else {
    overallBand = Math.round(overallBand);
  }

  await progressModel.updateAttemptScores(attemptId, {
    overall_band_score: overallBand,
    reading_score: rScore,
    listening_score: lScore,
    writing_score: wScore,
    speaking_score: sScore,
    feedback: feedbackTexts.join("\n\n") || "Evaluation compiled successfully by Testiva AI Engine.",
    status: "completed"
  });

  const finalClient = await pool.connect();
  try {
    await finalClient.query(
      "UPDATE test_attempts SET sync_status = 'synced', status = 'completed', updated_at = NOW() WHERE id = $1::uuid", 
      [attemptId]
    );
  } finally {
    finalClient.release();
  }

  await progressModel.updateUserStats(attempt.user_id);
  console.log(`[AI Service] Full Evaluation compiled for attempt ${attemptId}. Overall: ${overallBand}`);
  return { success: true, overallBand };
};

// =================================================================
// RESTORED FUNCTIONS: Database Operations for AI Feedback
// =================================================================
const saveFeedback = async (feedbackData, client = null) => {
  const db = client || (await pool.connect());
  const ownClient = !client;
  try {
    if (ownClient) await db.query("BEGIN");
    const {
      attempt_id,
      user_id,
      overall_band_score,
      task_response_score,
      coherence_cohesion_score,
      lexical_resource_score,
      grammatical_range_score,
      detailed_analysis,
      improvement_suggestions,
      model_used,
    } = feedbackData;
    const analysisVal =
      typeof detailed_analysis === "string" ? detailed_analysis : JSON.stringify(detailed_analysis ?? {});
    
    await db.query(`DELETE FROM ai_feedback WHERE attempt_id = $1::uuid`, [attempt_id]);
    const feedbackResult = await db.query(
      `INSERT INTO ai_feedback (
        attempt_id, user_id, overall_band_score, task_response_score,
        coherence_cohesion_score, lexical_resource_score,
        grammatical_range_score, detailed_analysis,
        improvement_suggestions, model_used
      ) VALUES ($1::uuid,$2::uuid,$3,$4,$5,$6,$7,$8::jsonb,$9,$10)
      RETURNING *`,
      [
        attempt_id,
        user_id,
        overall_band_score,
        task_response_score,
        coherence_cohesion_score,
        lexical_resource_score,
        grammatical_range_score,
        analysisVal,
        improvement_suggestions,
        model_used,
      ],
    );
    if (ownClient) await db.query("COMMIT");
    return feedbackResult.rows[0];
  } catch (error) {
    if (ownClient) await db.query("ROLLBACK");
    throw error;
  } finally {
    if (ownClient) db.release();
  }
};

const getFeedbackByAttempt = async (attempt_id) => {
  const result = await pool.query(`SELECT * FROM ai_feedback WHERE attempt_id = $1::uuid`, [attempt_id]);
  return result.rows[0];
};

export { saveFeedback, getFeedbackByAttempt };