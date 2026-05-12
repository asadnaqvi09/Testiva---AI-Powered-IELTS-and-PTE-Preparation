import pool from '../../../config/db.js';

export const createTest = async (testData, client = pool) => {
    const { title, exam_type, test_category, total_duration, created_by, difficulty_level, passing_score, is_published = false, is_premium = false } = testData;
    const result = await client.query(`
        INSERT INTO public.tests 
        (title, exam_type, test_category, total_duration, created_by, difficulty_level, passing_score, is_published, is_premium)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING *;
    `, [title, exam_type, test_category, total_duration, created_by, difficulty_level, passing_score, is_published, is_premium]);
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

export const getTestsByFilters = async (examTypes, allowedSections) => {
    const result = await pool.query(
        `SELECT id, title, exam_type, test_category, difficulty_level, total_duration, created_at 
         FROM tests 
         WHERE exam_type = ANY($1) AND is_published = true
         ORDER BY created_at DESC`,
        [examTypes]
    );
    return result.rows.map(test => ({
        ...test,
        allowed_sections: allowedSections || 'ALL'
    }));
};

export const updateTestHeader = async (id, data) => {
    const { title, test_category, passing_score, difficulty_level, is_published, total_duration } = data;
    const result = await pool.query(`
        UPDATE public.tests 
        SET 
            title = COALESCE($1, title),
            test_category = COALESCE($2, test_category),
            passing_score = COALESCE($3, passing_score),
            difficulty_level = COALESCE($4, difficulty_level),
            is_published = COALESCE($5, is_published),
            total_duration = COALESCE($6, total_duration),
            updated_at = NOW() 
        WHERE id = $7 
        RETURNING *;
    `, [title, test_category, passing_score, difficulty_level, is_published, total_duration, id]);
    return result.rows[0];
};

export const updateQuestion = async (id, data) => {
    const { question_type, question_text, passage_text, options, correct_answer, audio_url, image_url, marks, difficulty } = data;
    const result = await pool.query(`
        UPDATE questions 
        SET question_type = COALESCE($1, question_type),
            question_text = COALESCE($2, question_text),
            passage_text = COALESCE($3, passage_text),
            options = COALESCE($4, options),
            correct_answer = COALESCE($5, correct_answer),
            audio_url = COALESCE($6, audio_url),
            image_url = COALESCE($7, image_url),
            marks = COALESCE($8, marks),
            difficulty = COALESCE($9, difficulty),
            updated_at = NOW()
        WHERE id = $10 
        RETURNING *;
    `, [question_type, question_text, passage_text, 
        options ? JSON.stringify(options) : null, 
        correct_answer, audio_url, image_url, marks, difficulty, id]);

    return result.rows[0];
};

export const updateTestDuration = async (testId, totalMinutes, client = pool) => {
    const result = await client.query(`
        UPDATE tests 
        SET total_time_minutes = $1, updated_at = NOW()
        WHERE id = $2 
        RETURNING total_time_minutes;
    `, [totalMinutes, testId]);
    return result.rows[0];
};

export const createSection = async (sectionData, client = pool) => {
    const { 
        test_id, section_name, time_limit_minutes, order_number, 
        instructions, question_types_allowed, task_count, section_type 
    } = sectionData;
    const result = await client.query(`
        INSERT INTO public.test_sections 
        (test_id, section_name, time_limit_minutes, order_number, instructions, question_types_allowed, task_count, section_type)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
        RETURNING *;
    `, [test_id, section_name, time_limit_minutes, order_number, instructions, JSON.stringify(question_types_allowed || []), task_count, section_type]);
    return result.rows[0];
};

export const createSingleQuestion = async (q, client = pool) => {
    const result = await client.query(`
        INSERT INTO public.questions 
        (section_id, question_type, passage_text, question_text, options, correct_answer, 
         audio_url, image_url, order_number, marks, difficulty, content, tags)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) 
        RETURNING *;
    `, [
        q.section_id, q.question_type, q.passage_text, q.question_text, 
        JSON.stringify(q.options || []), JSON.stringify(q.correct_answer || {}), 
        q.audio_url, q.image_url, q.order_number, q.marks, 
        q.difficulty || 'medium', JSON.stringify(q.content || {}), JSON.stringify(q.tags || [])
    ]);
    return result.rows[0];
};

export const createQuestionsBatch = async (questionsArray, client = pool) => {
    if (questionsArray.length === 0) return [];
    
    const placeholders = questionsArray.map((_, i) => 
        `($${i*11 + 1}, $${i*11 + 2}, $${i*11 + 3}, $${i*11 + 4}, $${i*11 + 5}, 
          $${i*11 + 6}, $${i*11 + 7}, $${i*11 + 8}, $${i*11 + 9}, $${i*11 + 10}, $${i*11 + 11})`
    ).join(', ');

    const flatValues = questionsArray.flatMap(q => [
        q.section_id,
        q.question_type,
        q.passage_text,
        q.question_text,
        q.options ? JSON.stringify(q.options) : null,
        q.correct_answer,
        q.audio_url,
        q.image_url,
        q.order_number,
        q.marks,
        q.difficulty || 'medium'
    ]);

    const result = await client.query(`
        INSERT INTO questions 
        (section_id, question_type, passage_text, question_text, options, correct_answer, 
         audio_url, image_url, order_number, marks, difficulty)
        VALUES ${placeholders} 
        RETURNING id, section_id, question_type, question_text;
    `, flatValues);

    return result.rows;
};

export const getFullTestDetails = async (id) => {
    const result = await pool.query(`
        SELECT 
            t.id as test_id, t.title, t.exam_type, t.test_category, t.is_published, 
            t.total_duration, t.difficulty_level, t.passing_score,
            ts.id as section_id, ts.section_name, ts.time_limit_minutes, 
            ts.order_number as section_order, ts.instructions, ts.section_type,
            ts.question_types_allowed, ts.task_count,
            q.id as question_id, q.question_type, q.passage_text, q.question_text, 
            q.options, q.correct_answer, q.audio_url, q.image_url, q.content,
            q.order_number as question_order, q.marks, q.difficulty as question_difficulty
        FROM public.tests t 
        LEFT JOIN public.test_sections ts ON t.id = ts.test_id 
        LEFT JOIN public.questions q ON ts.id = q.section_id
        WHERE t.id = $1 
        ORDER BY ts.order_number ASC, q.order_number ASC;
    `, [id]);
    if (result.rows.length === 0) return null;
    const test = {
        id: result.rows[0].test_id,
        title: result.rows[0].title,
        exam_type: result.rows[0].exam_type,
        test_category: result.rows[0].test_category,
        total_duration: result.rows[0].total_duration,
        difficulty_level: result.rows[0].difficulty_level,
        passing_score: result.rows[0].passing_score,
        sections: []
    };
    const sectionMap = new Map();
    result.rows.forEach(row => {
        if (!row.section_id) return;
        if (!sectionMap.has(row.section_id)) {
            const section = {
                id: row.section_id,
                name: row.section_name,
                type: row.section_type,
                duration: row.time_limit_minutes,
                order: row.section_order,
                instructions: row.instructions,
                allowed_types: row.question_types_allowed,
                questions: []
            };
            sectionMap.set(row.section_id, section);
            test.sections.push(section);
        }
        if (row.question_id) {
            sectionMap.get(row.section_id).questions.push({
                id: row.question_id,
                type: row.question_type,
                passage: row.passage_text,
                text: row.question_text,
                options: row.options,
                correct_answer: row.correct_answer,
                audio: row.audio_url,
                image: row.image_url,
                content: row.content,
                order: row.question_order,
                marks: row.marks
            });
        }
    });
    return test;
};

export const deleteTest = async (id) => {
    const result = await pool.query(`DELETE FROM public.tests WHERE id = $1 RETURNING title`, [id]);
    return result.rows[0];
};