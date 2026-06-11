import pool from '../../../config/db.js';

export const togglePostLike = async ({ postId, userId }) => {
  const existing = await pool.query(
    `SELECT 1 FROM post_likes WHERE post_id = $1 AND user_id = $2`,
    [postId, userId]
  );
  if (existing.rows.length > 0) {
    await pool.query(
      `DELETE FROM post_likes WHERE post_id = $1 AND user_id = $2`,
      [postId, userId]
    );
    return { liked: false };
  }
  await pool.query(
    `INSERT INTO post_likes (post_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
    [postId, userId]
  );
  return { liked: true };
};

export const toggleCommentLike = async ({ commentId, userId }) => {
  const existing = await pool.query(
    `SELECT 1 FROM comment_likes WHERE comment_id = $1 AND user_id = $2`,
    [commentId, userId]
  );
  if (existing.rows.length > 0) {
    await pool.query(
      `DELETE FROM comment_likes WHERE comment_id = $1 AND user_id = $2`,
      [commentId, userId]
    );
    return { liked: false };
  }
  await pool.query(
    `INSERT INTO comment_likes (comment_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
    [commentId, userId]
  );
  return { liked: true };
};

export const getPostLikeCount = async (postId) => {
  const result = await pool.query(
    `SELECT COUNT(*)::INT AS count FROM post_likes WHERE post_id = $1`,
    [postId]
  );
  return result.rows[0].count;
};

export const getCommentLikeCount = async (commentId) => {
  const result = await pool.query(
    `SELECT COUNT(*)::INT AS count FROM comment_likes WHERE comment_id = $1`,
    [commentId]
  );
  return result.rows[0].count;
};