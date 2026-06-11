import pool from '../../../config/db.js';

export const insertModerationLog = async ({
  adminId,
  targetId,
  action,
  adminFeedback = null,
  emailSent = false
}) => {
  await pool.query(
    `INSERT INTO moderation_log 
        (admin_id, post_id, action, admin_feedback, email_sent) 
     VALUES ($1, $2, $3, $4, $5)`,
    [adminId, targetId, action, adminFeedback, emailSent]
  );
};

export const getModerationLogsByPost = async ({ postId }) => {
  const result = await pool.query(
    `SELECT ml.*, u.full_name AS admin_name
     FROM moderation_log ml
     JOIN users u ON u.id = ml.admin_id
     WHERE ml.post_id = $1
     ORDER BY ml.created_at DESC`,
    [postId]
  );
  return result.rows;
};