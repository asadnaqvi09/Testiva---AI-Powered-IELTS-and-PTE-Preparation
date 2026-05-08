import pool from "../../../config/db.js";

export const createNotification = async ({
  user_id,
  sender_id = null,
  type,
  title,
  message,
  entity_id = null,
  entity_type = null
}) => {
  const result = await pool.query(
    `INSERT INTO notifications (
      user_id,
      sender_id,
      type,
      title,
      message,
      entity_id,
      entity_type
    )
    VALUES ($1,$2,$3,$4,$5,$6,$7)
    RETURNING *`,
    [
      user_id,
      sender_id,
      type,
      title,
      message,
      entity_id,
      entity_type
    ]
  );

  return result.rows[0];
};

export const getUserNotifications = async (
  userId,
  limit = 20,
  offset = 0
) => {
  const result = await pool.query(
    `SELECT
      n.id,
      n.type,
      n.title,
      n.message,
      n.entity_id,
      n.entity_type,
      n.is_read,
      n.created_at,
      json_build_object(
        'id', u.id,
        'full_name', u.full_name,
        'avatar_url', u.avatar_url
      ) AS sender
    FROM notifications n
    LEFT JOIN users u
      ON u.id = n.sender_id
    WHERE n.user_id = $1
    ORDER BY n.created_at DESC
    LIMIT $2
    OFFSET $3`,
    [userId, limit, offset]
  );

  return result.rows;
};

export const markNotificationAsRead = async (
  notificationId,
  userId
) => {
  const result = await pool.query(
    `UPDATE notifications
    SET
      is_read = true,
      read_at = NOW()
    WHERE id = $1
    AND user_id = $2
    RETURNING *`,
    [notificationId, userId]
  );

  return result.rows[0] || null;
};

export const markAllNotificationsAsRead = async (userId) => {
  await pool.query(
    `UPDATE notifications
    SET
      is_read = true,
      read_at = NOW()
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

export const deleteNotification = async (
  notificationId,
  userId
) => {
  const result = await pool.query(
    `DELETE FROM notifications
    WHERE id = $1
    AND user_id = $2
    RETURNING id`,
    [notificationId, userId]
  );

  return result.rows[0] || null;
};