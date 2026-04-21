import pool from "../config/db.js";
import bcrypt from "bcrypt";

export const findUserByEmail = async (email) => {
  const result = await pool.query(
    "SELECT id, full_name, email, role, subscription, password_hash, auth_provider, is_email_verified FROM users WHERE email=$1",
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
    `SELECT id, full_name, email, avatar_url, country, role, subscription, created_at 
     FROM users WHERE id=$1`,
    [id]
  );
  return result.rows[0];
};

export const updateUserProfile = async (id, data) => {
  const { full_name, password, confirm_password } = data;

  if (password) {
    if (password !== confirm_password) {
      throw new Error("Password mismatch");
    }

    const password_hash = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `UPDATE users 
       SET full_name=$1, password_hash=$2, updated_at=NOW()
       WHERE id=$3
       RETURNING id, full_name, email, country, avatar_url, role, subscription`,
      [full_name, password_hash, id]
    );

    return result.rows[0];
  }

  const result = await pool.query(
    `UPDATE users 
     SET full_name=$1, updated_at=NOW()
     WHERE id=$2
     RETURNING id, full_name, email, country, avatar_url, role, subscription`,
    [full_name, id]
  );

  return result.rows[0];
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
      COUNT(*) FILTER (WHERE subscription='premium') AS premium_users
     FROM users`
  );

  return result.rows[0];
};

export const fetchAllUsers = async (limit, offset) => {
  const result = await pool.query(
    `SELECT id, full_name, email, role, subscription, created_at
     FROM users
     ORDER BY created_at DESC
     LIMIT $1 OFFSET $2`,
    [limit, offset]
  );

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

export const saveRefreshToken = async (userId, token, expiresAt) => {
  await pool.query(
    `INSERT INTO refresh_tokens (user_id, token, expires_at)
     VALUES ($1, $2, $3)`,
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