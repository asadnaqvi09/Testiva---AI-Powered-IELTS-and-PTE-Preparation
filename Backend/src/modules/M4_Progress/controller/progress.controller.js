import pool from "../../../config/db.js";
import * as progressModel from "../models/progress.model.js";
import { addSyncJob } from "../../M5_Offline/sync.queue.js";
import { submitFullTestSchema } from "../validator/progress.validator.js";
import { cacheDelByPrefix } from "../../../utils/redisCache.js";

async function bustUserTestCaches(userId) {
  await cacheDelByPrefix(`test:mobile:${userId}:`);
}

export const submitTest = async (req, res) => {
  const userId = req.user.id;
  try {
    const { error, value } = submitFullTestSchema.validate(req.body);
    if (error) return res.status(400).json({ success: false, message: error.details[0].message });
    if (value.is_offline) {
      await addSyncJob({ userId, testData: value });
      return res.status(202).json({ success: true, message: "Offline data queued for sync" });
    }
    const hasSubjectiveSection = value.responses.some(resp => 
      resp.audio_response_url || 
      resp.audio_url || 
      (resp.user_answer && resp.user_answer.trim().split(/\s+/).length > 15)
    );

    const client = await pool.connect();
    try {
      await client.query("BEGIN");
      const attempt = await progressModel.startNewAttempt(
        {
          user_id: userId,
          test_id: value.test_id,
          client_started_at: value.client_started_at,
          is_offline: false,
        },
        client,
      );
      const attemptId = attempt.id;
      for (const resp of value.responses) {
        await progressModel.saveUserResponse(
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
      let finalStatus = "completed";
      let finalSyncStatus = "synced";
      let writingScore = value.writing_score ?? 0;
      let speakingScore = value.speaking_score ?? 0;
      let globalFeedback = value.feedback ?? "Evaluation completed.";
      if (hasSubjectiveSection) {
        finalStatus = "pending";
        finalSyncStatus = "pending";
        writingScore = 0;
        speakingScore = 0;
        globalFeedback = "Your subjective answers are being evaluated by Testiva AI Engine.";
      }

      await progressModel.finalizeAttempt(
        attemptId,
        {
          overall_band_score: hasSubjectiveSection ? 0 : (value.overall_band_score ?? 0),
          reading_score: value.reading_score ?? 0,
          listening_score: value.listening_score ?? 0,
          writing_score: writingScore,
          speaking_score: speakingScore,
          feedback: globalFeedback,
          client_completed_at: value.client_completed_at,
          status: finalStatus,
          sync_status: finalSyncStatus,
        },
        client,
      );
      await client.query("COMMIT");
      await bustUserTestCaches(userId);
      if (hasSubjectiveSection) {
        await addSyncJob({ 
          userId, 
          attemptId,
          testData: value,
          isOnlineAsyncHook: true 
        });
        return res.status(202).json({
          success: true,
          message: "Test content captured. Writing/Speaking evaluation has been delegated to background AI pipelines.",
          data: { attemptId, status: "pending" }
        });
      }
      return res.status(201).json({
        success: true,
        message: "Test submitted successfully.",
        data: { attemptId, status: "completed" },
      });

    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message || "Submission failed" });
  }
};

export const getMyStats = async (req, res) => {
  try {
    const stats = await progressModel.getUserStats(req.user.id);
    res.status(200).json({ success: true, data: stats || { message: "No tests taken yet" } });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching stats" });
  }
};

export const getTestResult = async (req, res) => {
  const { attempt_id } = req.params;
  const userId = req.user.id;
  try {
    const attempt = await progressModel.getFullAttemptDetail(attempt_id);
    if (!attempt) return res.status(404).json({ success: false, message: "Result not found" });
    if (attempt.user_id !== userId) return res.status(403).json({ success: false, message: "Unauthorized" });
    const responses = await progressModel.getAttemptResponses(attempt_id);
    const total = responses.length;
    const correct = responses.filter((r) => r.is_correct).length;
    res.status(200).json({
      success: true,
      data: {
        main_info: {
          test_title: attempt.test_title,
          test_type: attempt.test_type,
          band_score: attempt.overall_band_score ?? 0,
          status: attempt.status,
        },
        stats: {
          total_questions: total,
          correct_answers: correct,
          accuracy: total > 0 ? ((correct / total) * 100).toFixed(1) + "%" : "0%",
        },
        scores_breakdown: {
          reading: attempt.reading_score ?? 0,
          listening: attempt.listening_score ?? 0,
          writing: attempt.writing_score ?? 0,
          speaking: attempt.speaking_score ?? 0,
        },
        ai_analysis: {
          feedback: attempt.feedback,
          detailed_analysis: attempt.detailed_analysis,
          improvement_suggestions: attempt.improvement_suggestions,
        },
        review: responses.map((r) => ({
          q_no: r.order_number,
          question: r.question_text,
          type: r.question_type,
          sub_type: r.sub_question_type,
          your_answer: r.user_answer,
          correct_answer: r.correct_answer,
          is_correct: r.is_correct,
          marks: r.marks_obtained,
          ai_feedback_per_question: r.ai_feedback_per_question,
          word_limit_instruction: r.word_limit_instruction,
        })),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: "Error fetching result" });
  }
};