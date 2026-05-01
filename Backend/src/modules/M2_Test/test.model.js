import pool from '../../config/db.js';

export const createTest = async (testData, client = pool) => {
    const { title, exam_type, is_full_mock, total_time_minutes, created_by } = testData;
    const result = await client.query(`
        INSERT INTO tests (title, exam_type, is_full_mock, total_time_minutes, created_by)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, title, exam_type, is_full_mock, total_time_minutes, created_by, created_at;
    `, [title, exam_type, is_full_mock, total_time_minutes, created_by]);
    return result.rows[0];
};
export const updateTestHeader = async (id, data) => {
    const { title, is_full_mock } = data;
    const result = await pool.query(`
        UPDATE tests SET title = $1, is_full_mock = $2, updated_at = NOW()
        WHERE id = $3 RETURNING id, title, exam_type, total_time_minutes;
    `, [title, is_full_mock, id]);
    return result.rows[0];
};
export const updateTestDuration = async (testId, client = pool) => {
    const result = await client.query(`
        UPDATE tests SET total_time_minutes = (
            SELECT COALESCE(SUM(time_limit_minutes), 0) FROM test_sections WHERE test_id = $1
        )
        WHERE id = $1 RETURNING total_time_minutes;
    `, [testId]);
    return result.rows[0];
};
export const deleteTest = async (id) => {
    const result = await pool.query(`DELETE FROM tests WHERE id = $1 RETURNING title`, [id]);
    return result.rows[0];
};
export const getAllTests = async (limit, offset, examType = null) => {
    let query = `SELECT id, title, exam_type, is_full_mock, total_time_minutes, created_at FROM tests`;
    const params = [];
    if (examType) {
        query += ` WHERE exam_type = $1`;
        params.push(examType);
    }
    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);
    const result = await pool.query(query, params);
    return result.rows;
};
export const getTestsByFilters = async (examTypes, allowedSections = null) => {
    let query = `
        SELECT DISTINCT t.id, t.title, t.exam_type, t.is_full_mock, t.total_time_minutes, t.created_at 
        FROM tests t LEFT JOIN test_sections ts ON t.id = ts.test_id
        WHERE t.exam_type = ANY($1) AND t.is_published = true
    `;
    const params = [examTypes];
    if (allowedSections) {
        query += ` AND ts.section_name = ANY($2)`;
        params.push(allowedSections);
    }
    query += ` ORDER BY t.created_at DESC`;
    const result = await pool.query(query, params);
    return result.rows;
};
export const getFullTestDetails = async (id) => {
    const result = await pool.query(`
        SELECT t.id as test_id, t.title, t.exam_type, t.is_full_mock, t.total_time_minutes,
        ts.id as section_id, ts.section_name, ts.time_limit_minutes, ts.order_number as section_order, ts.instructions,
        q.id as question_id, q.question_type, q.passage_text, q.question_text, q.options, q.correct_answer, q.audio_url, q.order_number as question_order, q.marks
        FROM tests t LEFT JOIN test_sections ts ON t.id = ts.test_id LEFT JOIN questions q ON ts.id = q.section_id
        WHERE t.id = $1 ORDER BY ts.order_number, q.order_number;
    `, [id]);
    if (result.rows.length === 0) return null;
    const test = { id: result.rows[0].test_id, title: result.rows[0].title, exam_type: result.rows[0].exam_type, is_full_mock: result.rows[0].is_full_mock, total_time_minutes: result.rows[0].total_time_minutes, sections: [] };
    const sectionMap = new Map();
    result.rows.forEach(row => {
        if (!row.section_id) return;
        if (!sectionMap.has(row.section_id)) {
            const section = { id: row.section_id, section_name: row.section_name, time_limit_minutes: row.time_limit_minutes, order_number: row.section_order, instructions: row.instructions, questions: [] };
            sectionMap.set(row.section_id, section);
            test.sections.push(section);
        }
        if (row.question_id) {
            sectionMap.get(row.section_id).questions.push({ id: row.question_id, question_type: row.question_type, passage_text: row.passage_text, question_text: row.question_text, options: row.options, correct_answer: row.correct_answer, audio_url: row.audio_url, order_number: row.question_order, marks: row.marks });
        }
    });
    return test;
};
export const createSection = async (sectionData, client = pool) => {
    const { test_id, section_name, time_limit_minutes, order_number, instructions } = sectionData;
    const result = await client.query(`
        INSERT INTO test_sections (test_id, section_name, time_limit_minutes, order_number, instructions)
        VALUES ($1, $2, $3, $4, $5) RETURNING *;
    `, [test_id, section_name, time_limit_minutes, order_number, instructions]);
    await updateTestDuration(test_id, client);
    return result.rows[0];
};
export const createSingleQuestion = async (q, client = pool) => {
    const result = await client.query(`
        INSERT INTO questions (section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *;
    `, [q.section_id, q.question_type, q.passage_text, q.question_text, JSON.stringify(q.options), q.correct_answer, q.audio_url, q.order_number, q.marks]);
    return result.rows[0];
};
export const createQuestions = async (questionsArray, client = pool) => {
    if (questionsArray.length === 0) return [];
    const placeholders = questionsArray.map((_, i) => `($${i * 9 + 1}, $${i * 9 + 2}, $${i * 9 + 3}, $${i * 9 + 4}, $${i * 9 + 5}, $${i * 9 + 6}, $${i * 9 + 7}, $${i * 9 + 8}, $${i * 9 + 9})`).join(', ');
    const flatValues = questionsArray.flatMap(q => [q.section_id, q.question_type, q.passage_text, q.question_text, JSON.stringify(q.options), q.correct_answer, q.audio_url, q.order_number, q.marks]);
    const result = await client.query(`INSERT INTO questions (section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks) VALUES ${placeholders} RETURNING id, section_id, question_type, question_text;`, flatValues);
    return result.rows;
};
export const getQuestion = async (id) => {
    const result = await pool.query(`SELECT id, audio_url FROM questions WHERE id = $1`, [id]);
    return result.rows[0];
};
export const updateQuestion = async (id, data) => {
    const { question_type, question_text, passage_text, options, correct_answer, audio_url, marks } = data;
    const result = await pool.query(`
        UPDATE questions SET question_type = $1, question_text = $2, passage_text = $3, options = $4, correct_answer = $5, audio_url = $6, marks = $7, updated_at = NOW()
        WHERE id = $8 RETURNING *;
    `, [question_type, question_text, passage_text, JSON.stringify(options), correct_answer, audio_url, marks, id]);
    return result.rows[0];
};
export const deleteQuestion = async (id) => {
    const result = await pool.query(`DELETE FROM questions WHERE id = $1 RETURNING id`, [id]);
    return result.rowCount > 0;
};