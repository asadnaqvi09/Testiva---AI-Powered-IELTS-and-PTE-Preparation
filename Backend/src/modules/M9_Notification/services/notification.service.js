import { createNotification, getUnreadNotificationCount, createBulkNotifications } from "../models/notification.model.js";
import { emitToUser } from "../socketIO/event.engine.js";
import pool from "../../../config/db.js";
import { sendPushNotification } from "../../../config/firebase.js";

export const sendNotification = async ({io,recipientId,senderId = null,type,title,message,postId = null,commentId = null}) => {
  const notification = await createNotification({
    user_id: recipientId,
    actor_id: senderId,
    type,
    title,
    message,
    post_id: postId,
    comment_id: commentId
  });
  const unreadCount = await getUnreadNotificationCount(recipientId);
  if (io) {
    emitToUser(io, recipientId, "notification:new", { notification, unreadCount });
  }
  try {
    const userResult = await pool.query('SELECT fcm_token FROM users WHERE id = $1', [recipientId]);
    const fcmToken = userResult.rows[0]?.fcm_token;
    if (fcmToken) {
      sendPushNotification(fcmToken, title, message, { type, postId: postId || "", commentId: commentId || "" })
        .catch(err => console.error("[FCM Async Error]:", err.message));
    }
  } catch (err) {
    console.error("[FCM DB Error]: Failed to fetch FCM token:", err.message);
  }
  return notification;
};

export const sendBulkNotifications = async (params) => {
  const { io, recipientIds = [], senderId = null, type, title, message, postId = null, commentId = null } = params;
  if (!recipientIds.length) return [];
  const notifications = await createBulkNotifications({
    recipientIds, senderId, type, title, message, post_id: postId, comment_id: commentId
  });
  if (io) {
    setImmediate(() => {
      notifications.forEach(notif => {
        emitToUser(io, notif.user_id, "notification:new", { notification: notif });
      });
    });
  }
  return notifications;
};