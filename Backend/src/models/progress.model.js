import pool from '../config/db.js'

export const startNewAttempt = async (data) => {
    const { user_id,test_id,client_started_at,is_offline } = data
    const result = await pool.query(
        `INSERT INTO test_attempts (user_id,test_id,client_started_at,is_offline,status) 
        VALUES ($1,$2,$3,$4,'in-progress')
        RETURNING *`,[user_id,test_id,client_started_at,is_offline]
    )
    return await result.rows[0];
}

export const saveUserResponse = async (data , client = pool) => {
    const { attempt_id,question_id,user_answer,audio_response_url,client_created_at } = data
    const qQuery = `SELECT correct_answer,marks,question_type FROM questions where id = $1`
    const qResult = await client.query(qQuery, [question_id])
    const question = qResult.rows[0]
    let is_correct = false
    let marks_obtained = 0
    if (question.question_type === 'MCQ' || question.question_type === 'short-answer') {
        if (user_answer && user_answer.trim().toLowerCase() === question.correct_answer.trim().toLowerCase()) {
            is_correct = true;
            marks_obtained = question.marks;
        }
    }
    const result = await client.query(
        `
        INSERT INTO user_response (attempt_id,question_id,user_answer,audio_response_url,is_correct,marks_obtained,client_created_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7)
        RETURNING *
        `, [attempt_id,question_id,user_answer,audio_response_url,is_correct,marks_obtained,client_created_at]
    )
    return await result.rows[0]
}

export const finalizeAttempt = async (id,data,client = pool) => {
    const { overall_band_score,feedback,client_completed_at,status } = data
    const result = await client.query(
        `
        UPDATE test_attempts SET overall_band_score = $1, feedback = $2, client_completed_at = $3,status = $4,server_synced_at = NOW(), updated_at = NOW()
        WHERE id = $5 RETURNING *
        `, [overall_band_score,feedback,client_completed_at,status,id]
    )
    return await result.rows[0]
}

export const updatedUserStats = async (id) => {
    const result = await pool.query(
        `
        INSERT INTO user_progress_stats (user_id,total_test_taken,average_band_score,highest_score,last_test_date)
        SELECT user_id,COUNT (id),AVG(overall_score_band),MAX(overall_score_band),MAX(created_at) FROM test_attempts
        WHERE user_id = $1 and status != 'in-progress'
        GROUP BY user_id
        ON CONFLICT (user_id) DO UPDATE SET
            total_tests_taken = EXCLUDED.total_tests_taken,
            average_band_score = EXCLUDED.average_band_score,
            highest_score = EXCLUDED.highest_score,
            last_test_date = EXCLUDED.last_test_date,
            updated_at = NOW()
        `,[id]
    )
    return await result.rows[0]
}