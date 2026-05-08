import pool from "../../config/db.js";
import bcrypt from "bcrypt";

const USER_FIELDS = `
id,
full_name,
email,
bio,
avatar_url,
role,
subscription,
preferences,
auth_provider,
is_email_verified,
token_version,
last_login_at,
created_at,
updated_at
`;

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
  preferences = null
}) => {
  const result = await pool.query(
    `INSERT INTO users (
      full_name,
      email,
      password_hash,
      auth_provider,
      is_email_verified,
      subscription,
      preferences
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
      preferences
    ]
  );
  return result.rows[0];
};

export const updateUserPreference = async (id, preferences) => {
  const result = await pool.query(
    `UPDATE users SET preferences=$1,updated_at=NOW()
     WHERE id=$2
     RETURNING ${USER_FIELDS}`,
    [preferences, id]
  );
  return result.rows[0] || null;
};

export const getUserPreference = async (id) => {
  const result = await pool.query(
    `SELECT id,preferences,subscription FROM users WHERE id=$1`,
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

    if (!valid) throw new Error("Invalid password");

    const hash = await bcrypt.hash(
      data.new_password,
      Number(process.env.BCRYPT_ROUNDS || 12)
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