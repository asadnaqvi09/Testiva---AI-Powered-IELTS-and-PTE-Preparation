import pool from '../../config/db.js'
import * as progressModel from '../../models/progress.model.js'

export const submitTest = async (req,res) => {
    const client = await pool.connect();
    try {
        const {test_id,client_started_at,client_completed_at,is_offline,responses} = req.body;
        const { id } = req.params;
        await client.query('BEGIN');
        const attempt = await progressModel.startNewAttempt({
            user_id : id,
            test_id : test_id,
            client_started_at : client_started_at,
            is_offline : is_offline
        });
        const attemptID = attempt.id;
        for (const resp of responses) {
            await progressModel.saveUserResponse({
                attempt_id: attemptID,
                question_id: resp.question_id,
                user_answer: resp.user_answer,
                audio_response_url: resp.audio_url || null,
                client_created_at: resp.client_created_at || new Date()
            }, client); 
        }
        await progressModel.finalizeAttempt(attemptID,{
            overall_band_score: 0.0, 
            feedback: "Evaluation in progress by AI...",
            client_completed_at: client_completed_at,
            status: is_offline ? 'synced' : 'completed'
        }, client);
        await progressModel.updatedUserStats(id);
        await client.query('COMMIT');
        res.status(201).json({
            success : true,
            message : "Test Submitted and Synced Successfully",
            data : { attemptID }
        })
    } catch (error) {
        await client.query('ROLLBACK');
        console.error("Error in submitTest Controller : ", error);
        res.status(500).json({
            success : false,
            message : "Synced Failed Please Try Again Letter"
        })
    } finally {
        client.release();
    }
}

export const getMyStats = async (req,res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM user_progress_stats WHERE user_id = $1`,
            [req.user.id]
        );
        res.status(200).json({
            success : true,
            message : "Fetched User Stats Successfully",
            data : result.rows[0] || {}
        })
    } catch (error) {
        console.error("Error in getMyStats Controller : ", error);
        res.status(500).json({
            success : false,
            message : "Error fetching stats"
        })
    }
}