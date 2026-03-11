import pool from "../config/db.js";

export const findUserByEmail = async (email) => {
  const result = await pool.query(
    "SELECT * FROM users WHERE email=$1",
    [email]
  );
  return result.rows[0];
}

export const createUser = async (userData) => {
  const { full_name, email, password_hash } = userData;
  try {
    const result = await pool.query(
      `INSERT INTO users (full_name, email, password_hash)
       VALUES ($1, $2, $3)
       RETURNING id, full_name, email, role, subscription, created_at`,
      [full_name, email, password_hash]
    );
    return result.rows[0];
  } catch (error) {
    console.error("Error creating user:", error);
    throw error;
  }
};

export const findUserById = async (id) => {
  const result = await pool.query(
    `SELECT 
      id,
      full_name,
      email,
      avatar_url,
      country,
      role,
      subscription,
      is_email_verified,
      created_at
     FROM users
     WHERE id = $1`,
    [id]
  );
  return result.rows[0];
};

export const updateUserProfile = async (id, data) => {
  const { full_name, country } = data;
  const result = await pool.query(
    `UPDATE users
     SET full_name=$1,
         country=$2,
         updated_at=NOW()
     WHERE id=$3
     RETURNING 
        id,
        full_name,
        email,
        country,
        avatar_url,
        role,
        subscription`,
    [full_name, country, id]
  );
  return result.rows[0];
};

export const uploadUserAvatar = async (userID,avatarUrl) => {
  const result = await pool.query(
    `UPDATE users
     SET avatar_url=$1,
         updated_at=NOW()
     WHERE id=$2
     RETURNING id, full_name, email, avatar_url`,
    [avatarUrl, userID]
  );
  await result.rows[0];
};

export const createGoogleUser = async (data) => {
  const {email,full_name,avatar_url} = data;
  const result = await pool.query(
    `INSERT INTO users (email, full_name, avatar_url, auth_provider, is_email_verified)
     VALUES ($1,$2,$3,'google',true)
     RETURNING id, full_name, email, role, subscription, avatar_url`,
    [email, full_name, avatar_url]
  )
};