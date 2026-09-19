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
      // clean and optimized code — include attempt id for test_result deep links
      sendPushNotification(fcmToken, title, message, {
        type: type || "",
        postId: postId || "",
        commentId: commentId || "",
        attemptId: type === "test_result_synced" ? (postId || "") : "",
      }).catch(err => console.error("[FCM Async Error]:", err.message));
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
  // clean and optimized code — best-effort FCM for bulk recipients
  setImmediate(async () => {
    try {
      const { rows } = await pool.query(
        `SELECT id, fcm_token FROM users
         WHERE id = ANY($1::uuid[]) AND fcm_token IS NOT NULL AND fcm_token <> ''`,
        [recipientIds],
      );
      for (const row of rows) {
        sendPushNotification(row.fcm_token, title, message, {
          type: type || "",
          postId: postId || "",
          commentId: commentId || "",
        }).catch((err) => console.error("[FCM Bulk Error]:", err.message));
      }
    } catch (err) {
      console.error("[FCM Bulk DB Error]:", err.message);
    }
  });
  return notifications;
};