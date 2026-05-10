import { createNotification, getUnreadNotificationCount, createBulkNotifications } from "../models/notification.model.js";
import { emitToUser } from "../socketIO/event.engine.js";

export const sendNotification = async ({
  io,
  recipientId,
  senderId = null,
  type,
  title,
  message,
  entityId = null,
  entityType = null
}) => {
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
  return notification;
};

export const sendBulkNotifications = async (params) => {
  const { io, recipientIds = [], senderId = null, type, title, message, entityId = null, entityType = null } = params;
  if (!recipientIds.length) return [];
  
  // Highly efficient single database connection bulk insert
  const notifications = await createBulkNotifications({
    recipientIds, senderId, type, title, message, entityId, entityType
  });

  // Non-blocking socket emission (omits individual unread count to save 5000+ DB queries)
  setImmediate(() => {
    notifications.forEach(notif => {
      emitToUser(io, notif.user_id, "notification:new", { notification: notif });
    });
  });

  return notifications;
};