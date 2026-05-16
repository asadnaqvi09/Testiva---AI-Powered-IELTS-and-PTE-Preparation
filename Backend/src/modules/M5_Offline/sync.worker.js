import { syncQueue } from "./sync.queue.js";
import * as Progress from "../M4_Progress/models/progress.model.js";
import pool from "../../config/db.js";
import { cacheDelByPrefix } from "../../utils/redisCache.js";

syncQueue.process(async (job) => {
  const userId = job.data.userId || job.data.userID;
  const testData = job.data.testData;
  const client = await pool.connect();

  try {
    await client.query("BEGIN");
    const attempt = await Progress.startNewAttempt(
      {
        user_id: userId,
        test_id: testData.test_id,
        client_started_at: testData.client_started_at,
        is_offline: true,
      },
      client,
    );
    for (const resp of testData.responses) {
      await Progress.saveUserResponse(
        {
          attempt_id: attempt.id,
          question_id: resp.question_id,
          user_answer: resp.user_answer,
          audio_response_url: resp.audio_response_url ?? resp.audio_url ?? null,
          time_spent_seconds: resp.time_spent_seconds ?? resp.time_taken_seconds ?? 0,
          word_count: resp.word_count ?? 0,
          client_created_at: resp.client_created_at,
        },
        client,
      );
    }
    await Progress.finalizeAttempt(
      attempt.id,
      {
        overall_band_score: testData.overall_band_score ?? 0,
        reading_score: testData.reading_score ?? 0,
        listening_score: testData.listening_score ?? 0,
        writing_score: testData.writing_score ?? 0,
        speaking_score: testData.speaking_score ?? 0,
        feedback: testData.feedback ?? "Synced offline attempt.",
        client_completed_at: testData.client_completed_at,
        status: "completed",
        sync_status: "synced",
      },
      client,
    );
    await client.query("COMMIT");
    await cacheDelByPrefix(`test:mobile:${userId}:`);
    return { success: true, attemptId: attempt.id };
  } catch (error) {
    await client.query("ROLLBACK");
    console.error("Error processing sync job : ", error);
    throw error;
  } finally {
    client.release();
  }
});
