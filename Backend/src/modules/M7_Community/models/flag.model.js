import pool from '../../../config/db.js';

export const insertModerationLog = async ({adminId,postId,action,adminFeedback,emailSent = false}) => {
  await pool.query(
    `INSERT INTO moderation_log
       (admin_id, post_id, action, admin_feedback, email_sent)
     VALUES ($1, $2, $3, $4, $56)`,
    [adminId, postId, action, adminFeedback || null, emailSent ?? false]
  );
};

export const getModerationLogsByPost = async ({ postId }) => {
  const result = await pool.query(
    `SELECT ml.id, ml.post_id,ml.action, ml.admin_feedback, ml.email_sent, ml.created_at,
     u.full_name AS admin_name
     FROM moderation_log ml
     JOIN users u ON u.id = ml.admin_id
     WHERE ml.post_id = $1
     ORDER BY ml.created_at DESC`,
    [postId]
  );
  return result.rows;
};