import pool from "../config/db.js";
import bcrypt from "bcrypt";

export const findUserByEmail = async (email) => {
  const result = await pool.query(
    "SELECT id, full_name, email, role, subscription, password_hash, auth_provider, is_email_verified, token_version FROM users WHERE email=$1",
    [email]
  );
  return result.rows[0];
};

export const createUser = async (userData) => {
  const { full_name, email, password_hash, auth_provider = "email", is_email_verified = false } = userData;
  const result = await pool.query(
    `INSERT INTO users (full_name, email, password_hash, auth_provider, is_email_verified)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, full_name, email, role, subscription, auth_provider, created_at`,
    [full_name, email, password_hash, auth_provider, is_email_verified]
  );
  return result.rows[0];
};

export const findUserById = async (id) => {
  const result = await pool.query(
    `SELECT id, full_name, email, bio, avatar_url, role, subscription, created_at 
     FROM users WHERE id=$1`,
    [id]
  );
  return result.rows[0];
};

export const updateUserProfile = async (id, data) => {
  const { full_name, bio } = data;
  const result = await pool.query(
    `UPDATE users 
     SET full_name=$1, bio=$2, updated_at=NOW()
     WHERE id=$3
     RETURNING id, full_name, email, bio, avatar_url,role,subscription`,
    [full_name, bio, id]
  );
  if (result.rows.length === 0) throw new Error("User not found");
  return result.rows[0];
};

export const updateUserPassword = async (id, data) => {
  const { current_password, new_password, confirm_password } = data;
  if (new_password !== confirm_password) throw new Error("Passwords do not match");
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const userRes = await client.query(
      'SELECT password_hash FROM users WHERE id=$1 FOR UPDATE',
      [id]
    );
    if (userRes.rows.length === 0) throw new Error("User not found");
    const valid = await bcrypt.compare(current_password, userRes.rows[0].password_hash);
    if (!valid) throw new Error("Current password is incorrect");
    const password_hash = await bcrypt.hash(new_password, parseInt(process.env.BCRYPT_ROUNDS || "12"));
    const result = await client.query(
      `UPDATE users 
       SET password_hash=$1, token_version = token_version + 1, updated_at=NOW()
       WHERE id=$2
       RETURNING id, full_name, email, role, subscription`,
      [password_hash, id]
    );
    await client.query('COMMIT');
    return result.rows[0];
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
};

export const uploadUserAvatar = async (userID, avatarUrl) => {
  const result = await pool.query(
    `UPDATE users 
     SET avatar_url=$1, updated_at=NOW()
     WHERE id=$2
     RETURNING id, full_name, email, avatar_url`,
    [avatarUrl, userID]
  );
  return result.rows[0];
};

export const createGoogleUser = async (data) => {
  const { email, full_name, avatar_url, subscription = "free" } = data;
  const result = await pool.query(
    `INSERT INTO users (email, full_name, avatar_url, auth_provider, subscription, is_email_verified)
     VALUES ($1, $2, $3, 'google', $4, true)
     RETURNING id, full_name, email, role, subscription, avatar_url`,
    [email, full_name, avatar_url, subscription]
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
      COUNT(*) FILTER (WHERE last_login_at >= NOW() - INTERVAL '7 days) AS active_users
     FROM users`
  );
  return result.rows[0];
};

export const fetchAllUsers = async (limit, offset, search = "", subscription = "") => {
  let query = `SELECT id,full_name,email,role,subscription,created_at FROM users WHERE 1=1`;
  const params = [];
  let paramIndex = 1;
  if (search) {
    query += ` AND (full_name ILIKE $${paramIndex} OR email ILIKE $${paramIndex})`;
    params.push(`%${search}%`);
    paramIndex++;
  }
  if (subscription) {
    query += `AND subscription= $${paramIndex}`;
    params.push(subscription);
    paramIndex++;
  }
  query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
  params.push(limit, offset);
  const result = await pool.query(query, params);
  return result.rows;
};

export const updateUserSubscriptionStatus = async (id, subscription) => {
  const result = await pool.query(
    `UPDATE users 
     SET subscription=$2, updated_at=NOW()
     WHERE id=$1
     RETURNING id, email, full_name, subscription`,
    [id, subscription]
  );
  return result.rows[0];
};

export const incrementTokenVersion = async (id) => {
  const result = await pool.query(
    `UPDATE users SET token_version = token_version + 1, updated_at=NOW() WHERE id=$1 RETURNING token_version`,
    [id]
  );
  return result.rows[0];
};

export const saveRefreshToken = async (userId, token, expiresAt) => {
  await pool.query(
    `INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES ($1, $2, $3)`,
    [userId, token, expiresAt]
  );
};

export const findRefreshToken = async (token) => {
  const result = await pool.query(
    `SELECT * FROM refresh_tokens WHERE token=$1`,
    [token]
  );
  return result.rows[0];
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