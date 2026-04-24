import pool from '../../config/db.js';
import * as progressModel from '../../models/progress.model.js';
import { addSyncJob } from '../offline/sync.queue.js';
import { submitTestSchema } from './progress.validator.js';

export const submitTest = async (req, res) => {
    const userId = req.user.id; // ✅ JWT authenticated
    const { test_id, client_started_at, client_completed_at, is_offline, responses } = req.body;
    
    try {
        const { error, value } = submitTestSchema.validate(req.body);
        if (error) return res.status(400).json({ success: false, message: error.details[0].message });
        
        if (is_offline) {
            await addSyncJob({ userId, testData: value });
            return res.status(202).json({ success: true, message: "Offline data queued for sync" });
        }
        
        const client = await pool.connect();
        try {
            await client.query('BEGIN');
            
            const attempt = await progressModel.startNewAttempt({
                user_id: userId,
                test_id: test_id,
                client_started_at: client_started_at,
                is_offline: false
            }, client);
            
            const attemptId = attempt.id;
            
            for (const resp of responses) {
                await progressModel.saveUserResponse({
                    attempt_id: attemptId,
                    question_id: resp.question_id,
                    user_answer: resp.user_answer,
                    audio_response_url: resp.audio_url || null,
                    client_created_at: resp.client_created_at || new Date()
                }, client);
            }
            
            // Status: pending_evaluation (AI will update later)
            await progressModel.finalizeAttempt(attemptId, {
                overall_band_score: null,
                feedback: null,
                client_completed_at: client_completed_at,
                status: 'pending_evaluation'
            }, client);
            
            await client.query('COMMIT');
            
            // Trigger AI evaluation asynchronously
            // await triggerAIEvaluation(attemptId); // Non-blocking
            
            res.status(201).json({
                success: true,
                message: "Test submitted successfully. AI evaluation in progress.",
                data: { attemptId, status: 'pending_evaluation' }
            });
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    } catch (error) {
        res.status(500).json({ success: false, message: "Submission failed" });
    }
};

export const getMyStats = async (req, res) => {
    try {
        const stats = await progressModel.getUserStats(req.user.id);
        res.status(200).json({
            success: true,
            data: stats || { message: "No tests taken yet" }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching stats" });
    }
};