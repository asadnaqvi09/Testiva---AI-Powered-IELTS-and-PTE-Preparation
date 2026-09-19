import React, { useState, useRef, useEffect, useMemo } from 'react';
import {
  Search, Bell, Menu, ChevronDown, Settings, LogOut,
  UserPlus, CreditCard, MessageSquare, FileText, Check, Loader2,
  Users, BookOpen, LayoutDashboard,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';
import { useNavigate } from 'react-router';
import { useNotifications, type Notification } from '../../hooks/useNotifications';
import { adminSearchAPI } from '../../services/api';
import { normalizeNotifPrefs, notifTypeAllowed } from '../../utils/uiSettings';

const NAV_PAGES = [
  { label: 'Dashboard', path: '/dashboard', keywords: 'home overview' },
  { label: 'Users', path: '/users', keywords: 'students accounts subscription unlock' },
  { label: 'Mock Tests', path: '/mocks', keywords: 'tests exams builder' },
  { label: 'Preparation', path: '/preparation', keywords: 'prep modules content' },
  { label: 'Analytics', path: '/analytics', keywords: 'stats reports metrics' },
  { label: 'Community', path: '/community', keywords: 'posts feed moderation' },
  { label: 'Subscriptions', path: '/subscriptions', keywords: 'billing plans unlock' },
  { label: 'Settings', path: '/settings', keywords: 'profile password theme' },
];

const NOTIF_CONFIG: Record<string, { icon: React.ReactNode; color: string; bg: string }> = {
  admin_new_user: { icon: <UserPlus size={14} />, color: '#007BFF', bg: '#007BFF15' },
  admin_subscription_changed: { icon: <CreditCard size={14} />, color: '#28A745', bg: '#28A74515' },
  admin_new_post: { icon: <FileText size={14} />, color: '#8B5CF6', bg: '#8B5CF615' },
  preference_change_request: { icon: <MessageSquare size={14} />, color: '#F59E0B', bg: '#F59E0B15' },
  default: { icon: <Bell size={14} />, color: '#6B7280', bg: '#F3F4F6' },
};

const TYPE_ICON: Record<string, React.ReactNode> = {
  user: <Users size={14} />,
  mock: <FileText size={14} />,
  prep: <BookOpen size={14} />,
  post: <MessageSquare size={14} />,
  page: <LayoutDashboard size={14} />,
};

function getNotificationRoute(notification: Notification): string | null {
  switch (notification.type) {
    case 'admin_new_user':
    case 'preference_change_request':
      return '/users';
    case 'admin_new_post':
      return '/community';
    case 'admin_subscription_changed':
      return '/subscriptions';
    default:
      return null;
  }
}

type SearchHit = { id: string; label: string; sub?: string; type: string; path: string };

interface TopBarProps {
  onMenuToggle: () => void;
}

export function TopBar({ onMenuToggle }: TopBarProps) {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const { notifications, unreadCount, loading, markAsRead, markAllRead, refresh } = useNotifications();
  const notifPrefs = normalizeNotifPrefs(user?.notifPrefs);

  const [showNotif, setShowNotif] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [showSearch, setShowSearch] = useState(false);
  const [searchLoading, setSearchLoading] = useState(false);
  const [remoteHits, setRemoteHits] = useState<SearchHit[]>([]);

  const notifRef = useRef<HTMLDivElement>(null);
  const profileRef = useRef<HTMLDivElement>(null);
  const searchRef = useRef<HTMLDivElement>(null);

  // Filter bell items using server-backed prefs
  const visibleNotifications = useMemo(
    () => notifications.filter((n) => notifTypeAllowed(n.type, notifPrefs)),
    [notifications, notifPrefs],
  );

  const visibleUnread = useMemo(
    () => visibleNotifications.filter((n) => !n.is_read).length,
    [visibleNotifications],
  );

  // Page matches (instant) + API hits (debounced)
  const pageHits = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    if (!q) return [] as SearchHit[];
    return NAV_PAGES
      .filter((item) => `${item.label} ${item.keywords} ${item.path}`.toLowerCase().includes(q))
      .slice(0, 4)
      .map((item) => ({
        id: item.path,
        label: item.label,
        sub: item.path,
        type: 'page',
        path: item.path,
      }));
  }, [searchQuery]);

  useEffect(() => {
    const q = searchQuery.trim();
    if (q.length < 2) {
      setRemoteHits([]);
      return;
    }
    const t = setTimeout(async () => {
      setSearchLoading(true);
      try {
        const res = await adminSearchAPI(q);
        if (res?.success && res.data) {
          setRemoteHits([
            ...(res.data.users || []),
            ...(res.data.mocks || []),
            ...(res.data.prep || []),
            ...(res.data.posts || []),
          ]);
        } else {
          setRemoteHits([]);
        }
      } catch {
        setRemoteHits([]);
      } finally {
        setSearchLoading(false);
      }
    }, 300);
    return () => clearTimeout(t);
  }, [searchQuery]);

  const searchResults = useMemo(() => [...pageHits, ...remoteHits].slice(0, 12), [pageHits, remoteHits]);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) setShowNotif(false);
      if (profileRef.current && !profileRef.current.contains(e.target as Node)) setShowProfile(false);
      if (searchRef.current && !searchRef.current.contains(e.target as Node)) setShowSearch(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  useEffect(() => {
    if (showNotif) refresh();
  }, [showNotif, refresh]);

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const handleNotificationClick = async (notification: Notification) => {
    await markAsRead(notification.id);
    const route = getNotificationRoute(notification);
    if (route) {
      setShowNotif(false);
      navigate(route);
    }
  };

  const formatTime = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInSeconds = Math.floor((now.getTime() - date.getTime()) / 1000);
    if (diffInSeconds < 60) return 'just now';
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
    return date.toLocaleDateString();
  };

  const badgeCount = Math.min(visibleUnread || unreadCount, 99);

  return (
    <div className="sticky top-0 z-40 flex items-center gap-4 px-4 lg:px-6 h-16 border-b bg-white border-gray-200">
      <button onClick={onMenuToggle} className="lg:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors">
        <Menu size={20} className="text-gray-900" />
      </button>

      <div className="flex-1 max-w-md" ref={searchRef}>
        <div className="relative">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => {
              setSearchQuery(e.target.value);
              setShowSearch(true);
            }}
            onFocus={() => setShowSearch(true)}
            placeholder="Search users, mocks, prep, posts…"
            className="w-full pl-9 pr-4 py-2 text-sm rounded-lg border border-gray-200 bg-gray-50 focus:outline-none focus:border-blue-400 focus:bg-white transition-all"
          />
          {showSearch && searchQuery.trim() && (
            <div className="absolute left-0 right-0 top-full mt-1 bg-white border border-gray-200 rounded-xl shadow-lg z-50 overflow-hidden max-h-80 overflow-y-auto">
              {searchLoading && searchResults.length === 0 ? (
                <div className="px-4 py-3 flex items-center gap-2 text-sm text-gray-400">
                  <Loader2 size={14} className="animate-spin" /> Searching…
                </div>
              ) : searchResults.length === 0 ? (
                <p className="px-4 py-3 text-sm text-gray-400">No matches</p>
              ) : (
                searchResults.map(item => (
                  <button
                    key={`${item.type}-${item.id}-${item.path}`}
                    type="button"
                    onClick={() => {
                      navigate(item.path);
                      setSearchQuery('');
                      setShowSearch(false);
                    }}
                    className="w-full text-left px-4 py-2.5 text-sm hover:bg-gray-50 flex items-center gap-3"
                  >
                    <span className="text-gray-400">{TYPE_ICON[item.type] || <Search size={14} />}</span>
                    <span className="flex-1 min-w-0">
                      <span className="font-medium text-gray-800 block truncate">{item.label}</span>
                      {item.sub && <span className="text-xs text-gray-400 truncate block">{item.sub}</span>}
                    </span>
                    <span className="text-[10px] uppercase text-gray-400 font-medium">{item.type}</span>
                  </button>
                ))
              )}
            </div>
          )}
        </div>
      </div>

      <div className="flex items-center gap-2 ml-auto">
        <div ref={notifRef} className="relative">
          <button
            onClick={() => { setShowNotif(!showNotif); setShowProfile(false); }}
            className="relative p-2 rounded-lg hover:bg-gray-100 transition-colors"
            aria-label="Notifications"
          >
            <Bell size={20} className="text-gray-700" />
            {badgeCount > 0 && (
              <span className="absolute top-1.5 right-1.5 w-4 h-4 rounded-full text-white flex items-center justify-center bg-red-500 text-[10px] font-bold border-2 border-white">
                {badgeCount > 99 ? '99+' : badgeCount}
              </span>
            )}
          </button>

          {showNotif && (
            <div className="absolute right-0 top-full mt-2 w-80 bg-white border border-gray-200 rounded-xl shadow-xl z-50 overflow-hidden">
              <div className="px-4 py-3 border-b border-gray-100 flex items-center justify-between bg-gray-50/50">
                <span className="font-semibold text-sm text-gray-800">Admin Notifications</span>
                {visibleUnread > 0 && (
                  <button
                    onClick={markAllRead}
                    className="text-[11px] font-medium text-blue-600 hover:underline"
                  >
                    Mark all as read
                  </button>
                )}
              </div>

              <div className="max-h-80 overflow-y-auto">
                {loading ? (
                  <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-gray-300" /></div>
                ) : visibleNotifications.length > 0 ? (
                  visibleNotifications.map((n) => {
                    const config = NOTIF_CONFIG[n.type] || NOTIF_CONFIG.default;
                    const route = getNotificationRoute(n);
                    return (
                      <div
                        key={n.id}
                        onClick={() => handleNotificationClick(n)}
                        className={`px-4 py-3 border-b border-gray-50 flex gap-3 hover:bg-gray-50 cursor-pointer transition-colors ${n.is_read ? 'opacity-60' : 'bg-blue-50/10'}`}
                      >
                        <div
                          className="flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center"
                          style={{ background: config.bg, color: config.color }}
                        >
                          {config.icon}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm text-gray-800 font-medium leading-tight">{n.title}</p>
                          <p className="text-xs text-gray-500 mt-0.5 line-clamp-2">{n.message}</p>
                          <div className="flex items-center gap-2 mt-1">
                            <span className="text-[10px] text-gray-400">{formatTime(n.created_at)}</span>
                            {!n.is_read && <span className="w-1.5 h-1.5 rounded-full bg-blue-600" />}
                            {route && (
                              <span className="text-[10px] text-blue-500 font-medium">View →</span>
                            )}
                          </div>
                        </div>
                      </div>
                    );
                  })
                ) : (
                  <div className="p-8 text-center">
                    <Check size={32} className="mx-auto text-gray-200 mb-2" />
                    <p className="text-sm text-gray-500">All caught up!</p>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>

        <div ref={profileRef} className="relative">
          <button
            onClick={() => { setShowProfile(!showProfile); setShowNotif(false); }}
            className="flex items-center gap-2 px-2 py-1.5 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <div className="w-8 h-8 rounded-full flex items-center justify-center bg-blue-600 text-white font-bold text-sm overflow-hidden">
              {user?.avatar ? (
                <img src={user.avatar} alt="" className="w-full h-full object-cover" />
              ) : (
                user?.name?.charAt(0) || 'U'
              )}
            </div>
            <div className="hidden sm:block text-left mr-1">
              <p className="text-sm font-semibold text-gray-900 leading-none">{user?.name}</p>
              <p className="text-[10px] text-gray-500 mt-1 uppercase tracking-wider">Admin</p>
            </div>
            <ChevronDown size={14} className="text-gray-400" />
          </button>

          {showProfile && (
            <div className="absolute right-0 top-full mt-2 w-52 bg-white border border-gray-200 rounded-xl shadow-xl z-50 py-1">
              <div className="px-4 py-3 border-b border-gray-100">
                <p className="text-xs text-gray-400">Signed in as</p>
                <p className="text-sm font-medium text-gray-900 truncate">{user?.email}</p>
              </div>
              <button onClick={() => { navigate('/settings'); setShowProfile(false); }} className="flex items-center gap-3 w-full px-4 py-2.5 hover:bg-gray-50 text-sm text-gray-700">
                <Settings size={15} className="text-gray-400" /> Profile Settings
              </button>
              <div className="border-t border-gray-100 my-1" />
              <button onClick={handleLogout} className="flex items-center gap-3 w-full px-4 py-2.5 hover:bg-red-50 text-sm text-red-600">
                <LogOut size={15} /> Sign Out
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
