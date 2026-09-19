import React, { useState, useEffect } from 'react';
import { BarChart2, TrendingUp, Users, Award, FileText, BookOpen, MessageSquare, Loader2 } from 'lucide-react';
import {
  PieChart, Pie, Cell, ResponsiveContainer, BarChart, Bar, XAxis, YAxis, Tooltip, CartesianGrid,
} from 'recharts';
import { getAdminAnalyticsAPI } from '../services/api';
import { toast } from 'sonner';

function StatCard({ icon, label, value, sub, color }: {
  icon: React.ReactNode; label: string; value: string | number; sub: string; color: string;
}) {
  return (
    <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
      <div className="flex items-start gap-3">
        <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background: `${color}18` }}>
          <span style={{ color }}>{icon}</span>
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-sm text-gray-500 truncate">{label}</p>
          <p className="font-bold mt-0.5 truncate" style={{ color: '#1A1A1A', fontSize: '20px' }}>{value}</p>
          <p className="text-xs text-gray-400 mt-0.5 truncate">{sub}</p>
        </div>
      </div>
    </div>
  );
}

const n = (v: unknown) => parseInt(String(v ?? '0'), 10) || 0;

export function Analytics() {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<any>(null);

  useEffect(() => {
    async function load() {
      try {
        setLoading(true);
        const res = await getAdminAnalyticsAPI();
        if (res?.success && res.data) setData(res.data);
        else toast.error('Could not load analytics.');
      } catch {
        toast.error('Could not load analytics.');
      } finally {
        setLoading(false);
      }
    }
    load();
  }, []);

  if (loading) {
    return (
      <div className="h-[70vh] w-full flex flex-col items-center justify-center gap-3">
        <Loader2 className="animate-spin text-blue-600" size={36} />
        <p className="text-sm font-medium text-gray-500">Loading platform metrics…</p>
      </div>
    );
  }

  const users = data?.users || {};
  const mocks = data?.mocks || {};
  const prep = data?.prep || {};
  const community = data?.community || {};
  const attempts = data?.attempts || {};
  const regs = (data?.registrations_14d || []) as Array<{ day: string; count: number }>;

  const totalUsers = n(users.total_users);
  const basicUsers = n(users.basic_users);
  const premiumUsers = n(users.premium_users);
  const freeUsers = n(users.free_users);
  const activeUsers = n(users.active_users);
  const unlockedBoth = n(users.unlocked_both);

  const subscriptionPieData = [
    { name: 'Free', value: freeUsers, color: '#6C757D' },
    { name: 'Basic', value: basicUsers, color: '#007BFF' },
    { name: 'Premium', value: premiumUsers, color: '#28A745' },
  ].filter(item => item.value > 0);

  const unlockPieData = [
    { name: 'IELTS', value: n(users.unlocked_ielts), color: '#007BFF' },
    { name: 'PTE', value: n(users.unlocked_pte), color: '#8B5CF6' },
    { name: 'Both', value: unlockedBoth, color: '#28A745' },
  ].filter(item => item.value > 0);

  const mockPie = [
    { name: 'IELTS', value: n(mocks.ielts_mocks), color: '#007BFF' },
    { name: 'PTE', value: n(mocks.pte_mocks), color: '#8B5CF6' },
  ].filter(i => i.value > 0);

  const finalSubPie = subscriptionPieData.length > 0
    ? subscriptionPieData
    : [{ name: 'No Users Yet', value: 1, color: '#E5E7EB' }];

  const finalUnlockPie = unlockPieData.length > 0
    ? unlockPieData
    : [{ name: 'No unlocks yet', value: 1, color: '#E5E7EB' }];

  const finalMockPie = mockPie.length > 0
    ? mockPie
    : [{ name: 'No mocks', value: 1, color: '#E5E7EB' }];

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      <div>
        <h1 style={{ color: '#1A1A1A' }}>Analytics</h1>
        <p className="text-sm text-gray-500 mt-0.5">
          Live platform metrics — users, mocks, prep, community, and attempts
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon={<Users size={20} />} label="Total Users" value={totalUsers} sub="Registered profiles" color="#007BFF" />
        <StatCard icon={<TrendingUp size={20} />} label="Active (7 days)" value={activeUsers} sub="Logged in recently" color="#28A745" />
        <StatCard icon={<Award size={20} />} label="Paid Subscribers" value={basicUsers + premiumUsers} sub={`${basicUsers} basic · ${premiumUsers} premium`} color="#F59E0B" />
        <StatCard icon={<BarChart2 size={20} />} label="Avg Band (completed)" value={Number(attempts.avg_band || 0)} sub={`${n(attempts.completed_attempts)} completed attempts`} color="#8B5CF6" />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon={<FileText size={20} />} label="Mock Tests" value={n(mocks.total_mocks)} sub={`${n(mocks.published_mocks)} published · ${n(mocks.draft_mocks)} drafts`} color="#007BFF" />
        <StatCard icon={<BookOpen size={20} />} label="Prep Lessons" value={n(prep.total_prep)} sub={`${n(prep.published_prep)} published`} color="#F59E0B" />
        <StatCard icon={<MessageSquare size={20} />} label="Community Posts" value={n(community.total_posts)} sub={`${n(community.flagged_posts)} flagged`} color="#8B5CF6" />
        <StatCard icon={<TrendingUp size={20} />} label="Test Attempts" value={n(attempts.total_attempts)} sub={`${n(attempts.offline_attempts)} offline synced`} color="#28A745" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Subscription Mix</h3>
          <p className="text-xs text-gray-400 mb-4">Live tier segmentation</p>
          <div className="h-44 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={finalSubPie} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="value" paddingAngle={totalUsers > 0 ? 4 : 0}>
                  {finalSubPie.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap gap-3 justify-center mt-3">
            {finalSubPie.map(d => (
              <div key={d.name} className="flex items-center gap-1.5 text-xs">
                <div className="w-2.5 h-2.5 rounded-full" style={{ background: d.color }} />
                <span className="text-gray-500 font-medium">{d.name} ({d.value})</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Exam Unlock Status</h3>
          <p className="text-xs text-gray-400 mb-4">Paid exam access</p>
          <div className="h-44 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={finalUnlockPie} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="value" paddingAngle={unlockPieData.length > 0 ? 4 : 0}>
                  {finalUnlockPie.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap gap-3 justify-center mt-3">
            {finalUnlockPie.map(d => (
              <div key={d.name} className="flex items-center gap-1.5 text-xs">
                <div className="w-2.5 h-2.5 rounded-full" style={{ background: d.color }} />
                <span className="text-gray-500 font-medium">{d.name} ({d.value})</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Mocks by Exam</h3>
          <p className="text-xs text-gray-400 mb-4">IELTS vs PTE catalog</p>
          <div className="h-44 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={finalMockPie} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="value" paddingAngle={mockPie.length > 0 ? 4 : 0}>
                  {finalMockPie.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap gap-3 justify-center mt-3">
            {finalMockPie.map(d => (
              <div key={d.name} className="flex items-center gap-1.5 text-xs">
                <div className="w-2.5 h-2.5 rounded-full" style={{ background: d.color }} />
                <span className="text-gray-500 font-medium">{d.name} ({d.value})</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
        <h3 className="mb-1" style={{ color: '#1A1A1A' }}>New Registrations (14 days)</h3>
        <p className="text-xs text-gray-400 mb-4">Daily signups from the database</p>
        <div className="h-56">
          {regs.length === 0 ? (
            <p className="text-sm text-gray-400 text-center py-16">No registrations in the last 14 days</p>
          ) : (
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={regs}>
                <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
                <XAxis dataKey="day" tick={{ fontSize: 10 }} tickFormatter={(v) => String(v).slice(5)} />
                <YAxis allowDecimals={false} tick={{ fontSize: 11 }} />
                <Tooltip />
                <Bar dataKey="count" fill="#007BFF" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>
    </div>
  );
}
