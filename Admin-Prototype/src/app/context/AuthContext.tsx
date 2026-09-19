import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import {
  loginAPI,
  logoutAPI,
  setTokens,
  clearTokens,
  getAccessToken,
  getRefreshToken,
  getUserProfileAPI,
} from '../services/api';
import { socketService } from '../services/socket.service';
import {
  applyTheme,
  normalizeNotifPrefs,
  type NotifPrefs,
} from '../utils/uiSettings';

export type AdminRole = 'admin';

export interface AuthUser {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
  avatar?: string;
  subscription?: string;
  preference?: string | null;
  bio?: string | null;
  theme?: string;
  notifPrefs?: NotifPrefs;
}

interface AuthContextType {
  user: AuthUser | null;
  login: (email: string, password: string) => Promise<{ success: boolean; message?: string }>;
  logout: () => Promise<void>;
  updateUser: (newData: Partial<AuthUser>) => void;
  isAuthenticated: boolean;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

const isAdminRole = (role: string) => role === 'admin';

const clearAdminSession = () => {
  socketService.disconnect();
  clearTokens();
  localStorage.removeItem('authUser');
};

const mapApiUser = (raw: any): AuthUser => ({
  id: raw.id,
  name: raw.full_name || raw.name || '',
  email: raw.email,
  role: 'admin',
  subscription: raw.subscription,
  preference: raw.preference,
  bio: raw.bio,
  avatar: raw.avatar_url || raw.avatar,
  theme: raw.theme || 'light',
  notifPrefs: normalizeNotifPrefs(raw.notif_prefs || raw.notifPrefs),
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  // Hydrate session + pull fresh profile (theme / notif prefs) from API
  useEffect(() => {
    const boot = async () => {
      const stored = localStorage.getItem('authUser');
      const token = getAccessToken();
      if (!stored || !token) {
        setLoading(false);
        return;
      }
      try {
        const parsed = JSON.parse(stored) as AuthUser;
        if (!isAdminRole(parsed.role)) {
          clearAdminSession();
          setUser(null);
          setLoading(false);
          return;
        }
        setUser(parsed);
        applyTheme(parsed.theme || 'light');
        socketService.connect(token);

        const res = await getUserProfileAPI().catch(() => null);
        if (res?.success && res.user) {
          const fresh = mapApiUser(res.user);
          setUser(fresh);
          localStorage.setItem('authUser', JSON.stringify(fresh));
          applyTheme(fresh.theme || 'light');
        }
      } catch {
        clearAdminSession();
        setUser(null);
      } finally {
        setLoading(false);
      }
    };
    boot();
  }, []);

  const login = async (email: string, password: string): Promise<{ success: boolean; message?: string }> => {
    try {
      const res = await loginAPI(email, password);
      if (res.success && res.accessToken) {
        if (!isAdminRole(res.user.role)) {
          clearAdminSession();
          return { success: false, message: 'Admin access only. This account does not have admin privileges.' };
        }
        setTokens(res.accessToken, res.refreshToken);
        let authUser = mapApiUser(res.user);

        // Enrich with settings fields from profile if login payload omits them
        const profile = await getUserProfileAPI().catch(() => null);
        if (profile?.success && profile.user) {
          authUser = mapApiUser(profile.user);
        }

        setUser(authUser);
        localStorage.setItem('authUser', JSON.stringify(authUser));
        applyTheme(authUser.theme || 'light');
        socketService.connect(res.accessToken);
        return { success: true };
      }
      return { success: false, message: 'Invalid server response' };
    } catch (err: any) {
      return {
        success: false,
        message: err?.data?.message || err?.message || 'Login failed',
      };
    }
  };

  const logout = async () => {
    try {
      const refresh = getRefreshToken();
      if (refresh) await logoutAPI(refresh).catch(() => {});
    } finally {
      clearAdminSession();
      setUser(null);
    }
  };

  const updateUser = (newData: Partial<AuthUser>) => {
    setUser((prev) => {
      if (!prev) return null;
      const updated = { ...prev, ...newData };
      if (newData.theme) applyTheme(newData.theme);
      localStorage.setItem('authUser', JSON.stringify(updated));
      return updated;
    });
  };

  return (
    <AuthContext.Provider value={{
      user,
      login,
      logout,
      updateUser,
      isAuthenticated: !!user,
      loading,
    }}>
      {!loading && children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
