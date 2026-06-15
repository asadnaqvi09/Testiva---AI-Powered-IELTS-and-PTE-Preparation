import * as writingEvaluation from "../evaluators/writing.evaluator.js";
import * as speakingEvaluation from "../evaluators/speaking.evaluator.js";
import pool from "../../../config/db.js";
import * as progressModel from "../../M4_Progress/models/progress.model.js";

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
// REFACTORED CORE ENGINE: Full Mock / Offline Sync Process Router
// =================================================================
export const processFullTestAI = async (attemptId) => {
  // 1. Test Info aur User Responses fetch karein jahan AI checking chahiye
  const attempt = await progressModel.getAttemptById(attemptId);
  if (!attempt) throw new Error("Attempt not found for AI processing");

  const responses = await progressModel.getAttemptResponses(attemptId);
  
  console.log(`[AI Service] Processing asynchronous payload for Test Type: ${attempt.test_type}`);

  let writingScore = null;
  let speakingScore = null;
  let feedbackTexts = [];

  // 2. Filter & Process Writing Tasks
  const writingResponses = responses.filter(r => (r.question_type || '').toLowerCase() === 'writing');
  for (const wr of writingResponses) {
    try {
      console.log(`[AI Service] Evaluating Writing Question ID: ${wr.question_id}`);
      
      // --- ITEM #10 FIX: Enforce isolated background validation limits ---
      const fb = await writingEvaluation.evaluateWriting(
        attempt.user_id, 
        attemptId, 
        attempt.test_type, 
        wr.question_text, 
        wr.user_answer?.text_essay || wr.user_answer,
        { skipScoreUpdate: true } // Prevents loop cycles from overwriting master scores
      );
      
      writingScore = fb.overall_band_score;
      feedbackTexts.push(`Writing Feedback: ${fb.improvement_suggestions || fb.general_critique}`);
    } catch (err) {
      console.error("Async Mock Writing Processing Failed:", err);
    }
  }

  // 3. Filter & Process Speaking Tasks
  const speakingResponses = responses.filter(r => (r.question_type || '').toLowerCase() === 'speaking');
  for (const sr of speakingResponses) {
    try {
      console.log(`[AI Service] Evaluating Speaking Question ID: ${sr.question_id}`);
      const transcriptionData = {
        transcribedText: sr.user_answer?.transcribed_text || sr.user_answer || "No speech detected",
        durationSeconds: sr.time_spent_seconds || 0
      };

      // --- ITEM #10 FIX: Enforce isolated background validation limits ---
      const fb = await speakingEvaluation.evaluateSpeakingTask(
        attempt.user_id, 
        attemptId, 
        transcriptionData,
        { skipScoreUpdate: true } // Isolates transactional footprint inside the loop
      );
      
      speakingScore = fb.overall_band_score;
      feedbackTexts.push(`Speaking Feedback: ${fb.improvement_suggestions || fb.general_critique}`);
    } catch (err) {
      console.error("Async Mock Speaking Processing Failed:", err);
    }
  }

  // 4. SMART BAND CALCULATOR (IELTS/PTE Compliant)
  const freshAttempt = await progressModel.getAttemptById(attemptId);
  
  const rScore = Number(freshAttempt.reading_score) || 0;
  const lScore = Number(freshAttempt.listening_score) || 0;
  const wScore = writingScore !== null ? Number(writingScore) : (Number(freshAttempt.writing_score) || 0);
  const sScore = speakingScore !== null ? Number(speakingScore) : (Number(freshAttempt.speaking_score) || 0);

  let overallBand = (rScore + lScore + wScore + sScore) / 4;
  if ((attempt.test_type || '').toUpperCase() !== 'PTE') {
    // IELTS rounding mechanism logic integration
    overallBand = Math.round(overallBand * 2) / 2;
  } else {
    // PTE whole integer rounding rule
    overallBand = Math.round(overallBand);
  }

  // 5. Finalize Single Atomic Score Updates
  // Yahan master final execution query pure objective aur subjective variables ko finalize karegi
  await progressModel.updateAttemptScores(attemptId, {
    overall_band_score: overallBand,
    reading_score: rScore,
    listening_score: lScore,
    writing_score: wScore,
    speaking_score: sScore,
    feedback: feedbackTexts.join("\n\n") || "Evaluation compiled successfully by Testiva AI Engine.",
    status: "completed"
  });

  // Global transactional database lock parameters update
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