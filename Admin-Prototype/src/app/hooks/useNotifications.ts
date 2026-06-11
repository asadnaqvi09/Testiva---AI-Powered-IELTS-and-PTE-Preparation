import { useState, useEffect, useCallback } from 'react';
import { socketService } from '../services/socket.service';
import { 
  fetchNotificationsAPI, 
  fetchUnreadCountAPI, 
  markNotificationReadAPI, 
  markAllNotificationsReadAPI 
} from '../services/notification.api'; // Ensure these match your API service file
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';

export interface Notification {
  id: string;
  type: string;
  title: string;
  message: string;
  is_read: boolean;
  created_at: string;
  post_id?: string;
  comment_id?: string;
  sender?: {
    id: string;
    full_name: string;
    avatar_url: string;
  };
}

export function useNotifications() {
  const { user } = useAuth();
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(false);

  // 1. Fetch initial data from REST API
  const loadNotifications = useCallback(async () => {
    if (!user) return;
    setLoading(true);
    try {
      const [notifRes, countRes] = await Promise.all([
        fetchNotificationsAPI(),
        fetchUnreadCountAPI()
      ]);

      if (notifRes.success) setNotifications(notifRes.notifications);
      if (countRes.success) setUnreadCount(countRes.unreadCount);
    } catch (error) {
      console.error('[Notifications Hook] Initialization failed:', error);
    } finally {
      setLoading(false);
    }
  }, [user]);

  // 2. Mark single notification as read
  const markAsRead = async (id: string) => {
    try {
      // Optimistic UI Update
      setNotifications(prev => 
        prev.map(n => n.id === id ? { ...n, is_read: true } : n)
      );
      setUnreadCount(prev => Math.max(0, prev - 1));
      
      await markNotificationReadAPI(id);
    } catch (error) {
      // Rollback on error if necessary
      console.error('Failed to mark notification as read');
    }
  };

  // 3. Mark all as read
  const markAllRead = async () => {
    if (unreadCount === 0) return;
    try {
      setNotifications(prev => prev.map(n => ({ ...n, is_read: true })));
      setUnreadCount(0);
      await markAllNotificationsReadAPI();
      toast.success('All notifications cleared');
    } catch (error) {
      console.error('Failed to mark all as read');
    }
  };

  // 4. Socket Integration
  useEffect(() => {
    if (!user || !socketService.socket) return;

    // Load initial data once socket is ready
    loadNotifications();

    // Listen for the "notification:new" event defined in your backend service
    const handleNewNotification = (data: { notification: Notification; unreadCount?: number }) => {
      setNotifications(prev => [data.notification, ...prev]);
      
      // Update unread count if provided by backend, otherwise increment locally
      if (typeof data.unreadCount === 'number') {
        setUnreadCount(data.unreadCount);
      } else {
        setUnreadCount(prev => prev + 1);
      }

      // Optional: Trigger a toast for the new arrival
      toast.info(data.notification.title, {
        description: data.notification.message,
      });
    };

    socketService.on('notification:new', handleNewNotification);

    return () => {
      socketService.off('notification:new', handleNewNotification);
    };
  }, [user, loadNotifications]);

  return {
    notifications,
    unreadCount,
    loading,
    markAsRead,
    markAllRead,
    refresh: loadNotifications
  };
}