import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router';
import { Users, FileText, BookOpen, TrendingUp, ArrowRight, Plus, Activity, Loader2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { getDashboardStats, fetchAllTests, getPrepLessons } from '../services/api';

function StatCard({ icon, label, value, sub, color, onClick }: {
  icon: React.ReactNode; label: string; value: string | number; sub: string; color: string; onClick?: () => void;
}) {
  return (
    <div
      onClick={onClick}
      className={`bg-white rounded-xl p-5 border shadow-sm flex items-start gap-4 transition-all ${onClick ? 'cursor-pointer hover:shadow-md hover:-translate-y-0.5' : ''}`}
      style={{ borderColor: '#E5E7EB' }}
    >
      <div className="w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: `${color}18` }}>
        <span style={{ color }}>{icon}</span>
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm text-gray-500 font-medium">{label}</p>
        <p className="font-bold mt-0.5" style={{ color: '#1A1A1A', fontSize: '24px' }}>{value}</p>
        <p className="text-xs text-gray-400 mt-0.5">{sub}</p>
      </div>
      {onClick && <ArrowRight size={16} className="text-gray-300 flex-shrink-0 mt-1" />}
    </div>
  );
}

export function Dashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();

  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeSubs: 0,
    totalMocks: 0,
    totalPrepContent: 0,
  });
  const [recentMocks, setRecentMocks] = useState<any[]>([]);
  const [recentPrep, setRecentPrep] = useState<any[]>([]);

  useEffect(() => {
    async function loadDashboardData() {
      try {
        setLoading(true);

        const [statsRes, mocksRes, prepRes] = await Promise.all([
          getDashboardStats().catch(err => { console.error("Stats API Error:", err); return null; }),
          fetchAllTests(1, 4).catch(err => { console.error("Mocks API Error Handled:", err); return null; }),
          getPrepLessons().catch(err => { console.error("Prep API Error Handled:", err); return null; })
        ]);

        let computedMocksCount = 0;
        let computedPrepCount = 0;

        if (mocksRes?.success && Array.isArray(mocksRes.data)) {
          setRecentMocks(mocksRes.data.slice(0, 4));
          computedMocksCount = mocksRes.count || mocksRes.data.length || 0;
        }

        if (prepRes?.success && Array.isArray(prepRes.data)) {
          setRecentPrep(prepRes.data.slice(0, 3));
          computedPrepCount = prepRes.count || prepRes.data.length || 0;
        }

        if (statsRes?.success && statsRes.data) {
          const rawData = statsRes.data;
          const basicCount = parseInt(rawData.basic_users || '0', 10);
          const premiumCount = parseInt(rawData.premium_users || '0', 10);

          setStats({
            totalUsers: parseInt(rawData.total_users || '0', 10),
            activeSubs: basicCount + premiumCount,
            totalMocks: computedMocksCount,
            totalPrepContent: computedPrepCount,
          });
        } else {
          setStats({
            totalUsers: 0,
            activeSubs: 0,
            totalMocks: computedMocksCount,
            totalPrepContent: computedPrepCount,
          });
        }

      } catch (error: any) {
        console.error('Dashboard synchronization crashed:', error);
      } finally {
        setLoading(false);
      }
    }

    loadDashboardData();
  }, []);

  if (loading) {
    return (
      <div className="h-[70vh] w-100 flex flex-col items-center justify-center gap-3">
        <Loader2 className="animate-spin text-blue-600" size={36} />
        <p className="text-sm font-medium text-gray-500">Synchronizing database metrics...</p>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold" style={{ color: '#1A1A1A' }}>Dashboard</h1>
          <p className="text-sm text-gray-500 mt-0.5">
            Welcome back, {user?.full_name || user?.name || 'Administrator'} 
            {user?.institute && <span className="text-blue-500"> · {user.institute}</span>}
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard
          icon={<Users size={22} />}
          label="Total Users"
          value={stats.totalUsers}
          sub="Live registered profiles"
          color="#007BFF"
          onClick={() => navigate('/users')}
        />
        
        <StatCard
          icon={<TrendingUp size={22} />}
          label="Active Subs"
          value={stats.activeSubs}
          sub="Basic & Premium premium tiers"
          color="#28A745"
          onClick={() => navigate('/users')}
        />
        
        <StatCard
          icon={<FileText size={22} />}
          label="Mock Tests"
          value={stats.totalMocks}
          sub="Full-length system exams"
          color="#8B5CF6"
          onClick={() => navigate('/mocks')}
        />
        
        <StatCard
          icon={<BookOpen size={22} />}
          label="Prep Content"
          value={stats.totalPrepContent}
          sub="Active core resource materials"
          color="#F59E0B"
          onClick={() => navigate('/preparation')}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-xl border shadow-sm flex flex-col justify-between" style={{ borderColor: '#E5E7EB' }}>
          <div>
            <div className="flex items-center justify-between px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <h3 className="font-semibold text-sm uppercase tracking-wider text-gray-500">Recent Mock Tests</h3>
              <button onClick={() => navigate('/mocks')} className="text-xs font-semibold flex items-center gap-1 text-blue-600 hover:underline">
                View Mocks <ArrowRight size={12} />
              </button>
            </div>
            <div className="divide-y" style={{ borderColor: '#F5F7FA' }}>
              {recentMocks.length === 0 ? (
                <p className="text-sm text-gray-400 p-5 text-center">No structural mock tests found in DB.</p>
              ) : (
                recentMocks.map(mock => (
                  <div key={mock.id || mock._id} className="flex items-center gap-3 px-5 py-3 hover:bg-gray-50/50 transition-colors">
                    <div className="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: '#007BFF12' }}>
                      <FileText size={16} style={{ color: '#007BFF' }} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate" style={{ color: '#1A1A1A' }}>{mock.title}</p>
                      <p className="text-xs text-gray-400">{mock.exam_type || mock.testType || 'General'} · {mock.sections?.length || 4} Sections</p>
                    </div>
                    <span className="text-xs px-2 py-0.5 rounded-full font-medium"
                      style={mock.status === 'published' ? { background: '#28A74515', color: '#28A745' } : { background: '#F59E0B15', color: '#F59E0B' }}>
                      {mock.status || 'Active'}
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl border shadow-sm flex flex-col justify-between" style={{ borderColor: '#E5E7EB' }}>
          <div>
            <div className="flex items-center justify-between px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
              <h3 className="font-semibold text-sm uppercase tracking-wider text-gray-500">Recent Prep Content</h3>
              <button onClick={() => navigate('/preparation')} className="text-xs font-semibold flex items-center gap-1 text-blue-600 hover:underline">
                View Content <ArrowRight size={12} />
              </button>
            </div>
            <div className="divide-y" style={{ borderColor: '#F5F7FA' }}>
              {recentPrep.length === 0 ? (
                <p className="text-sm text-gray-400 p-5 text-center">No learning materials loaded in system yet.</p>
              ) : (
                recentPrep.map(item => (
                  <div key={item.id || item._id} className="flex items-center gap-3 px-5 py-3 hover:bg-gray-50/50 transition-colors">
                    <div className="w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0" style={{ background: '#F59E0B12' }}>
                      <BookOpen size={16} style={{ color: '#F59E0B' }} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate" style={{ color: '#1A1A1A' }}>{item.title}</p>
                      <p className="text-xs text-gray-400">{item.test_type || 'General'} Portal · Module Section: {item.section || 'All'}</p>
                    </div>
                    <span className="text-xs px-2 py-0.5 rounded-full font-medium bg-green-50 text-green-700">
                      Active
                    </span>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl border shadow-sm p-5" style={{ borderColor: '#E5E7EB' }}>
        <h3 className="text-sm font-semibold uppercase tracking-wider text-gray-500 mb-4">Quick Actions Panel Controls</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[
            { label: 'Create Mock', icon: <Plus size={15} />, path: '/mocks', color: '#007BFF' },
            { label: 'Add Content', icon: <BookOpen size={15} />, path: '/preparation', color: '#8B5CF6' },
            { label: 'View Users', icon: <Users size={15} />, path: '/users', color: '#28A745' },
            { label: 'Analytics', icon: <Activity size={15} />, path: '/analytics', color: '#F59E0B' },
          ].map(action => (
            <button
              key={action.label}
              onClick={() => navigate(action.path)}
              className="flex items-center justify-center gap-2 px-4 py-3 rounded-xl text-sm font-semibold transition-all hover:opacity-90 shadow-sm active:scale-[0.98]"
              style={{ background: `${action.color}12`, color: action.color, border: `1px solid ${action.color}25` }}
            >
              {action.icon}
              {action.label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}