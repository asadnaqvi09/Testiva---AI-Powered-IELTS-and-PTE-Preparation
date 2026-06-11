import pool from '../../../config/db.js';

export const createComment = async ({ postId, userId, parentId, content }) => {
  const result = await pool.query(
    `INSERT INTO comments (post_id, user_id, parent_id, content)
     VALUES ($1, $2, $3, $4)
     RETURNING id, post_id, user_id, parent_id, content, created_at`,
    [postId, userId, parentId || null, content]
  );
  return result.rows[0];
};

export const getCommentById = async (commentId) => {
  const result = await pool.query(
    `SELECT c.id, c.post_id, c.user_id, c.parent_id, c.content,
            c.is_flagged, c.flagged_by, c.flag_reason,
            c.created_at, c.updated_at,
            u.full_name, u.profile_image,
            s.plan_type AS subscription_type
     FROM comments c
     JOIN users u              ON u.id = c.user_id
     LEFT JOIN subscriptions s ON s.user_id = c.user_id AND s.status = 'active'
     WHERE c.id = $1 AND c.deleted_at IS NULL`,
    [commentId]
  );
  return result.rows[0] || null;
};

export const getCommentsForPost = async ({ postId, userId }) => {
  const result = await pool.query(
    `SELECT c.id, c.post_id, c.user_id, c.parent_id, c.content,
            c.is_flagged, c.created_at, c.updated_at,
            u.full_name, u.profile_image,
            s.plan_type AS subscription_type,
            COUNT(DISTINCT cl.user_id)::INT AS like_count,
            EXISTS(
              SELECT 1 FROM comment_likes cl2
              WHERE cl2.comment_id = c.id AND cl2.user_id = $2
            ) AS liked_by_me
     FROM comments c
     JOIN users u              ON u.id = c.user_id
     LEFT JOIN subscriptions s ON s.user_id = c.user_id AND s.status = 'active'
     LEFT JOIN comment_likes cl ON cl.comment_id = c.id
     WHERE c.post_id = $1 AND c.deleted_at IS NULL
     GROUP BY c.id, u.full_name, u.profile_image, s.plan_type
     ORDER BY c.created_at ASC`,
    [postId, userId]
  );
  return result.rows;
};

export const updateComment = async ({ commentId, userId, content }) => {
  const result = await pool.query(
    `UPDATE comments
     SET content = $1, updated_at = NOW()
     WHERE id = $2 AND user_id = $3 AND deleted_at IS NULL
     RETURNING id, content, updated_at`,
    [content, commentId, userId]
  );
  return result.rows[0] || null;
};

export const softDeleteComment = async ({ commentId, userId }) => {
  const result = await pool.query(
    `UPDATE comments SET deleted_at = NOW()
     WHERE id = $1 AND user_id = $2 AND deleted_at IS NULL
     RETURNING id`,
    [commentId, userId]
  );
  return result.rows[0] || null;
};

export const adminDeleteComment = async (commentId) => {
  const result = await pool.query(
    `UPDATE comments SET deleted_at = NOW()
     WHERE id = $1 AND deleted_at IS NULL
     RETURNING id`,
    [commentId]
  );
  return result.rows[0] || null;
};

export const flagComment = async ({ commentId, flaggedBy, flagReason }) => {
  const result = await pool.query(
    `UPDATE comments
     SET is_flagged = TRUE, flagged_by = $1, flag_reason = $2, updated_at = NOW()
     WHERE id = $3 AND deleted_at IS NULL
     RETURNING id, is_flagged, flagged_by, flag_reason`,
    [flaggedBy, flagReason, commentId]
  );
  return result.rows[0] || null;
};

export const getParentCommentPostId = async (commentId) => {
  const result = await pool.query(
    `SELECT post_id, parent_id FROM comments WHERE id = $1 AND deleted_at IS NULL`,
    [commentId]
  );
  return result.rows[0] || null;
};