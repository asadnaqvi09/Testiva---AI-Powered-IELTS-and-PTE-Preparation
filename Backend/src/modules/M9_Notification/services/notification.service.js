import { createNotification, getUnreadNotificationCount, createBulkNotifications } from "../models/notification.model.js";
import { emitToUser } from "../socketIO/event.engine.js";
import pool from "../../../config/db.js";
import { sendPushNotification } from "../../../config/firebase.js";

export const sendNotification = async ({io,recipientId,senderId = null,type,title,message,entityId = null,entityType = null}) => {
  const notification = await createNotification({
    user_id: recipientId,
    sender_id: senderId,
    type,
    title,
    message,
    entity_id: entityId,
    entity_type: entityType
  });
  const unreadCount = await getUnreadNotificationCount(recipientId);
  emitToUser(io, recipientId, "notification:new", { notification, unreadCount });
  try {
    const userResult = await pool.query('SELECT fcm_token FROM users WHERE id = $1', [recipientId]);
    const fcmToken = userResult.rows[0]?.fcm_token;
    if (fcmToken) {
      sendPushNotification(fcmToken, title, message, { type, entityId: entityId || "" })
        .catch(err => console.error("[FCM Async Error]:", err.message));
    }
  } catch (err) {
    console.error("[FCM DB Error]: Failed to fetch FCM token:", err.message);
  }
  return notification;
};

export const sendBulkNotifications = async (params) => {
  const { io, recipientIds = [], senderId = null, type, title, message, entityId = null, entityType = null } = params;
  if (!recipientIds.length) return [];
  const notifications = await createBulkNotifications({
    recipientIds, senderId, type, title, message, entityId, entityType
  });
  setImmediate(() => {
    notifications.forEach(notif => {
      emitToUser(io, notif.user_id, "notification:new", { notification: notif });
    });
  });
  return notifications;
};