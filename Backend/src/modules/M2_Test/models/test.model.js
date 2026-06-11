import pool from "../../../config/db.js";

export async function allocDisplayId(client = pool) {
  const { rows } = await client.query(`
    SELECT COALESCE(MAX(SUBSTRING(display_id FROM 4)::int), 0) + 1 AS n
    FROM tests WHERE display_id ~ '^mck[0-9]+$'
  `);
  const n = Number(rows[0]?.n) || 1;
  return `mck${String(n).padStart(3, "0")}`;
}

export async function findSingleModuleConflict(examType, sectionType, excludeTestId, client = pool) {
  const params = [examType, sectionType];
  let sql = `
    SELECT t.id FROM tests t
    INNER JOIN test_sections ts ON ts.test_id = t.id
    WHERE t.test_category != 'full_mock' AND t.exam_type = $1::public.test_type_enum
      AND ts.section_type = $2::public.section_type_enum
  `;
  if (excludeTestId) {
    sql += ` AND t.id <> $3::uuid`;
    params.push(excludeTestId);
  }
  sql += ` LIMIT 1`;
  const { rows } = await client.query(sql, params);
  return rows[0] || null;
}

export async function createTest(testData, client = pool) {
  const {
    display_id,
    title,
    exam_type,
    test_category,
    total_duration,
    created_by,
    difficulty_level = "medium",
    passing_score = 6.5,
    min_required_band = 6.0,
    is_published = false,
    is_premium = false,
  } = testData;
  const { rows } = await client.query(
    `INSERT INTO tests (display_id, title, total_duration, exam_type, test_category, difficulty_level, passing_score, min_required_band, is_published, is_premium, created_by)
     VALUES ($1,$2,$3,$4::public.test_type_enum,$5::public.test_category_enum,$6::public.difficulty_enum,$7,$8,$9,$10,$11)
     RETURNING *`,
    [
      display_id,
      title,
      total_duration,
      exam_type,
      test_category,
      difficulty_level,
      passing_score,
      min_required_band,
      is_published,
      is_premium,
      created_by,
    ],
  );
  return rows[0];
}

export async function updateTestHeader(id, data, client = pool) {
  const {
    title,
    exam_type,
    test_category,
    total_duration,
    difficulty_level,
    passing_score,
    min_required_band,
    is_published,
    is_premium,
  } = data;
  const { rows } = await client.query(
    `UPDATE tests SET
      title = COALESCE($1, title),
      exam_type = COALESCE($2::public.test_type_enum, exam_type),
      test_category = COALESCE($3::public.test_category_enum, test_category),
      total_duration = COALESCE($4, total_duration),
      difficulty_level = COALESCE($5::public.difficulty_enum, difficulty_level),
      passing_score = COALESCE($6, passing_score),
      min_required_band = COALESCE($7, min_required_band),
      is_published = COALESCE($8, is_published),
      is_premium = COALESCE($9, is_premium),
      updated_at = NOW()
    WHERE id = $10::uuid RETURNING *`,
    [
      title ?? null,
      exam_type ?? null,
      test_category ?? null,
      total_duration ?? null,
      difficulty_level ?? null,
      passing_score ?? null,
      min_required_band ?? null,
      is_published ?? null,
      is_premium ?? null,
      id,
    ],
  );
  return rows[0];
}

export async function listAdminMocksDashboard({ search, exam_type, limit, offset }) {
  const params = [];
  let where = "WHERE 1=1";
  if (search) {
    params.push(`%${search}%`);
    where += ` AND title ILIKE $${params.length}`;
  }
  if (exam_type && exam_type !== "All") {
    params.push(exam_type);
    where += ` AND exam_type = $${params.length}::public.test_type_enum`;
  }
  params.push(limit);
  const limitIdx = params.length;
  params.push(offset);
  const offsetIdx = params.length;
  const { rows } = await pool.query(
    `SELECT t.id, t.display_id, t.title, t.exam_type, t.test_category, t.is_published,
            to_char(t.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD') AS created_at,
            t.total_duration, t.difficulty_level, t.min_required_band, t.is_premium,
            (SELECT COUNT(*)::int FROM questions q
              INNER JOIN test_sections ts ON q.section_id = ts.id WHERE ts.test_id = t.id) AS question_count
     FROM tests t
     ${where}
     ORDER BY t.created_at DESC
     LIMIT $${limitIdx} OFFSET $${offsetIdx}`,
    params,
  );
  return rows;
}

export async function listMobilePublished(userId, examTypes) {
  const types = examTypes?.length ? examTypes : ["IELTS", "PTE"];
  const { rows } = await pool.query(
    `SELECT t.id, t.display_id, t.title, t.exam_type, t.test_category, t.difficulty_level,
            t.total_duration, t.min_required_band,
            (SELECT COUNT(*)::int FROM questions q
              INNER JOIN test_sections ts ON q.section_id = ts.id WHERE ts.test_id = t.id) AS total_questions,
            sq.sub_question_types,
            la.overall_band_score AS last_attempt_score,
            la.id AS last_attempt_id,
            la.status AS last_attempt_status
     FROM tests t
     LEFT JOIN LATERAL (
       SELECT COALESCE(array_agg(DISTINCT q.sub_question_type ORDER BY q.sub_question_type)
         FILTER (WHERE q.sub_question_type IS NOT NULL), '{}') AS sub_question_types
       FROM questions q
       INNER JOIN test_sections ts ON q.section_id = ts.id
       WHERE ts.test_id = t.id
     ) sq ON true
     LEFT JOIN LATERAL (
       SELECT id, overall_band_score, status FROM test_attempts
       WHERE user_id = $1::uuid AND test_id = t.id
       ORDER BY created_at DESC NULLS LAST LIMIT 1
     ) la ON true
     WHERE t.is_published = true AND t.exam_type = ANY($2::public.test_type_enum[])
     ORDER BY t.created_at DESC`,
    [userId, types],
  );
  return rows;
}

export async function getAllTests(limit, offset, examType = null) {
  return listAdminMocksDashboard({ search: null, exam_type: examType, limit, offset });
}

export async function listPublishedForCatalog(examTypes) {
  const types = examTypes?.length ? examTypes : ["IELTS", "PTE"];
  const { rows } = await pool.query(
    `SELECT t.id, t.display_id, t.title, t.exam_type, t.test_category, t.difficulty_level,
            t.total_duration, t.min_required_band,
            (SELECT COUNT(*)::int FROM questions q
              INNER JOIN test_sections ts ON q.section_id = ts.id WHERE ts.test_id = t.id) AS total_questions
     FROM tests t
     WHERE t.is_published = true AND t.exam_type = ANY($1::public.test_type_enum[])
     ORDER BY t.created_at DESC`,
    [types],
  );
  return rows;
}

export async function getTestsByFilters(examTypes, allowedSections) {
  const rows = await listPublishedForCatalog(examTypes);
  return rows.map((r) => ({
    ...r,
    allowed_sections: allowedSections || "ALL",
  }));
}

function mapQuestionRow(row, includeCorrect) {
  const q = {
    id: row.question_id,
    question_type: row.question_type,
    sub_question_type: row.sub_question_type,
    passage_text: row.passage_text,
    question_text: row.question_text,
    word_limit_instruction: row.word_limit_instruction,
    options: row.options,
    content: row.content,
    audio_url: row.audio_url,
    image_url: row.image_url,
    order_number: row.question_order,
    marks: row.marks,
    difficulty: row.question_difficulty,
    min_words: row.min_words,
    max_words: row.max_words,
    prep_time_seconds: row.prep_time_seconds,
    record_time_seconds: row.record_time_seconds,
    tags: row.tags,
  };
  if (includeCorrect) {
    q.correct_answer = row.correct_answer;
  }
  return q;
}

export async function getStructuredTest(id, { includeCorrect = false } = {}) {
  const { rows } = await pool.query(
    `SELECT t.id AS test_id, t.display_id, t.title, t.exam_type, t.test_category, t.is_published,
            t.total_duration, t.difficulty_level, t.passing_score, t.min_required_band, t.is_premium,
            ts.id AS section_id, ts.section_name, ts.section_type, ts.sub_type, ts.time_limit_minutes,
            ts.order_number AS section_order, ts.instructions, ts.question_types_allowed, ts.task_count,
            q.id AS question_id, q.question_type, q.sub_question_type, q.passage_text, q.question_text,
            q.word_limit_instruction, q.options, q.correct_answer, q.content, q.audio_url, q.image_url,
            q.order_number AS question_order, q.marks, q.difficulty AS question_difficulty,
            q.min_words, q.max_words, q.prep_time_seconds, q.record_time_seconds, q.tags
     FROM tests t
     LEFT JOIN test_sections ts ON t.id = ts.test_id
     LEFT JOIN questions q ON ts.id = q.section_id
     WHERE t.id = $1::uuid
     ORDER BY ts.order_number ASC NULLS LAST, q.order_number ASC NULLS LAST`,
    [id],
  );
  if (!rows.length) return null;
  const head = rows[0];
  const test = {
    id: head.test_id,
    display_id: head.display_id,
    title: head.title,
    exam_type: head.exam_type,
    test_category: head.test_category,
    is_published: head.is_published,
    total_duration: head.total_duration,
    global_time_limit_minutes: head.total_duration,
    difficulty_level: head.difficulty_level,
    passing_score: head.passing_score,
    min_required_band: head.min_required_band,
    is_premium: head.is_premium,
    sections: [],
  };
  const sectionMap = new Map();
  for (const row of rows) {
    if (!row.section_id) continue;
    if (!sectionMap.has(row.section_id)) {
      const sec = {
        id: row.section_id,
        section_name: row.section_name,
        section_type: row.section_type,
        sub_type: row.sub_type,
        time_limit_minutes: row.time_limit_minutes,
        order_number: row.section_order,
        instructions: row.instructions,
        question_types_allowed: row.question_types_allowed,
        task_count: row.task_count,
        questions: [],
      };
      sectionMap.set(row.section_id, sec);
      test.sections.push(sec);
    }
    if (row.question_id) {
      sectionMap.get(row.section_id).questions.push(mapQuestionRow(row, includeCorrect));
    }
  }
  return test;
}

export async function getFullTestDetails(id) {
  return getStructuredTest(id, { includeCorrect: true });
}

export async function getRuntimeTest(id) {
  return getStructuredTest(id, { includeCorrect: false });
}

export async function getPreviewPayload(id) {
  const t = await getStructuredTest(id, { includeCorrect: false });
  if (!t) return null;
  return {
    id: t.id,
    display_id: t.display_id,
    title: t.title,
    exam_type: t.exam_type,
    test_category: t.test_category,
    is_published: t.is_published,
    total_duration: t.total_duration,
    min_required_band: t.min_required_band,
    difficulty_level: t.difficulty_level,
    sections: t.sections.map((s) => ({
      id: s.id,
      section_name: s.section_name,
      section_type: s.section_type,
      sub_type: s.sub_type,
      time_limit_minutes: s.time_limit_minutes,
      order_number: s.order_number,
      instructions: s.instructions,
      question_types_allowed: s.question_types_allowed,
      task_count: s.task_count,
      question_count: s.questions.length,
      layout_summary: {
        has_audio: s.questions.some((q) => q.audio_url),
        has_image: s.questions.some((q) => q.image_url),
        has_passage: s.questions.some((q) => q.passage_text),
        sub_types: [...new Set(s.questions.map((q) => q.sub_question_type).filter(Boolean))],
      },
    })),
  };
}

export async function createSection(sectionData, client = pool) {
  const {
    test_id,
    section_name,
    section_type,
    sub_type,
    time_limit_minutes,
    order_number,
    instructions,
    question_types_allowed,
    task_count,
  } = sectionData;
  const { rows } = await client.query(
    `INSERT INTO test_sections (test_id, section_name, section_type, sub_type, time_limit_minutes, order_number, instructions, question_types_allowed, task_count)
     VALUES ($1,$2,$3::public.section_type_enum,$4,$5,$6,$7,$8::jsonb,$9) RETURNING *`,
    [
      test_id,
      section_name,
      section_type,
      sub_type ?? null,
      time_limit_minutes,
      order_number,
      instructions ?? null,
      JSON.stringify(question_types_allowed ?? []),
      task_count ?? 1,
    ],
  );
  return rows[0];
}

export async function updateSection(sectionId, data, client = pool) {
  const {
    section_name,
    section_type,
    sub_type,
    time_limit_minutes,
    order_number,
    instructions,
    question_types_allowed,
    task_count,
  } = data;
  const { rows } = await client.query(
    `UPDATE test_sections SET
      section_name = COALESCE($1, section_name),
      section_type = COALESCE($2::public.section_type_enum, section_type),
      sub_type = COALESCE($3, sub_type),
      time_limit_minutes = COALESCE($4, time_limit_minutes),
      order_number = COALESCE($5, order_number),
      instructions = COALESCE($6, instructions),
      question_types_allowed = COALESCE($7::jsonb, question_types_allowed),
      task_count = COALESCE($8, task_count)
    WHERE id = $9::uuid RETURNING *`,
    [
      section_name ?? null,
      section_type ?? null,
      sub_type ?? null,
      time_limit_minutes ?? null,
      order_number ?? null,
      instructions ?? null,
      question_types_allowed != null ? JSON.stringify(question_types_allowed) : null,
      task_count ?? null,
      sectionId,
    ],
  );
  return rows[0];
}

export async function deleteSectionsNotIn(testId, keepIds, client = pool) {
  if (!keepIds.length) {
    await client.query(`DELETE FROM test_sections WHERE test_id = $1::uuid`, [testId]);
    return;
  }
  await client.query(
    `DELETE FROM test_sections WHERE test_id = $1::uuid AND id <> ALL($2::uuid[])`,
    [testId, keepIds],
  );
}

export async function deleteQuestionsNotIn(sectionId, keepIds, client = pool) {
  if (!keepIds.length) {
    await client.query(`DELETE FROM questions WHERE section_id = $1::uuid`, [sectionId]);
    return;
  }
  await client.query(
    `DELETE FROM questions WHERE section_id = $1::uuid AND id <> ALL($2::uuid[])`,
    [sectionId, keepIds],
  );
}

export async function createSingleQuestion(q, client = pool) {
  const { rows } = await client.query(
    `INSERT INTO questions (
      section_id, question_type, sub_question_type, passage_text, question_text, word_limit_instruction,
      options, correct_answer, content, audio_url, image_url, order_number, marks, difficulty,
      min_words, max_words, prep_time_seconds, record_time_seconds, tags
    ) VALUES (
      $1::uuid,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9::jsonb,$10,$11,$12,$13,$14::public.difficulty_enum,$15,$16,$17,$18,$19::jsonb
    ) RETURNING *`,
    [
      q.section_id,
      q.question_type,
      q.sub_question_type ?? null,
      q.passage_text ?? null,
      q.question_text,
      q.word_limit_instruction ?? null,
      JSON.stringify(q.options ?? []),
      JSON.stringify(q.correct_answer ?? {}),
      JSON.stringify(q.content ?? {}),
      q.audio_url ?? null,
      q.image_url ?? null,
      q.order_number,
      q.marks ?? 1,
      q.difficulty || "medium",
      q.min_words ?? 0,
      q.max_words ?? 0,
      q.prep_time_seconds ?? 0,
      q.record_time_seconds ?? 0,
      JSON.stringify(q.tags ?? []),
    ],
  );
  return rows[0];
}

export async function updateQuestion(id, data, client = pool) {
  const cur = await client.query(`SELECT * FROM questions WHERE id = $1::uuid`, [id]);
  if (!cur.rows[0]) return null;
  const c = cur.rows[0];
  const merged = {
    question_type: data.question_type ?? c.question_type,
    sub_question_type: data.sub_question_type ?? c.sub_question_type,
    passage_text: data.passage_text !== undefined ? data.passage_text : c.passage_text,
    question_text: data.question_text ?? c.question_text,
    word_limit_instruction:
      data.word_limit_instruction !== undefined ? data.word_limit_instruction : c.word_limit_instruction,
    options: data.options !== undefined ? data.options : c.options,
    correct_answer: data.correct_answer !== undefined ? data.correct_answer : c.correct_answer,
    content: data.content !== undefined ? data.content : c.content,
    audio_url: data.audio_url !== undefined ? data.audio_url : c.audio_url,
    image_url: data.image_url !== undefined ? data.image_url : c.image_url,
    order_number: data.order_number ?? c.order_number,
    marks: data.marks ?? c.marks,
    difficulty: data.difficulty ?? c.difficulty,
    min_words: data.min_words ?? c.min_words,
    max_words: data.max_words ?? c.max_words,
    prep_time_seconds: data.prep_time_seconds ?? c.prep_time_seconds,
    record_time_seconds: data.record_time_seconds ?? c.record_time_seconds,
    tags: data.tags !== undefined ? data.tags : c.tags,
  };
  const { rows } = await client.query(
    `UPDATE questions SET
      question_type = $1, sub_question_type = $2, passage_text = $3, question_text = $4, word_limit_instruction = $5,
      options = $6::jsonb, correct_answer = $7::jsonb, content = $8::jsonb, audio_url = $9, image_url = $10,
      order_number = $11, marks = $12, difficulty = $13::public.difficulty_enum, min_words = $14, max_words = $15,
      prep_time_seconds = $16, record_time_seconds = $17, tags = $18::jsonb
    WHERE id = $19::uuid RETURNING *`,
    [
      merged.question_type,
      merged.sub_question_type,
      merged.passage_text,
      merged.question_text,
      merged.word_limit_instruction,
      typeof merged.options === "string" ? merged.options : JSON.stringify(merged.options ?? []),
      typeof merged.correct_answer === "string" ? merged.correct_answer : JSON.stringify(merged.correct_answer ?? {}),
      typeof merged.content === "string" ? merged.content : JSON.stringify(merged.content ?? {}),
      merged.audio_url,
      merged.image_url,
      merged.order_number,
      merged.marks,
      merged.difficulty,
      merged.min_words,
      merged.max_words,
      merged.prep_time_seconds,
      merged.record_time_seconds,
      typeof merged.tags === "string" ? merged.tags : JSON.stringify(merged.tags ?? []),
      id,
    ],
  );
  return rows[0];
}

export async function getQuestionById(id, client = pool) {
  const { rows } = await client.query(`SELECT * FROM questions WHERE id = $1::uuid`, [id]);
  return rows[0] || null;
}

export async function deleteQuestion(id, client = pool) {
  const { rows } = await client.query(`DELETE FROM questions WHERE id = $1::uuid RETURNING id`, [id]);
  return rows[0] || null;
}

export async function deleteTest(id, client = pool) {
  const { rows } = await client.query(`DELETE FROM tests WHERE id = $1::uuid RETURNING id`, [id]);
  return rows[0] || null;
}

export async function validateFullMockSections(sections) {
  const types = new Set((sections || []).map((s) => s.section_type).filter(Boolean));
  for (const req of ["reading", "listening", "writing", "speaking"]) {
    if (!types.has(req)) return `full_mock requires section_type ${req}`;
  }
  return null;
}