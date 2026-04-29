import pool from "../../config/db.js";

/**
 * CORE TEST OPERATIONS
 */

export const createTest = async (testData, client = pool) => {
    const { title, exam_type, is_full_mock, total_time_minutes, created_by } = testData;
    const query = `
        INSERT INTO tests (title, exam_type, is_full_mock, total_time_minutes, created_by)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, title, exam_type, is_full_mock, total_time_minutes, created_by, created_at;
    `;
    const result = await client.query(query, [title, exam_type, is_full_mock, total_time_minutes, created_by]);
    return result.rows[0];
};

export const updateTestDuration = async (testId, client = pool) => {
    const query = `
        UPDATE tests 
        SET total_time_minutes = (
            SELECT COALESCE(SUM(time_limit_minutes), 0) 
            FROM test_sections 
            WHERE test_id = $1
        )
        WHERE id = $1
        RETURNING total_time_minutes;
    `;
    const result = await client.query(query, [testId]);
    return result.rows[0];
};

/**
 * SECTION & QUESTION OPERATIONS
 */

export const createSection = async (sectionData, client = pool) => {
    const { test_id, section_name, time_limit_minutes, order_number, instructions } = sectionData;
    const query = `
        INSERT INTO test_sections (test_id, section_name, time_limit_minutes, order_number, instructions)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *;
    `;
    const result = await client.query(query, [test_id, section_name, time_limit_minutes, order_number, instructions]);
    
    // Auto-update total test time
    await updateTestDuration(test_id, client);
    
    return result.rows[0];
};

export const createQuestionsBatch = async (questionsArray, client = pool) => {
    if (questionsArray.length === 0) return [];
    const placeholders = questionsArray.map((_, i) => 
        `($${i * 9 + 1}, $${i * 9 + 2}, $${i * 9 + 3}, $${i * 9 + 4}, $${i * 9 + 5}, $${i * 9 + 6}, $${i * 9 + 7}, $${i * 9 + 8}, $${i * 9 + 9})`
    ).join(', ');
    const flatValues = questionsArray.flatMap(q => [
        q.section_id, q.question_type, q.passage_text, q.question_text,
        JSON.stringify(q.options), q.correct_answer, q.audio_url, q.order_number, q.marks
    ]);
    const query = `
        INSERT INTO questions (section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks)
        VALUES ${placeholders}
        RETURNING id, section_id, question_type, question_text;
    `;
    const result = await client.query(query, flatValues);
    return result.rows;
};

/**
 * FETCH OPERATIONS (Tier & Role Based)
 */

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
        FROM tests t
        LEFT JOIN test_sections ts ON t.id = ts.test_id
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
    const query = `
        SELECT 
            t.id as test_id, t.title, t.exam_type, t.is_full_mock, t.total_time_minutes,
            ts.id as section_id, ts.section_name, ts.time_limit_minutes, ts.order_number as section_order, ts.instructions,
            q.id as question_id, q.question_type, q.passage_text, q.question_text, q.options, q.correct_answer, q.audio_url, q.order_number as question_order, q.marks
        FROM tests t
        LEFT JOIN test_sections ts ON t.id = ts.test_id
        LEFT JOIN questions q ON ts.id = q.section_id
        WHERE t.id = $1
        ORDER BY ts.order_number, q.order_number;
    `;
    const result = await pool.query(query, [id]);
    if (result.rows.length === 0) return null;

    const test = {
        id: result.rows[0].test_id,
        title: result.rows[0].title,
        exam_type: result.rows[0].exam_type,
        is_full_mock: result.rows[0].is_full_mock,
        total_time_minutes: result.rows[0].total_time_minutes,
        sections: []
    };

    const sectionMap = new Map();
    result.rows.forEach(row => {
        if (!row.section_id) return;
        if (!sectionMap.has(row.section_id)) {
            const section = {
                id: row.section_id,
                section_name: row.section_name,
                time_limit_minutes: row.time_limit_minutes,
                order_number: row.section_order,
                instructions: row.instructions,
                questions: []
            };
            sectionMap.set(row.section_id, section);
            test.sections.push(section);
        }
        if (row.question_id) {
            sectionMap.get(row.section_id).questions.push({
                id: row.question_id,
                question_type: row.question_type,
                passage_text: row.passage_text,
                question_text: row.question_text,
                options: row.options,
                correct_answer: row.correct_answer,
                audio_url: row.audio_url,
                order_number: row.question_order,
                marks: row.marks
            });
        }
    });
    return test;
};

/**
 * UPDATE & DELETE OPERATIONS
 */

export const updateTestHeader = async (id, data) => {
    const { title, is_full_mock } = data;
    const result = await pool.query(
        `UPDATE tests SET title = $1, is_full_mock = $2, updated_at = NOW()
         WHERE id = $3 RETURNING id, title, exam_type, total_time_minutes;`,
        [title, is_full_mock, id]
    );
    return result.rows[0];
};

export const updateQuestionById = async (id, data) => {
    const { question_type, question_text, passage_text, options, correct_answer, audio_url, marks } = data;
    const query = `
        UPDATE questions SET 
            question_type = $1, question_text = $2, passage_text = $3, 
            options = $4, correct_answer = $5, audio_url = $6, marks = $7, updated_at = NOW()
        WHERE id = $8 
        RETURNING *;
    `;
    const result = await pool.query(query, [question_type, question_text, passage_text, JSON.stringify(options), correct_answer, audio_url, marks, id]);
    return result.rows[0];
};

export const deleteTestById = async (id) => {
    const result = await pool.query(`DELETE FROM tests WHERE id = $1 RETURNING title`, [id]);
    return result.rows[0];
};