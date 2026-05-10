import pool from '../../../config/db.js';

export const saveFeedback = async (feedbackData) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
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
            model_used 
        } = feedbackData;
        const feedbackResult = await client.query(
            `INSERT INTO ai_feedback (
                attempt_id, user_id, overall_band_score, task_response_score, 
                coherence_cohesion_score, lexical_resource_score, 
                grammatical_range_score, detailed_analysis, 
                improvement_suggestions, model_used
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
            [
                attempt_id, user_id, overall_band_score, task_response_score, 
                coherence_cohesion_score, lexical_resource_score, 
                grammatical_range_score, JSON.stringify(detailed_analysis),
                improvement_suggestions, model_used
            ]
        );
        await client.query(
            `UPDATE test_attempts 
             SET overall_band_score = $1, 
                 writing_score = $1, -- Assuming writing for now
                 status = 'completed', 
                 updated_at = NOW() 
             WHERE id = $2`,
            [overall_band_score, attempt_id]
        );
        await client.query('COMMIT');
        return feedbackResult.rows[0];
    } catch (error) {
        await client.query('ROLLBACK');
        console.error("[AI-Model-Error] Transaction failed:", error);
        throw error;
    } finally {
        client.release();
    }
};

export const getFeedbackByAttempt = async (attempt_id) => {
    const result = await pool.query(
        `SELECT * FROM ai_feedback WHERE attempt_id = $1`,
        [attempt_id]
    );
    return result.rows[0];
};