import pool from '../../config/db.js'
import * as progressModel from '../../models/progress.model.js'
import { addSyncJob } from '../offline/sync.queue.js';

export const submitTest = async (req, res) => {
    const { test_id, client_started_at, client_completed_at, is_offline, responses } = req.body;
    const { id } = req.params;
    try {
        if (is_offline) {
            await addSyncJob({
                userId: id,
                testData: { test_id, client_started_at, client_completed_at, responses }
            });
            return res.status(202).json({
                success: true,
                message: "Offline data received and added to sync queue"
            });
        }
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            const attempt = await progressModel.startNewAttempt({
                user_id: id,
                test_id: test_id,
                client_started_at: client_started_at,
                is_offline: false
            }, client);
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
            await progressModel.finalizeAttempt(attemptID, {
                overall_band_score: 0.0,
                feedback: "Evaluation in progress by AI...",
                client_completed_at: client_completed_at,
                status: 'completed'
            }, client);
            await progressModel.updatedUserStats(id, client);
            await client.query('COMMIT');
            res.status(201).json({
                success: true,
                message: "Test Submitted Successfully",
                data: { attemptID }
            });
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    } catch (error) {
        console.error("Error in submitTest Controller: ", error);
        res.status(500).json({
            success: false,
            message: "Submission Failed"
        });
    }
}

export const getMyStats = async (req, res) => {
    try {
        const result = await pool.query(
            `SELECT * FROM user_progress_stats WHERE user_id = $1`,
            [req.user.id]
        );
        res.status(200).json({
            success: true,
            message: "Fetched User Stats Successfully",
            data: result.rows[0] || {}
        })
    } catch (error) {
        console.error("Error in getMyStats Controller : ", error);
        res.status(500).json({
            success: false,
            message: "Error fetching stats"
        })
    }
}