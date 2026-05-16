import pool from "../../../config/db.js";

export const saveFeedback = async (feedbackData, client = null) => {
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

export const getFeedbackByAttempt = async (attempt_id) => {
  const result = await pool.query(`SELECT * FROM ai_feedback WHERE attempt_id = $1::uuid`, [attempt_id]);
  return result.rows[0];
};
