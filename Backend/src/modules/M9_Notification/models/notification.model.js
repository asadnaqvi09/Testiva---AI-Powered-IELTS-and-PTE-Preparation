import pool from "../../../config/db.js";

export const createNotification = async ({ user_id, actor_id = null, type, title, message, post_id = null, comment_id = null }) => {
  const result = await pool.query(
    `INSERT INTO notifications (user_id, actor_id, type, title, message, post_id, comment_id)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING *`,
    [
      user_id,
      actor_id,
      type,
      title,
      message,
      post_id,
      comment_id
    ]
  );
  return result.rows[0];
};

export const createBulkNotifications = async ({ recipientIds, senderId = null, type, title, message, post_id = null, comment_id = null }) => {
  if (!recipientIds || !recipientIds.length) return [];
  const result = await pool.query(
    `INSERT INTO notifications (user_id, actor_id, type, title, message, post_id, comment_id)
    SELECT unnest($1::uuid[]), $2, $3, $4, $5, $6, $7
    RETURNING *`,
    [recipientIds, senderId, type, title, message, post_id, comment_id]
  );
  return result.rows;
};

export const getUserNotifications = async (userId, limit = 20, offset = 0) => {
  const result = await pool.query(
    `SELECT n.id, n.type, n.title, n.message, n.post_id, n.comment_id, n.is_read, n.created_at, json_build_object('id', u.id, 'full_name', u.full_name, 'avatar_url', u.avatar_url) AS sender
    FROM notifications n
    LEFT JOIN users u ON u.id = n.actor_id
    WHERE n.user_id = $1
    ORDER BY n.created_at DESC
    LIMIT $2
    OFFSET $3`,
    [userId, limit, offset]
  );
  return result.rows;
};

export const markNotificationAsRead = async (notificationId,userId) => {
  const result = await pool.query(
    `UPDATE notifications
    SET
      is_read = true
    WHERE id = $1
    AND user_id = $2
    RETURNING *`,
    [notificationId, userId]
  )
  return result.rows[0] || null;
};

export const markAllNotificationsAsRead = async (userId) => {
  await pool.query(
    `UPDATE notifications
    SET
      is_read = true
    WHERE user_id = $1
    AND is_read = false`,
    [userId]
  );
  return true;
};

export const getUnreadNotificationCount = async (userId) => {
  const result = await pool.query(
    `SELECT COUNT(*)::INT AS count
    FROM notifications
    WHERE user_id = $1
    AND is_read = false`,
    [userId]
  );
  return result.rows[0]?.count || 0;
};

export const deleteNotification = async (notificationId,userId) => {
  const result = await pool.query(
    `DELETE FROM notifications
    WHERE id = $1
    AND user_id = $2
    RETURNING id`,
    [notificationId, userId]
  );
  return result.rows[0] || null;
};