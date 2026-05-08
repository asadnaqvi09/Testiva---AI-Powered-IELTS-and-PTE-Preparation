// src/modules/M9_Notification/controller/notification.controller.js

import {
  getUserNotifications,
  getUnreadNotificationCount,
  markNotificationAsRead,
  markAllNotificationsAsRead,
  deleteNotification
} from "../models/notification.model.js";

export const fetchNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const limit = Number(req.query.limit) || 20;
    const offset = Number(req.query.offset) || 0;
    const notifications = await getUserNotifications(
      userId,
      limit,
      offset
    );
    return res.status(200).json({
      success: true,
      notifications
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: "Failed to fetch notifications"
    });
  }
};

export const fetchUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id;
    const count = await getUnreadNotificationCount(userId);
    return res.status(200).json({
      success: true,
      unreadCount: count
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: "Failed to fetch unread count"
    });
  }
};

export const readNotification = async (req, res) => {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;
    const notification = await markNotificationAsRead(
      notificationId,
      userId
    );
    if (!notification) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }
    const unreadCount = await getUnreadNotificationCount(userId);
    return res.status(200).json({
      success: true,
      notification,
      unreadCount
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: "Failed to update notification"
    });
  }
};

export const readAllNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    await markAllNotificationsAsRead(userId);
    return res.status(200).json({
      success: true,
      message: "All notifications marked as read",
      unreadCount: 0
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: "Failed to update notifications"
    });
  }
};

export const removeNotification = async (req, res) => {
  try {
    const userId = req.user.id;
    const notificationId = req.params.id;
    const deleted = await deleteNotification(
      notificationId,
      userId
    );
    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: "Notification not found"
      });
    }
    const unreadCount = await getUnreadNotificationCount(userId);
    return res.status(200).json({
      success: true,
      message: "Notification deleted",
      unreadCount
    });
  } catch {
    return res.status(500).json({
      success: false,
      message: "Failed to delete notification"
    });
  }
};