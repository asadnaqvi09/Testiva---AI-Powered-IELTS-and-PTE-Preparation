import pool from '../../config/db.js';
import * as progressModel from './progress.model.js';
import { addSyncJob } from '../M5_Offline/offline/sync.queue.js';
import { submitTestSchema } from './progress.validator.js';

export const submitTest = async (req, res) => {
    const userId = req.user.id;
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
                test_id,
                client_started_at,
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
            await progressModel.finalizeAttempt(attemptId, {
                overall_band_score: null,
                feedback: null,
                client_completed_at,
                status: 'pending_evaluation'
            }, client);
            await progressModel.updateUserStats(userId);
            await client.query('COMMIT');
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
        const correct = responses.filter(r => r.is_correct).length;
        res.status(200).json({
            success: true,
            data: {
                main_box: {
                    band_score: attempt.overall_band_score || "Analyzing",
                    correct,
                    incorrect: total - correct,
                    percentage: total > 0 ? ((correct / total) * 100).toFixed(2) + "%" : "0%"
                },
                performance_sliders: {
                    reading: attempt.reading_score || 0,
                    listening: attempt.listening_score || 0,
                    writing: attempt.writing_score || 0,
                    speaking: attempt.speaking_score || 0
                },
                ai_feedback: {
                    status: attempt.status,
                    feedback: attempt.feedback || "AI is evaluating...",
                    detailed_analysis: attempt.detailed_analysis || null,
                    improvement_suggestions: attempt.improvement_suggestions || null
                },
                quick_review: responses.map(r => ({
                    q_no: r.order_number,
                    status: r.is_correct ? 'correct' : 'incorrect',
                    your_answer: r.user_answer,
                    type: r.question_type
                }))
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching result" });
    }
};