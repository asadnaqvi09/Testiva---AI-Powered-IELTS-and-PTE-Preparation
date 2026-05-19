import pool from "../../config/db.js";
import bcrypt from "bcrypt";

const USER_FIELDS = `id,full_name,email,bio,avatar_url,role,subscription,preference,auth_provider,is_email_verified,token_version,last_login_at,created_at,updated_at`;

export const findUserByEmail = async (email) => {
  const result = await pool.query(
    `SELECT ${USER_FIELDS}, password_hash FROM users WHERE email=$1`,
    [email]
  );
  return result.rows[0] || null;
};

export const findUserById = async (id) => {
  const result = await pool.query(
    `SELECT ${USER_FIELDS} FROM users WHERE id=$1`,
    [id]
  );
  return result.rows[0] || null;
};

export const createUser = async ({
  full_name,
  email,
  password_hash,
  auth_provider = "email",
  is_email_verified = true,
  subscription = "free",
  preference = null
}) => {
  const result = await pool.query(
    `INSERT INTO users (
      full_name,
      email,
      password_hash,
      auth_provider,
      is_email_verified,
      subscription,
      preference
     )
     VALUES ($1,$2,$3,$4,$5,$6,$7)
     RETURNING ${USER_FIELDS}`,
    [
      full_name,
      email,
      password_hash,
      auth_provider,
      is_email_verified,
      subscription,
      preference
    ]
  );
  return result.rows[0];
};

export const updateUserPreference = async (id, preference) => {
  const result = await pool.query(
    `UPDATE users SET preference=$1,updated_at=NOW()
     WHERE id=$2
     RETURNING ${USER_FIELDS}`,
    [preference, id]
  );
  return result.rows[0] || null;
};

export const getUserPreference = async (id) => {
  const result = await pool.query(
    `SELECT id,preference,subscription FROM users WHERE id=$1`,
    [id]
  );
  return result.rows[0] || null;
};

export const updateUserProfile = async (id, { full_name, bio }) => {
  const result = await pool.query(
    `UPDATE users SET full_name=$1,bio=$2,updated_at=NOW()
     WHERE id=$3
     RETURNING ${USER_FIELDS}`,
    [full_name, bio, id]
  );
  return result.rows[0] || null;
};

export const updateUserPassword = async (id, data) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const user = await client.query(
      `SELECT password_hash FROM users WHERE id=$1 FOR UPDATE`,
      [id]
    );
    if (!user.rows[0]) throw new Error("User not found");
    const valid = await bcrypt.compare(
      data.current_password,
      user.rows[0].password_hash
    );
    if (!valid) throw new Error("Current password is incorrect");
    const hash = await bcrypt.hash(
      data.new_password,
      Number(12)
    );
    const result = await client.query(
      `UPDATE users SET password_hash=$1,token_version=token_version+1,updated_at=NOW()
       WHERE id=$2
       RETURNING ${USER_FIELDS}`,
      [hash, id]
    );
    await client.query("COMMIT");
    return result.rows[0];
  } catch (e) {
    await client.query("ROLLBACK");
    throw e;
  } finally {
    client.release();
  }
};

export const uploadUserAvatar = async (id, avatar_url) => {
  const result = await pool.query(
    `UPDATE users SET avatar_url=$1,updated_at=NOW()
     WHERE id=$2
     RETURNING ${USER_FIELDS}`,
    [avatar_url, id]
  );
  return result.rows[0] || null;
};

export const updateUserSubscriptionStatus = async (id, subscription) => {
  const result = await pool.query(
    `UPDATE users SET subscription=$2,updated_at=NOW()
     WHERE id=$1
     RETURNING ${USER_FIELDS}`,
    [id, subscription]
  );
  return result.rows[0] || null;
};

export const createGoogleUser = async (data) => {
  const { email, full_name, avatar_url, subscription = "free", preference = null } = data;
  const result = await pool.query(
    `INSERT INTO users (email, full_name, avatar_url, auth_provider, subscription, is_email_verified, preference)
     VALUES ($1, $2, $3, 'google', $4, true, $5)
     RETURNING ${USER_FIELDS}`,
    [email, full_name, avatar_url, subscription, preference]
  );
  return result.rows[0];
};

export const getAdminStats = async () => {
  const result = await pool.query(
    `SELECT 
      COUNT(*) AS total_users,
      COUNT(*) FILTER (WHERE subscription='free') AS free_users,
      COUNT(*) FILTER (WHERE subscription='basic') AS basic_users,
      COUNT(*) FILTER (WHERE subscription='premium') AS premium_users,
      COUNT(*) FILTER (WHERE last_login_at >= NOW() - INTERVAL '7 days') AS active_users
     FROM users`
  );
  return result.rows[0];
};

export const fetchAllUsers = async (limit, offset, search = "", subscription = "", preference = "") => {
  let query = `
    SELECT 
      'USR-' || LPAD(ROW_NUMBER() OVER(ORDER BY created_at ASC)::text, 3, '0') AS dynamic_id,
      id, full_name, email, role, subscription, preference, last_login_at, created_at 
    FROM users 
    WHERE 1=1
  `;
  const params = [];
  let paramIndex = 1;
  if (search) {
    query += ` AND (full_name ILIKE $${paramIndex} OR email ILIKE $${paramIndex})`;
    params.push(`%${search}%`);
    paramIndex++;
  }
  if (subscription && subscription.toLowerCase() !== "all") {
    query += ` AND subscription = $${paramIndex}`;
    params.push(subscription.toLowerCase());
    paramIndex++;
  }
  if (preference && preference.toLowerCase() !== "all") {
    query += ` AND preference = $${paramIndex}`;
    params.push(preference.toUpperCase());
    paramIndex++;
  }
  let mainQuery = `SELECT * FROM (${query}) AS sub_query ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
  params.push(limit, offset);
  const result = await pool.query(mainQuery, params);
  return result.rows;
};

export const incrementTokenVersion = async (id) => {
  const result = await pool.query(
    `UPDATE users SET token_version=token_version+1,updated_at=NOW()
     WHERE id=$1 RETURNING token_version`,
    [id]
  );
  return result.rows[0] || null;
};

export const saveRefreshToken = async (userId, token, expiresAt) => {
  await pool.query(
    `INSERT INTO refresh_tokens (user_id,token,expires_at)
     VALUES ($1,$2,$3)`,
    [userId, token, expiresAt]
  );
};

export const findRefreshToken = async (token) => {
  const result = await pool.query(
    `SELECT * FROM refresh_tokens WHERE token=$1`,
    [token]
  );
  return result.rows[0] || null;
};

export const deleteRefreshToken = async (token) => {
  await pool.query(
    `DELETE FROM refresh_tokens WHERE token=$1`,
    [token]
  );
};

export const deleteAllUserTokens = async (userId) => {
  await pool.query(
    `DELETE FROM refresh_tokens WHERE user_id=$1`,
    [userId]
  );
};

export const updateUserFcmToken = async (id, fcm_token) => {
  const result = await pool.query(
    `UPDATE users SET fcm_token=$1, updated_at=NOW()
     WHERE id=$2
     RETURNING id, fcm_token, updated_at`,
    [fcm_token, id]
  );
  if (result.rowCount === 0) throw new Error("User not found");
  return result.rows[0];
};

export const getUserHistoricalResults = async (userId) => {
  const result = await pool.query(
    `SELECT ta.id AS attempt_id, ta.test_id, t.title AS test_title, t.exam_type,
            ta.overall_band_score, ta.reading_score, ta.listening_score, 
            ta.writing_score, ta.speaking_score, ta.feedback, ta.status, 
            ta.created_at, ta.client_completed_at,
            af.task_response_score, af.coherence_cohesion_score, 
            af.lexical_resource_score, af.grammatical_range_score,
            af.detailed_analysis, af.improvement_suggestions
     FROM test_attempts ta
     JOIN tests t ON ta.test_id = t.id
     LEFT JOIN ai_feedback af ON ta.id = af.attempt_id
     WHERE ta.user_id = $1::uuid
     ORDER BY ta.created_at DESC`,
    [userId]
  );
  return result.rows;
};
