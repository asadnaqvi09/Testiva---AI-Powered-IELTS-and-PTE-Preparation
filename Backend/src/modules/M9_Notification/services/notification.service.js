import { createNotification, getUnreadNotificationCount } from "../models/notification.model.js";
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
  const { recipientIds = [], ...rest } = params;
  if (!recipientIds.length) return [];
  return Promise.all(
    recipientIds.map((recipientId) => sendNotification({ recipientId, ...rest }))
  );
};