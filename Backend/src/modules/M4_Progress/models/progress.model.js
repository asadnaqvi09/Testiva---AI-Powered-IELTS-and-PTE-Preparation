import pool from "../../../config/db.js";

export const startNewAttempt = async (data, client = pool) => {
  const { user_id, test_id, client_started_at, is_offline = false } = data;
  const dbClient = client === pool ? await pool.connect() : client;
  try {
    if (client === pool) await dbClient.query("BEGIN");
    const existing = await dbClient.query(
      `SELECT id FROM test_attempts WHERE user_id = $1::uuid AND test_id = $2::uuid AND status = 'in_progress' LIMIT 1`,
      [user_id, test_id],
    );
    if (existing.rows.length > 0) {
      if (client === pool) await dbClient.query("ROLLBACK");
      throw new Error("Test already in progress. Resume or abandon existing attempt.");
    }
    const result = await dbClient.query(
      `INSERT INTO test_attempts (user_id, test_id, client_started_at, is_offline, status, sync_status)
       VALUES ($1::uuid,$2::uuid,$3,$4,'in_progress','pending')
       RETURNING id, user_id, test_id, status, client_started_at, is_offline, created_at`,
      [user_id, test_id, client_started_at, is_offline],
    );
    if (client === pool) await dbClient.query("COMMIT");
    return result.rows[0];
  } catch (error) {
    if (client === pool) await dbClient.query("ROLLBACK");
    throw error;
  } finally {
    if (client === pool) dbClient.release();
  }
};

const normalize = (v) => {
  if (v === null || v === undefined) return "";
  if (typeof v === "string") return v.trim().toLowerCase();
  if (typeof v === "object") return JSON.stringify(v);
  if (Array.isArray(v)) return v.map((x) => String(x).toLowerCase().trim()).sort().join(",");
  return String(v).toLowerCase().trim();
};

const scoreObjective = (question, user_answer) => {
  let is_correct = false;
  let marks_obtained = 0;
  const qType = (question.question_type || "").toLowerCase();
  const sub = (question.sub_question_type || "").toLowerCase();
  if (
    ["mcq", "multi_select", "true_false", "yes_no", "tf_not_given", "yn_not_given"].includes(qType) ||
    ["mcq", "multi_select", "tf_not_given", "yn_not_given"].includes(sub)
  ) {
    if (normalize(user_answer) === normalize(question.correct_answer)) {
      is_correct = true;
      marks_obtained = Number(question.marks) || 0;
    }
  } else if (
    ["fill_blank", "short_answer", "match_the_column", "matching", "sentence_completion", "form_fill"].includes(qType) ||
    ["short_answer", "matching", "sentence_completion", "form_fill"].includes(sub)
  ) {
    const raw = question.correct_answer;
    const acceptable = Array.isArray(raw)
      ? raw.map((a) => normalize(a))
      : String(raw)
          .split(/[|/]/)
          .map((a) => normalize(a));
    if (acceptable.includes(normalize(user_answer))) {
      is_correct = true;
      marks_obtained = Number(question.marks) || 0;
    }
  }
  return { is_correct, marks_obtained };
};

export const saveUserResponse = async (data, client = pool) => {
  const {
    attempt_id,
    question_id,
    user_answer,
    audio_response_url,
    time_spent_seconds = 0,
    word_count = 0,
    client_created_at,
  } = data;
  const dbClient = client === pool ? await pool.connect() : client;
  try {
    if (client === pool) await dbClient.query("BEGIN");
    const qResult = await dbClient.query(
      `SELECT correct_answer, marks, question_type, sub_question_type FROM questions WHERE id = $1::uuid FOR SHARE`,
      [question_id],
    );
    if (qResult.rows.length === 0) throw new Error("Question not found");
    const question = qResult.rows[0];
    const { is_correct, marks_obtained } = scoreObjective(question, user_answer);
    await dbClient.query(`DELETE FROM user_responses WHERE attempt_id = $1::uuid AND question_id = $2::uuid`, [
      attempt_id,
      question_id,
    ]);
    const result = await dbClient.query(
      `INSERT INTO user_responses (attempt_id, question_id, user_answer, audio_response_url, is_correct, marks_obtained, word_count, time_spent_seconds, client_created_at)
       VALUES ($1::uuid,$2::uuid,$3::jsonb,$4,$5,$6,$7,$8,$9)
       RETURNING id, attempt_id, is_correct, marks_obtained`,
      [
        attempt_id,
        question_id,
        user_answer === undefined || user_answer === null ? null : JSON.stringify(user_answer),
        audio_response_url ?? null,
        is_correct,
        marks_obtained,
        word_count,
        time_spent_seconds,
        client_created_at,
      ],
    );
    if (client === pool) await dbClient.query("COMMIT");
    return result.rows[0];
  } catch (error) {
    if (client === pool) await dbClient.query("ROLLBACK");
    throw error;
  } finally {
    if (client === pool) dbClient.release();
  }
};

export const finalizeAttempt = async (id, data, client = pool) => {
  const {
    overall_band_score,
    reading_score,
    listening_score,
    writing_score,
    speaking_score,
    feedback,
    client_completed_at,
    status = "completed",
    sync_status,
  } = data;
  const dbClient = client === pool ? await pool.connect() : client;
  try {
    if (client === pool) await dbClient.query("BEGIN");
    const result = await dbClient.query(
      `UPDATE test_attempts SET
        overall_band_score = COALESCE($1, overall_band_score),
        reading_score = COALESCE($2, reading_score),
        listening_score = COALESCE($3, listening_score),
        writing_score = COALESCE($4, writing_score),
        speaking_score = COALESCE($5, speaking_score),
        feedback = COALESCE($6, feedback),
        client_completed_at = COALESCE($7, client_completed_at),
        status = COALESCE($8::attempt_status_enum, status),
        sync_status = COALESCE($9, sync_status),
        server_synced_at = NOW(),
        updated_at = NOW()
      WHERE id = $10::uuid
      RETURNING id, user_id, status`,
      [
        overall_band_score ?? null,
        reading_score ?? null,
        listening_score ?? null,
        writing_score ?? null,
        speaking_score ?? null,
        feedback ?? null,
        client_completed_at ?? null,
        status,
        sync_status ?? null,
        id,
      ],
    );
    if (result.rows.length === 0) throw new Error("Attempt not found");
    const attempt = result.rows[0];
    await updateUserStats(attempt.user_id, dbClient);
    if (client === pool) await dbClient.query("COMMIT");
    return attempt;
  } catch (error) {
    if (client === pool) await dbClient.query("ROLLBACK");
    throw error;
  } finally {
    if (client === pool) dbClient.release();
  }
};

export const updateUserStats = async (userId, client = pool) => {
  const result = await client.query(
    `INSERT INTO user_progress_stats (user_id, total_tests_taken, average_band_score, highest_score, last_test_date)
     SELECT user_id, COUNT(id)::int, AVG(overall_band_score), MAX(overall_band_score), MAX(created_at)
     FROM test_attempts
     WHERE user_id = $1::uuid AND status = 'completed'
     GROUP BY user_id
     ON CONFLICT (user_id) DO UPDATE SET
       total_tests_taken = EXCLUDED.total_tests_taken,
       average_band_score = EXCLUDED.average_band_score,
       highest_score = EXCLUDED.highest_score,
       last_test_date = EXCLUDED.last_test_date,
       updated_at = NOW()
     RETURNING user_id, total_tests_taken, average_band_score, highest_score, last_test_date, updated_at`,
    [userId],
  );
  return result.rows[0] || null;
};

export const getUserStats = async (userId) => {
  const result = await pool.query(
    `SELECT user_id, total_tests_taken, average_band_score, highest_score, last_test_date, updated_at
     FROM user_progress_stats WHERE user_id = $1::uuid`,
    [userId],
  );
  return result.rows[0] || null;
};

export const getAttemptById = async (id) => {
  const result = await pool.query(
    `SELECT id, user_id, test_id, overall_band_score, writing_score, reading_score, listening_score, speaking_score, feedback, status, client_started_at, client_completed_at, is_offline, created_at
     FROM test_attempts WHERE id = $1::uuid`,
    [id],
  );
  return result.rows[0];
};

export const getAttemptResponses = async (attemptId) => {
  const result = await pool.query(
    `SELECT ur.id, ur.attempt_id, ur.question_id, ur.user_answer, ur.audio_response_url, ur.is_correct, ur.marks_obtained,
            ur.word_count, ur.time_spent_seconds, ur.ai_feedback_per_question, ur.client_created_at,
            q.question_text, q.question_type, q.sub_question_type, q.correct_answer, q.marks AS total_marks, q.order_number, q.word_limit_instruction
     FROM user_responses ur
     JOIN questions q ON ur.question_id = q.id
     WHERE ur.attempt_id = $1::uuid
     ORDER BY q.order_number`,
    [attemptId],
  );
  return result.rows;
};

export const updateAttemptScores = async (id, scores) => {
  const {
    overall_band_score,
    writing_score,
    reading_score,
    listening_score,
    speaking_score,
    feedback,
    status = "completed",
  } = scores;
  const result = await pool.query(
    `UPDATE test_attempts SET
      overall_band_score = COALESCE($1, overall_band_score),
      writing_score = COALESCE($2, writing_score),
      reading_score = COALESCE($3, reading_score),
      listening_score = COALESCE($4, listening_score),
      speaking_score = COALESCE($5, speaking_score),
      feedback = COALESCE($6, feedback),
      status = COALESCE($7::attempt_status_enum, status),
      updated_at = NOW()
    WHERE id = $8::uuid
    RETURNING id, overall_band_score, writing_score, reading_score, listening_score, speaking_score, status, updated_at`,
    [overall_band_score, writing_score, reading_score, listening_score, speaking_score, feedback, status, id],
  );
  return result.rows[0];
};

export const updateResponseAiFeedback = async (attemptId, questionId, text, client = pool) => {
  const { rows } = await client.query(
    `UPDATE user_responses SET ai_feedback_per_question = $1 WHERE attempt_id = $2::uuid AND question_id = $3::uuid RETURNING id`,
    [text, attemptId, questionId],
  );
  return rows[0] || null;
};

export const getFullAttemptDetail = async (attemptId) => {
  const result = await pool.query(
    `SELECT ta.*, t.title AS test_title, t.exam_type AS test_type,
            af.task_response_score, af.coherence_cohesion_score, af.lexical_resource_score, af.grammatical_range_score,
            af.detailed_analysis, af.improvement_suggestions
     FROM test_attempts ta
     JOIN tests t ON ta.test_id = t.id
     LEFT JOIN ai_feedback af ON ta.id = af.attempt_id
     WHERE ta.id = $1::uuid`,
    [attemptId],
  );
  return result.rows[0];
};
