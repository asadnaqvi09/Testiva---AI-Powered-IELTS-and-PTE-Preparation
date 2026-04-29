import { syncQueue } from "./sync.queue.js";
import * as Progress from '../../models/progress.model.js';
import pool from '../../config/db.js';

syncQueue.process(async (job) => {
    const { userID, testData } = job.data;
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        const attempt = await Progress.startNewAttempt({
            user_id: userID,
            test_id: testData.test_id,
            client_started_at: testData.client_started_at,
            is_offline: true
        }, client);
        for (const resp of testData.responses) {
            await Progress.saveUserResponse({
                attempt_id: attempt.id,
                question_id: resp.question_id,
                user_answer: resp.user.answer,
                audio_response_url: resp.audio_url || null,
                client_created_at: resp.client_created_at
            }, client);
        }
        await Progress.finalizeAttempt(attempt.id, {
            overall_band_score: 0.0,
            client_completed_at: testData.client_completed_at,
            status: 'synced'
        }, client);
        await Progress.updateUserStats(userID);
        await client.query('COMMIT');
        return { success: true, attemptId: attempt.id };
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error processing sync job : ', error);
        throw error;
    } finally {
        client.release();
    }
})