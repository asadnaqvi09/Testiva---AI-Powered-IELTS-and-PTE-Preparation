import { createBrowserRouter, Navigate } from 'react-router';
import React from 'react';
import { DashboardLayout } from './components/layout/DashboardLayout';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { Users } from './pages/Users';
import { Mocks } from './pages/Mocks';
import { Preparation } from './pages/Preparation';
import { Analytics } from './pages/Analytics';
import { Community } from './pages/Community';
import { Subscriptions } from './pages/Subscriptions';
import { Settings } from './pages/Settings';
import { Institutes } from './pages/Institutes';
import { TestBuilder } from './pages/TestBuilder';

export const router = createBrowserRouter([
  {
    path: '/login',
    Component: Login,
  },
  {
    path: '/',
    Component: DashboardLayout,
    children: [
      { index: true, Component: () => <Navigate to="/dashboard" replace /> },
      { path: 'dashboard', Component: Dashboard },
      { path: 'users', Component: Users },
      { path: 'institutes', Component: Institutes },
      { path: 'mocks', Component: Mocks },
      { path: 'preparation', Component: Preparation },
      { path: 'analytics', Component: Analytics },
      { path: 'community', Component: Community },
      { path: 'subscriptions', Component: Subscriptions },
      { path: 'test-builder', Component: TestBuilder },
      { path: 'settings', Component: Settings },
    ],
  },
  {
    path: '*',
    Component: () => (
      <div className="min-h-screen flex items-center justify-center" style={{ background: '#F5F7FA' }}>
        <div className="text-center">
          <div className="w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4" style={{ background: '#DC354515' }}>
            <span style={{ fontSize: '36px' }}>⚠️</span>
          </div>
          <h1 style={{ color: '#1A1A1A' }}>Page Not Found</h1>
          <p className="text-gray-500 mt-2 mb-6">The page you're looking for doesn't exist.</p>
          <a href="/dashboard" className="px-6 py-2 rounded-lg text-white text-sm font-medium" style={{ background: '#007BFF' }}>
            Go to Dashboard
          </a>
        </div>
      </div>
    ),
  },
]);