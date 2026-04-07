import pool from "../config/db.js";

export const createTest = async (testData, client = pool) => {
    const { title, exam_type, is_full_mock, total_time_minutes, created_by } = testData;
    const query = `
    INSERT INTO tests (title, exam_type, is_full_mock, total_time_minutes, created_by)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
`;
    const result = await client.query(query, [title, exam_type, is_full_mock, total_time_minutes, created_by]);
    return result.rows[0];
};

export const createSection = async (sectionData, client = pool) => {
    const { test_id, section_name, time_limit_minutes, order_number, instructions } = sectionData;
    const query = `
    INSERT INTO test_sections (test_id, section_name, time_limit_minutes, order_number, instructions)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
  `;
    const result = await client.query(query, [test_id, section_name, time_limit_minutes, order_number, instructions]);
    return result.rows[0];
};

export const createQuestion = async (questionData, client = pool) => {
    const { section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks } = questionData;
    const query = `
    INSERT INTO questions (section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    RETURNING *;
  `;
    const result = await client.query(query, [
        section_id, question_type, passage_text, question_text,
        JSON.stringify(options), correct_answer, audio_url, order_number, marks
    ]);
    return result.rows[0];
};

export const getAllTests = async (limit, offset) => {
    const result = await pool.query(
        `SELECT * FROM tests ORDER BY created_at DESC LIMIT $1 OFFSET $2`,
        [limit, offset]
    );
    return result.rows;
};

export const deleteTestById = async (id) => {
    const result = await pool.query(`DELETE FROM tests WHERE id = $1 RETURNING id`, [id]);
    return result.rows[0];
};

/**
 * 6. Get Full Test Hierarchy (Test -> Sections -> Questions)
 */
export const getFullTestDetails = async (id) => {
  const testHeader = await pool.query(`SELECT * FROM tests WHERE id = $1`, [id]);
  if (testHeader.rows.length === 0) return null;
  const sections = await pool.query(
    `SELECT * FROM test_sections WHERE test_id = $1 ORDER BY order_number ASC`,
    [id]
  );
  const fullStructure = { ...testHeader.rows[0], sections: [] };
  for (let section of sections.rows) {
    const questions = await pool.query(
      `SELECT * FROM questions WHERE section_id = $1 ORDER BY order_number ASC`,
      [section.id]
    );
    fullStructure.sections.push({
      ...section,
      questions: questions.rows
    });
  }
  return fullStructure;
};

export const updateTest = async (id , updatedData)=> {
  const { title, exam_type, is_full_mock, total_time_minutes } = updatedData;
  const query = `
    UPDATE tests
    SET title = $1, exam_type = $2, is_full_mock = $3, total_time_minutes = $4, updated_at = NOW()
    WHERE id = $5
    RETURNING *;
  `;
  const result = await pool.query(query, [title, exam_type, is_full_mock, total_time_minutes, id]);
  return result.rows[0];
}

export const updateTestHeader = async (id, data) => {
  const { title, is_full_mock, total_time_minutes } = data;
  const result = await pool.query(
    `UPDATE tests
    SET title = $1, is_full_mock = $2, total_time_minutes = $3, updated_at = NOW()
    WHERE id = $4 RETURNING *;`, [title, is_full_mock, total_time_minutes, id]  
  )
  return result.rows[0];
}

export const updateQuestionById = async (id, data) => {
  const { question_type, question_text, passage_text, options, correct_answer, audio_url, marks } = data;
  // Logic: Agar type 'short-answer' ho toh options table mein empty/null jane chahiye
  const processedOptions = (question_type !== 'MCQ') ? null : JSON.stringify(options);
  const result = await pool.query(
    `UPDATE questions SET 
      question_type = $1, question_text = $2, passage_text = $3, 
      options = $4, correct_answer = $5, audio_url = $6, marks = $7 
     WHERE id = $8 RETURNING *`,
    [question_type, question_text, passage_text, processedOptions, correct_answer, audio_url, marks, id]
  );
  return result.rows[0];
};