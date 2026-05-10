import pool from '../../../config/db.js';

export const createPracticeSession = async (data, client = pool) => {
    const { user_id, section_name, question_type, difficulty_level } = data;
    const result = await client.query(
        `INSERT INTO practice_sessions (user_id, section_name, question_type, difficulty_level, status)
         VALUES ($1, $2, $3, $4, 'in_progress')
         RETURNING id, user_id, section_name, question_type, difficulty_level, status, started_at`,
        [user_id, section_name, question_type, difficulty_level]
    );
    return result.rows[0];
};

export const getPracticeQuestion = async (userId, sectionName, questionType, difficulty, limit = 1, excludeIds = []) => {
    let query = `
        SELECT q.id, q.question_type, q.passage_text, q.question_text, q.options, q.audio_url, q.marks, q.difficulty_level
        FROM questions q
        JOIN test_sections ts ON q.section_id = ts.id
        WHERE ts.section_name = $1
        AND q.id NOT IN (
            SELECT question_id FROM practice_responses pr
            JOIN practice_sessions ps ON pr.session_id = ps.id
            WHERE ps.user_id = $2
        )`;
    const values = [sectionName, userId];
    
    if (questionType) {
        values.push(questionType);
        query += ` AND q.question_type = $${values.length}`;
    }
    if (difficulty) {
        values.push(difficulty);
        query += ` AND q.difficulty_level = $${values.length}`;
    }
    if (excludeIds.length > 0) {
        const placeholders = excludeIds.map((_, i) => `$${values.length + i + 1}`).join(', ');
        query += ` AND q.id NOT IN (${placeholders})`;
        values.push(...excludeIds);
    }
    
    query += ` ORDER BY RANDOM() LIMIT $${values.length + 1}`;
    values.push(limit);
    
    const result = await pool.query(query, values);
    return result.rows;
};

export const savePracticeResponse = async (data, client = pool) => {
    const { session_id, question_id, user_answer, is_correct, marks_obtained, time_taken_seconds } = data;
    const result = await client.query(
        `INSERT INTO practice_responses (session_id, question_id, user_answer, is_correct, marks_obtained, time_taken_seconds)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (session_id, question_id)
         DO UPDATE SET user_answer = EXCLUDED.user_answer, is_correct = EXCLUDED.is_correct,
                       marks_obtained = EXCLUDED.marks_obtained, time_taken_seconds = EXCLUDED.time_taken_seconds
         RETURNING id, session_id, question_id, is_correct, marks_obtained`,
        [session_id, question_id, user_answer, is_correct, marks_obtained, time_taken_seconds]
    );
    return result.rows[0];
};

export const completePracticeSession = async (sessionId, client = pool) => {
    const result = await client.query(
        `UPDATE practice_sessions
         SET status = 'completed',
             total_questions = (SELECT COUNT(*) FROM practice_responses WHERE session_id = $1),
             correct_answers = (SELECT COUNT(*) FROM practice_responses WHERE session_id = $1 AND is_correct = true),
             accuracy = (SELECT COALESCE(AVG(CASE WHEN is_correct THEN 100.0 ELSE 0.0 END), 0) FROM practice_responses WHERE session_id = $1),
             completed_at = NOW()
         WHERE id = $1
         RETURNING id, total_questions, correct_answers, accuracy, completed_at`,
        [sessionId]
    );
    return result.rows[0];
};

export const getPracticeStats = async (userId) => {
    const result = await pool.query(
        `SELECT 
            section_name,
            COUNT(*) as sessions_count,
            SUM(total_questions) as total_attempted,
            SUM(correct_answers) as total_correct,
            ROUND(AVG(accuracy), 2) as avg_accuracy
         FROM practice_sessions
         WHERE user_id = $1 AND status = 'completed'
         GROUP BY section_name`,
        [userId]
    );
    return result.rows;
};

export const getRecentPracticeSessions = async (userId, limit = 10) => {
    const result = await pool.query(
        `SELECT id, section_name, question_type, difficulty_level, total_questions, correct_answers, accuracy, completed_at
         FROM practice_sessions
         WHERE user_id = $1
         ORDER BY created_at DESC
         LIMIT $2`,
        [userId, limit]
    );
    return result.rows;
};