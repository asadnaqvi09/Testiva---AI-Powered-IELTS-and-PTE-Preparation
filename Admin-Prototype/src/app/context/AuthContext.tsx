import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { loginAPI, logoutAPI, setTokens, clearTokens, getAccessToken, getRefreshToken } from '../services/api';
import { socketService } from '../services/socket.service';

export type AdminRole = 'admin' | 'super_admin' | 'institute_admin';
export type AppMode = 'b2c' | 'b2b';

export interface AuthUser {
  id: string;
  name: string;
  email: string;
  role: AdminRole;
  mode: AppMode;
  avatar?: string;
  institute?: string;
  subscription?: string;
  preference?: string | null;
  bio?: string | null;
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

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  const initializeAuth = () => {
    const stored = localStorage.getItem('authUser');
    const token = getAccessToken();

    if (stored && token) {
      try {
        const parsedUser = JSON.parse(stored);
        setUser(parsedUser);
        socketService.connect(token);
      } catch {
        clearTokens();
        localStorage.removeItem('authUser');
      }
    }
    setLoading(false);
  };

  useEffect(() => {
    initializeAuth();
  }, []);

  const login = async (email: string, password: string): Promise<{ success: boolean; message?: string }> => {
    try {
      const res = await loginAPI(email, password);
      
      if (res.success && res.accessToken) {
        setTokens(res.accessToken, res.refreshToken);
        
        const authUser: AuthUser = {
          id: res.user.id,
          name: res.user.full_name,
          email: res.user.email,
          role: res.user.role as AdminRole,
          mode: 'b2c',
          subscription: res.user.subscription,
          preference: res.user.preference,
          bio: res.user.bio,
        };

        setUser(authUser);
        localStorage.setItem('authUser', JSON.stringify(authUser));
        
        socketService.connect(res.accessToken);
        
        return { success: true };
      }
      return { success: false, message: 'Invalid server response' };
    } catch (err: any) {
      return {
        success: false,
        message: err?.response?.data?.message || err?.message || 'Login failed',
      };
    }
  };

  const logout = async () => {
    try {
      const refresh = getRefreshToken();
      if (refresh) await logoutAPI(refresh).catch(() => {});
    } finally {
      socketService.disconnect();
      clearTokens();
      localStorage.removeItem('authUser');
      setUser(null);
    }
  };

  const updateUser = (newData: Partial<AuthUser>) => {
    setUser((prev) => {
      if (!prev) return null;
      const updated = { ...prev, ...newData };
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
      loading 
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