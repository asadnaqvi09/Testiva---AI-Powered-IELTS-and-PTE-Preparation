import { useState, useEffect, useCallback, useRef } from 'react';
import { socketService } from '../services/socket.service';
import {
  fetchNotificationsAPI,
  fetchUnreadCountAPI,
  markNotificationReadAPI,
  markAllNotificationsReadAPI,
  type AdminNotification,
} from '../services/api';
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';

export type Notification = AdminNotification;

export function useNotifications() {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const [socketReady, setSocketReady] = useState(false);
  const seenIds = useRef(new Set<string>());

  const loadNotifications = useCallback(async () => {
    if (!user) return;
    setLoading(true);
    try {
      const [notifRes, countRes] = await Promise.all([
        fetchNotificationsAPI(),
        fetchUnreadCountAPI(),
      ]);

      if (notifRes.success) {
        setNotifications(notifRes.notifications);
        seenIds.current = new Set(notifRes.notifications.map((n) => n.id));
      }
      if (countRes.success) setUnreadCount(countRes.unreadCount);
    } catch (error) {
      console.error('[Notifications] Failed to load:', error);
    } finally {
      setLoading(false);
    }
  }, [user]);

  const markAsRead = async (id: string) => {
    const target = notifications.find((n) => n.id === id);
    if (target?.is_read) return;

    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, is_read: true } : n)),
    );
    setUnreadCount((prev) => Math.max(0, prev - 1));

    try {
      const res = await markNotificationReadAPI(id);
      if (res.success && typeof res.unreadCount === 'number') {
        setUnreadCount(res.unreadCount);
      }
    } catch {
      await loadNotifications();
    }
  };

  const markAllRead = async () => {
    if (unreadCount === 0) return;
    try {
      setNotifications((prev) => prev.map((n) => ({ ...n, is_read: true })));
      setUnreadCount(0);
      await markAllNotificationsReadAPI();
      toast.success('All notifications marked as read');
    } catch {
      toast.error('Failed to mark all notifications as read');
      await loadNotifications();
    }
  };

  // REST load on login — do not wait for socket
  useEffect(() => {
    if (!user) {
      setNotifications([]);
      setUnreadCount(0);
      seenIds.current.clear();
      return;
    }
    loadNotifications();
  }, [user, loadNotifications]);

  // Track socket readiness for UI/debug
  useEffect(() => {
    if (!user) {
      setSocketReady(false);
      return;
    }
    return socketService.onConnect(() => setSocketReady(true));
  }, [user]);

  // Real-time notification:new events
  useEffect(() => {
    if (!user) return;

    const handleNewNotification = (data: {
      notification: Notification;
      unreadCount?: number;
    }) => {
      const { notification } = data;
      if (!notification?.id || seenIds.current.has(notification.id)) return;

      seenIds.current.add(notification.id);
      setNotifications((prev) => [notification, ...prev]);

      if (typeof data.unreadCount === 'number') {
        setUnreadCount(data.unreadCount);
      } else {
        setUnreadCount((prev) => prev + 1);
      }

      toast.info(notification.title, {
        description: notification.message,
      });
    };

    const attachListener = () => {
      socketService.off('notification:new', handleNewNotification);
      socketService.on('notification:new', handleNewNotification);
    };

    attachListener();
    const unregisterConnect = socketService.onConnect(attachListener);

    return () => {
      unregisterConnect();
      socketService.off('notification:new', handleNewNotification);
    };
  }, [user]);

  return {
    notifications,
    unreadCount,
    loading,
    socketReady,
    markAsRead,
    markAllRead,
    refresh: loadNotifications,
  };
}
