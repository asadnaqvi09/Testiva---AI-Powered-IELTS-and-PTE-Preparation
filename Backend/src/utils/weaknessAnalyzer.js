import pool from '../config/db.js';

export const analyzeWeakness = async (userId) => {
    const sectionAccuracy = await pool.query(
        `SELECT 
            ts.section_name,
            COUNT(ur.id) as total_attempted,
            COUNT(*) FILTER (WHERE ur.is_correct = true) as correct_count,
            ROUND(COUNT(*) FILTER (WHERE ur.is_correct = true) * 100.0 / COUNT(*), 2) as accuracy
         FROM user_responses ur
         JOIN questions q ON ur.question_id = q.id
         JOIN test_sections ts ON q.section_id = ts.id
         JOIN test_attempts ta ON ur.attempt_id = ta.id
         WHERE ta.user_id = $1
         AND ta.status = 'completed'
         GROUP BY ts.section_name`,
        [userId]
    );
    
    const questionTypeAccuracy = await pool.query(
        `SELECT 
            q.question_type,
            COUNT(ur.id) as total_attempted,
            COUNT(*) FILTER (WHERE ur.is_correct = true) as correct_count,
            ROUND(COUNT(*) FILTER (WHERE ur.is_correct = true) * 100.0 / COUNT(*), 2) as accuracy
         FROM user_responses ur
         JOIN questions q ON ur.question_id = q.id
         JOIN test_attempts ta ON ur.attempt_id = ta.id
         WHERE ta.user_id = $1
         AND ta.status = 'completed'
         GROUP BY q.question_type`,
        [userId]
    );
    
    const bandScores = await pool.query(
        `SELECT 
            AVG(overall_band_score) as avg_band,
            MAX(overall_band_score) as highest_band,
            AVG(reading_score) as avg_reading,
            AVG(listening_score) as avg_listening,
            AVG(writing_score) as avg_writing,
            AVG(speaking_score) as avg_speaking
         FROM test_attempts
         WHERE user_id = $1 AND status = 'completed'`,
        [userId]
    );
    
    const scores = bandScores.rows[0];
    const weakSections = [];
    const weakQuestionTypes = [];
    
    sectionAccuracy.rows.forEach(row => {
        if (row.accuracy < 50) weakSections.push(row.section_name);
    });
    
    questionTypeAccuracy.rows.forEach(row => {
        if (row.accuracy < 50) weakQuestionTypes.push(row.question_type);
    });
    
    return {
        sectionAccuracy: sectionAccuracy.rows,
        questionTypeAccuracy: questionTypeAccuracy.rows,
        averageBand: parseFloat(scores.avg_band) || 0,
        highestBand: parseFloat(scores.highest_band) || 0,
        sectionScores: {
            reading: parseFloat(scores.avg_reading) || 0,
            listening: parseFloat(scores.avg_listening) || 0,
            writing: parseFloat(scores.avg_writing) || 0,
            speaking: parseFloat(scores.avg_speaking) || 0
        },
        weakSections,
        weakQuestionTypes,
    };
};
