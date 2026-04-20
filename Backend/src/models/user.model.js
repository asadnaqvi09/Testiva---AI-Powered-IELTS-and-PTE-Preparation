import pool from "../config/db.js";
import bcrypt from 'bcrypt';

export const findUserByEmail = async (email) => {
  const result = await pool.query(
    "SELECT id, full_name, email, role, subscription, auth_provider FROM users WHERE email=$1",
    [email]
  );
  return result.rows[0];
};

export const createUser = async (userData) => {
  const { full_name, email, password_hash } = userData;
  const result = await pool.query(
    `INSERT INTO users (full_name, email, password_hash)
     VALUES ($1, $2, $3)
     RETURNING id, full_name, email, role, subscription, auth_provider ,created_at`,
    [full_name, email, password_hash]
  );
  return result.rows[0];
};

export const findUserById = async (id) => {
  const result = await pool.query(
    `SELECT id, full_name, email, avatar_url, country, role, subscription, created_at 
     FROM users WHERE id = $1`,
    [id]
  );
  return result.rows[0];
};

export const updateUserProfile = async (id, data) => {
  const { full_name, password, confirm_password } = data;
  let query;
  let values;
  if (password) {
    if (password !== confirm_password) {
        throw new Error('Password Did Not Match Please Provide Correct Password')
    }
    const password_hash = await bcrypt.hash(password,10);
    query = `UPDATE users
      SET full_name = $1, password_hash = $2, updated_at = NOW()
      WHERE id = $3
      RETURNING id, full_name, email, country, avatar_url, role, subscription
    `;
    values = [full_name,password_hash, id];
  } else {
    query = `
      UPDATE users 
      SET full_name=$1, updated_at=NOW()
      WHERE id=$2
      RETURNING id, full_name, email, country, avatar_url, role, subscription
    `;
    values = [full_name, id];
  }
  const result = await pool.query(query, values);
  return result.rows[0];
};

export const uploadUserAvatar = async (userID, avatarUrl) => {
  const result = await pool.query(
    `UPDATE users SET avatar_url=$1, updated_at=NOW()
     WHERE id=$2
     RETURNING id, full_name, email, avatar_url`,
    [avatarUrl, userID]
  );
  return result.rows[0]; // Fixed: now returns result
};

export const createGoogleUser = async (data) => {
  const { email, full_name, avatar_url, subscription } = data; 
  const result = await pool.query(
    `INSERT INTO users (email, full_name, avatar_url, auth_provider, subscription ,is_email_verified)
     VALUES ($1, $2, $3, 'google', $4 ,true)
     RETURNING id, full_name, email, role, subscription, avatar_url`,
    [email, full_name, avatar_url, subscription]
  );
  return result.rows[0]; // Fixed: now returns result
};

export const getAdminStats = async () => {
  const result = await pool.query(
    `SELECT 
      COUNT(*) AS total_users,
      COUNT(*) FILTER (WHERE subscription = 'free') AS free_users,
      COUNT(*) FILTER (WHERE subscription = 'premium') AS premium_users,
      COUNT(*) FILTER (WHERE subscription = 'basic') AS basic_users
    FROM users`,
  )
  return result.rows[0]
};

export const fetchAllUsers = async (limit, offset) => {
  const result = await pool.query(
    `SELECT id,full_name,email,role,subscription,created_at
    FROM users
    ORDER BY created_at DESC
    LIMIT $1 OFFSET $2
    `, [limit, offset]
  )
  return result.rows
}

export const updateUserSubscriptionStatus = async (id, subscription) => {
  const result = await pool.query(`
    UPDATE users 
    SET subscription = $2, updated_at = NOW()
    WHERE id = $1
    RETURNING id,email,full_name,subscription  
  `, [id, subscription])
  return result.rows[0]
}
