import pool from '../../../config/db.js';

export const recordShare = async ({ postId, userId, platform }) => {
  const result = await pool.query(
    `INSERT INTO post_shares (post_id, user_id, platform)
     VALUES ($1, $2, $3)
     RETURNING id, platform, created_at`,
    [postId, userId, platform]
  );
  return result.rows[0];
};

export const getShareCountByPost = async (postId) => {
  const result = await pool.query(
    `SELECT platform, COUNT(*)::INT AS count
     FROM post_shares
     WHERE post_id = $1
     GROUP BY platform`,
    [postId]
  );
  return result.rows;
};