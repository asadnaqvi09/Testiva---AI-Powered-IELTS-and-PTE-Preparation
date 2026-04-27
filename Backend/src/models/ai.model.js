import pool from '../config/db.js';

export const saveFeedback = async (userID,feedback) => {
    const { attempt_id,user_id,overall_band_score,task_response_score,coherence_cohesion_score,lexical_resource_score,grammatical_range_score,detailed_analysis,improvement_suggestions,model_used } = data;
    const result = await pool.query(
        `INSERT INTO ai_feedback (attempt_id,user_id,overall_band_score,task_response_score,coherence_cohesion_score,lexical_resource_score,grammatical_range_score,detailed_analysis,improvement_suggestions,model_used) VALUES
        ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,[attempt_id,user_id,overall_band_score,task_response_score,coherence_cohesion_score,lexical_resource_score,grammatical_range_score,detailed_analysis,improvement_suggestions,model_used]
    );
    return result.rows[0];
};

export const getFeedbackByAttempt = async (attempt_id) => {
    const result = await pool.query(`SELECT * FROM ai_feedback WHERE attempt_id = $1`,[attempt_id]);
    return result.rows[0]
}