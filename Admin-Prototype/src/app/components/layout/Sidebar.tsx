import React, { useState } from 'react';
import { NavLink, useNavigate } from 'react-router';
import {
  LayoutDashboard, Users, FileText, BookOpen,
  BarChart3, MessageSquare, CreditCard, Settings,
  LogOut, ChevronLeft, ChevronRight, GraduationCap, X
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const LOGO_BLUE = '#007BFF';

interface NavItem {
  label: string;
  icon: React.ReactNode;
  path: string;
  roles?: string[];
}

const navItems: NavItem[] = [
  { label: 'Dashboard', icon: <LayoutDashboard size={20} />, path: '/dashboard' },
  { label: 'Users', icon: <Users size={20} />, path: '/users', roles: ['admin', 'super_admin'] },
  { label: 'Students', icon: <GraduationCap size={20} />, path: '/users', roles: ['institute_admin'] },
  { label: 'Mock Tests', icon: <FileText size={20} />, path: '/mocks' },
  { label: 'Preparation', icon: <BookOpen size={20} />, path: '/preparation' },
  { label: 'Analytics', icon: <BarChart3 size={20} />, path: '/analytics' },
  { label: 'Community', icon: <MessageSquare size={20} />, path: '/community', roles: ['admin', 'super_admin'] },
  { label: 'Subscriptions', icon: <CreditCard size={20} />, path: '/subscriptions', roles: ['admin', 'super_admin'] },
  { label: 'Settings', icon: <Settings size={20} />, path: '/settings' },
];

interface SidebarProps {
  mobileOpen: boolean;
  onMobileClose: () => void;
}

export function Sidebar({ mobileOpen, onMobileClose }: SidebarProps) {
  const [collapsed, setCollapsed] = useState(false);
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const filteredNav = navItems.filter(item => {
    if (!item.roles) return true;
    return user && item.roles.includes(user.role);
  });

  const SidebarContent = () => (
    <div className="flex flex-col h-full" style={{ background: '#1A1A2E' }}>
      {/* Logo */}
      <div className="flex items-center justify-between px-4 py-5 border-b border-white/10">
        {!collapsed && (
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background: LOGO_BLUE }}>
              <GraduationCap size={18} color="white" />
            </div>
            <span className="text-white font-semibold text-sm leading-tight">ACELT<br /><span style={{ color: LOGO_BLUE }} className="text-xs">Admin</span></span>
          </div>
        )}
        {collapsed && (
          <div className="w-8 h-8 rounded-lg flex items-center justify-center mx-auto" style={{ background: LOGO_BLUE }}>
            <GraduationCap size={18} color="white" />
          </div>
        )}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="hidden lg:flex text-gray-400 hover:text-white transition-colors p-1 rounded"
        >
          {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
        </button>
        <button onClick={onMobileClose} className="lg:hidden text-gray-400 hover:text-white">
          <X size={18} />
        </button>
      </div>

      {/* Mode badge */}
      {!collapsed && user && (
        <div className="px-4 py-2">
          <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${user.mode === 'b2c' ? 'bg-blue-500/20 text-blue-300' : 'bg-purple-500/20 text-purple-300'}`}>
            {user.mode === 'b2c' ? 'B2C Mode' : 'B2B Mode'}
          </span>
        </div>
      )}

      {/* Nav Items */}
      <nav className="flex-1 px-3 py-4 overflow-y-auto space-y-1">
        {filteredNav.map(item => (
          <NavLink
            key={item.path + item.label}
            to={item.path}
            onClick={onMobileClose}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200 group
              ${isActive
                ? 'text-white'
                : 'text-gray-400 hover:text-white hover:bg-white/5'
              }`
            }
            style={({ isActive }) => isActive ? { background: `${LOGO_BLUE}22`, color: LOGO_BLUE } : {}}
          >
            {({ isActive }) => (
              <>
                <span style={isActive ? { color: LOGO_BLUE } : {}} className="flex-shrink-0">{item.icon}</span>
                {!collapsed && <span className="text-sm font-medium">{item.label}</span>}
                {!collapsed && isActive && <div className="ml-auto w-1.5 h-1.5 rounded-full" style={{ background: LOGO_BLUE }} />}
              </>
            )}
          </NavLink>
        ))}
      </nav>

      {/* Logout */}
      <div className="px-3 pb-4 border-t border-white/10 pt-3">
        <button
          onClick={handleLogout}
          className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-gray-400 hover:text-red-400 hover:bg-red-500/10 transition-all w-full"
        >
          <LogOut size={20} className="flex-shrink-0" />
          {!collapsed && <span className="text-sm font-medium">Logout</span>}
        </button>
      </div>
    </div>
  );

  return (
    <>
      {/* Desktop Sidebar */}
      <div
        className={`hidden lg:flex flex-col flex-shrink-0 transition-all duration-300 ${collapsed ? 'w-16' : 'w-56'}`}
        style={{ height: '100vh', position: 'sticky', top: 0 }}
      >
        <SidebarContent />
      </div>

      {/* Mobile Overlay */}
      {mobileOpen && (
        <div className="lg:hidden fixed inset-0 z-50 flex">
          <div className="fixed inset-0 bg-black/50" onClick={onMobileClose} />
          <div className="relative w-64 flex flex-col">
            <SidebarContent />
          </div>
        </div>
      )}
    </>
  );
}
