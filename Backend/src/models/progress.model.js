import pool from '../config/db.js';

export const startNewAttempt = async (data, client = pool) => {
    const { user_id, test_id, client_started_at, is_offline = false } = data;
    const dbClient = client === pool ? await pool.connect() : client;
    try {
        if (client === pool) await dbClient.query('BEGIN');
        const existing = await dbClient.query(
            `SELECT id FROM test_attempts 
             WHERE user_id = $1 AND test_id = $2 AND status = 'in_progress' 
             LIMIT 1`,
            [user_id, test_id]
        );
        if (existing.rows.length > 0) {
            if (client === pool) await dbClient.query('ROLLBACK');
            throw new Error("Test already in progress. Resume or abandon existing attempt.");
        }
        const result = await dbClient.query(
            `INSERT INTO test_attempts (user_id, test_id, client_started_at, is_offline, status) 
             VALUES ($1, $2, $3, $4, 'in_progress')
             RETURNING id, user_id, test_id, status, client_started_at, is_offline, created_at`,
            [user_id, test_id, client_started_at, is_offline]
        );
        if (client === pool) await dbClient.query('COMMIT');
        return result.rows[0];
    } catch (error) {
        if (client === pool) await dbClient.query('ROLLBACK');
        throw error;
    } finally {
        if (client === pool) dbClient.release();
    }
};

export const saveUserResponse = async (data, client = pool) => {
  const { attempt_id, question_id, user_answer, audio_response_url, client_created_at } = data
  const dbClient = client === pool ? await pool.connect() : client
  const normalize = v => {
    if (typeof v === 'string') return v.trim().toLowerCase()
    if (Array.isArray(v)) return v.map(x => String(x).toLowerCase()).sort().join(',')
    if (v && typeof v === 'object') return JSON.stringify(v)
    return String(v).toLowerCase()
  }
  try {
    if (client === pool) await dbClient.query('BEGIN')
    const qResult = await dbClient.query(`SELECT correct_answer, marks, question_type FROM questions WHERE id = $1 FOR SHARE`,[question_id])
    if (qResult.rows.length === 0) throw new Error('Question not found')
    const question = qResult.rows[0]
    let is_correct = false
    let marks_obtained = 0
    const qType = (question.question_type || '').toLowerCase()
    if (qType === 'mcq' || qType === 'true_false') {
      if (normalize(user_answer) === normalize(question.correct_answer)) {
        is_correct = true
        marks_obtained = question.marks
      }
    } else if (qType === 'fill_blank') {
      const acceptable = String(question.correct_answer).split('|').map(a => a.trim().toLowerCase())
      if (acceptable.includes(normalize(user_answer))) {
        is_correct = true
        marks_obtained = question.marks
      }
    }
    const result = await dbClient.query(
      `INSERT INTO user_responses (attempt_id, question_id, user_answer, audio_response_url, is_correct, marks_obtained, client_created_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       ON CONFLICT (attempt_id, question_id)
       DO UPDATE SET
        user_answer = EXCLUDED.user_answer,
        audio_response_url = COALESCE(EXCLUDED.audio_response_url,user_responses.audio_response_url),
        is_correct = EXCLUDED.is_correct,
        marks_obtained = EXCLUDED.marks_obtained,
        updated_at = NOW()
       RETURNING id,attempt_id,question_id,is_correct,marks_obtained,updated_at`,
      [attempt_id,question_id,user_answer,audio_response_url,is_correct,marks_obtained,client_created_at]
    )
    if (client === pool) await dbClient.query('COMMIT')
    return result.rows[0]
  } catch (error) {
    if (client === pool) await dbClient.query('ROLLBACK')
    throw error
  } finally {
    if (client === pool) dbClient.release()
  }
}

export const finalizeAttempt = async (id, data, client = pool) => {
    const { overall_band_score, feedback, client_completed_at, status } = data;
    const dbClient = client === pool ? await pool.connect() : client;
    try {
        if (client === pool) await dbClient.query('BEGIN');
        const result = await dbClient.query(
            `UPDATE test_attempts 
             SET overall_band_score = $1, 
                 feedback = $2, 
                 client_completed_at = $3,
                 status = $4,
                 server_synced_at = NOW(), 
                 updated_at = NOW()
             WHERE id = $5 
             RETURNING id, user_id, test_id, overall_band_score, status, client_completed_at, server_synced_at, updated_at`,
            [overall_band_score, feedback, client_completed_at, status, id]
        );
        if (result.rows.length === 0) throw new Error("Attempt not found");
        if (client === pool) await dbClient.query('COMMIT');
        return result.rows[0];
    } catch (error) {
        if (client === pool) await dbClient.query('ROLLBACK');
        throw error;
    } finally {
        if (client === pool) dbClient.release();
    }
};

export const updateUserStats = async (userId) => {
    const result = await pool.query(
        `INSERT INTO user_progress_stats (user_id, total_tests_taken, average_band_score, highest_score, last_test_date)
         SELECT 
            user_id,
            COUNT(id),
            AVG(overall_band_score),
            MAX(overall_band_score),
            MAX(created_at)
         FROM test_attempts
         WHERE user_id = $1 AND status = 'completed'
         GROUP BY user_id
         ON CONFLICT (user_id) DO UPDATE SET
            total_tests_taken = EXCLUDED.total_tests_taken,
            average_band_score = EXCLUDED.average_band_score,
            highest_score = EXCLUDED.highest_score,
            last_test_date = EXCLUDED.last_test_date,
            updated_at = NOW()
         RETURNING user_id, total_tests_taken, average_band_score, highest_score, last_test_date, updated_at`,
        [userId]
    );
    return result.rows[0] || null;
};

export const getUserStats = async (userId) => {
    const result = await pool.query(
        `SELECT user_id, total_tests_taken, average_band_score, highest_score, last_test_date, updated_at 
         FROM user_progress_stats WHERE user_id = $1`,
        [userId]
    );
    return result.rows[0] || null;
};

export const getAttemptById = async (id) => {
    const result = await pool.query(
        `SELECT id, user_id, test_id, overall_band_score, writing_score, reading_score, listening_score, speaking_score, feedback, status, client_started_at, client_completed_at, is_offline, created_at 
         FROM test_attempts WHERE id = $1`,
        [id]
    );
    return result.rows[0];
};

export const getAttemptResponses = async (attemptId) => {
    const result = await pool.query(
        `SELECT ur.id, ur.attempt_id, ur.question_id, ur.user_answer, ur.audio_response_url, ur.is_correct, ur.marks_obtained, ur.time_taken_seconds, ur.client_created_at,
                q.question_text, q.question_type, q.marks as total_marks, q.order_number
         FROM user_responses ur
         JOIN questions q ON ur.question_id = q.id
         WHERE ur.attempt_id = $1
         ORDER BY q.order_number`,
        [attemptId]
    );
    return result.rows;
};

export const updateAttemptScores = async (id, scores) => {
    const { overall_band_score, writing_score, reading_score, listening_score, speaking_score, feedback, status = 'completed' } = scores;
    const result = await pool.query(
        `UPDATE test_attempts 
         SET overall_band_score = $1, writing_score = $2, reading_score = $3, listening_score = $4, speaking_score = $5, feedback = $6, status = $7, updated_at = NOW()
         WHERE id = $8
         RETURNING id, overall_band_score, writing_score, reading_score, listening_score, speaking_score, status, updated_at`,
        [overall_band_score, writing_score, reading_score, listening_score, speaking_score, feedback, status, id]
    );
    return result.rows[0];
};

export const getFullAttemptDetail = async (attemptId) => {
    const result = await pool.query(
        `SELECT 
            ta.*, 
            t.title as test_title, 
            t.exam_type as test_type,
            af.overall_band_score as ai_overall_score,
            af.task_response_score,
            af.coherence_cohesion_score,
            af.lexical_resource_score,
            af.grammatical_range_score,
            af.detailed_analysis,
            af.improvement_suggestions
        FROM test_attempts ta
        JOIN tests t ON ta.test_id = t.id
        LEFT JOIN ai_feedback af ON ta.id = af.attempt_id
        WHERE ta.id = $1`, [attemptId]
    );
    return result.rows[0]
}