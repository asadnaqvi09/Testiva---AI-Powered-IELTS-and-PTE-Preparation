import { createNotification, getUnreadNotificationCount, createBulkNotifications } from "../models/notification.model.js";
import { emitToUser } from "../socketIO/event.engine.js";
import pool from "../../../config/db.js";
import { sendPushNotification } from "../../../config/firebase.js";
import { isInQuietHours } from "../../../utils/quietHours.js";
import { normalizeNotifPrefs } from "../../M1_Identity/user.model.js";

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
    // L7: load notif_prefs for quiet-hours gate (in-app/socket still delivered)
    const userResult = await pool.query(
      'SELECT fcm_token, notif_prefs FROM users WHERE id = $1',
      [recipientId],
    );
    const row = userResult.rows[0];
    const fcmToken = row?.fcm_token;
    const prefs = normalizeNotifPrefs(row?.notif_prefs);
    if (fcmToken && !isInQuietHours(prefs)) {
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
  // clean and optimized code — best-effort FCM for bulk recipients (respect quiet hours)
  setImmediate(async () => {
    try {
      const { rows } = await pool.query(
        `SELECT id, fcm_token, notif_prefs FROM users
         WHERE id = ANY($1::uuid[]) AND fcm_token IS NOT NULL AND fcm_token <> ''`,
        [recipientIds],
      );
      for (const row of rows) {
        const prefs = normalizeNotifPrefs(row.notif_prefs);
        if (isInQuietHours(prefs)) continue;
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