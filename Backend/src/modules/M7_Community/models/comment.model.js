import pool from '../../../config/db.js';

export const createComment = async ({
  postId,
  userId,
  parentId,
  content,
  isFlagged = false,
  flaggedBy = null,
  flagReason = null,
}) => {
  const result = await pool.query(
    `INSERT INTO comments (post_id, user_id, parent_id, content, is_flagged, flagged_by, flag_reason)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING id, post_id, user_id, parent_id, content, is_flagged, flagged_by, flag_reason, created_at`,
    [postId, userId, parentId || null, content, Boolean(isFlagged), flaggedBy, flagReason]
  );
  return result.rows[0];
};

export const getCommentById = async (commentId) => {
  const result = await pool.query(
    `SELECT c.id, c.post_id, c.user_id, c.parent_id, c.content,
            c.is_flagged, c.flagged_by, c.flag_reason,
            c.created_at, c.updated_at,
            u.full_name, u.avatar_url,
            u.subscription AS subscription_type
     FROM comments c
     JOIN users u ON u.id = c.user_id
     WHERE c.id = $1 AND c.deleted_at IS NULL`,
    [commentId]
  );
  return result.rows[0] || null;
};

export const getCommentsForPost = async ({ postId, userId }) => {
  const result = await pool.query(
    `
    SELECT
      c.id,
      c.post_id,
      c.user_id,
      c.parent_id,
      c.content,
      c.is_flagged,
      c.created_at,
      c.updated_at,
      u.full_name,
      u.avatar_url,
      u.subscription AS subscription_type,
      COUNT(DISTINCT cl.user_id)::INT AS like_count,
      CASE
        WHEN $2::uuid IS NULL THEN FALSE
        ELSE EXISTS (
          SELECT 1
          FROM comment_likes cl2
          WHERE cl2.comment_id = c.id
            AND cl2.user_id = $2
        )
      END AS liked_by_me
    FROM comments c
    JOIN users u ON u.id = c.user_id
    LEFT JOIN comment_likes cl ON cl.comment_id = c.id
    WHERE c.post_id = $1
      AND c.deleted_at IS NULL
      AND c.is_flagged = FALSE
    GROUP BY
      c.id,
      c.post_id,
      c.user_id,
      c.parent_id,
      c.content,
      c.is_flagged,
      c.created_at,
      c.updated_at,
      u.full_name,
      u.avatar_url,
      u.subscription
    ORDER BY c.created_at ASC
    `,
    [postId, userId || null]
  );
  return result.rows;
};

export const updateComment = async ({
  commentId,
  userId,
  content,
  isFlagged,
  flaggedBy,
  flagReason,
}) => {
  const result = await pool.query(
    `UPDATE comments
     SET content = $1,
         is_flagged = COALESCE($4, is_flagged),
         flagged_by = CASE
           WHEN $4 IS TRUE THEN $5::flag_source
           WHEN $4 IS FALSE THEN NULL
           ELSE flagged_by
         END,
         flag_reason = CASE
           WHEN $4 IS TRUE THEN $6
           WHEN $4 IS FALSE THEN NULL
           ELSE flag_reason
         END,
         updated_at = NOW()
     WHERE id = $2 AND user_id = $3 AND deleted_at IS NULL
     RETURNING id, content, is_flagged, flagged_by, flag_reason, updated_at`,
    [
      content,
      commentId,
      userId,
      typeof isFlagged === "boolean" ? isFlagged : null,
      flaggedBy ?? null,
      flagReason ?? null,
    ]
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
    `SELECT post_id, parent_id, user_id
     FROM comments
     WHERE id = $1 AND deleted_at IS NULL`,
    [commentId]
  );
  return result.rows[0] || null;
};