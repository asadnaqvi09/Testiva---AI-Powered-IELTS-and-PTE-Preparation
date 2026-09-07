import React, { useState, useEffect } from 'react';
import { BarChart2, TrendingUp, Users, Award, Loader2 } from 'lucide-react';
import {
  PieChart, Pie, Cell, ResponsiveContainer
} from 'recharts';
import { getDashboardStats } from '../services/api';
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

export function Analytics() {
  const [loading, setLoading] = useState(true);
  const [dbMetrics, setDbMetrics] = useState({
    totalUsers: 0,
    freeUsers: 0,
    basicUsers: 0,
    premiumUsers: 0,
    activeUsers: 0,
    unlockedIelts: 0,
    unlockedPte: 0,
    unlockedBoth: 0,
  });

  useEffect(() => {
    async function fetchLiveMetrics() {
      try {
        setLoading(true);
        const res = await getDashboardStats().catch(() => null);
        if (res?.success && res.data) {
          setDbMetrics({
            totalUsers: parseInt(res.data.total_users || '0', 10),
            freeUsers: parseInt(res.data.free_users || '0', 10),
            basicUsers: parseInt(res.data.basic_users || '0', 10),
            premiumUsers: parseInt(res.data.premium_users || '0', 10),
            activeUsers: parseInt(res.data.active_users || '0', 10),
            unlockedIelts: parseInt(res.data.unlocked_ielts || '0', 10),
            unlockedPte: parseInt(res.data.unlocked_pte || '0', 10),
            unlockedBoth: parseInt(res.data.unlocked_both || '0', 10),
          });
        } else {
          toast.error('Could not load analytics stats.');
        }
      } catch (err) {
        console.error('Failed syncing analytics:', err);
        toast.error('Could not load analytics stats.');
      } finally {
        setLoading(false);
      }
    }
    fetchLiveMetrics();
  }, []);

  const subscriptionPieData = [
    { name: 'Free', value: dbMetrics.freeUsers, color: '#6C757D' },
    { name: 'Basic', value: dbMetrics.basicUsers, color: '#007BFF' },
    { name: 'Premium', value: dbMetrics.premiumUsers, color: '#28A745' },
  ].filter(item => item.value > 0);

  const unlockPieData = [
    { name: 'IELTS', value: dbMetrics.unlockedIelts, color: '#007BFF' },
    { name: 'PTE', value: dbMetrics.unlockedPte, color: '#8B5CF6' },
    { name: 'Both', value: dbMetrics.unlockedBoth, color: '#28A745' },
  ].filter(item => item.value > 0);

  const finalSubPie = subscriptionPieData.length > 0
    ? subscriptionPieData
    : [{ name: 'No Users Yet', value: 1, color: '#E5E7EB' }];

  const finalUnlockPie = unlockPieData.length > 0
    ? unlockPieData
    : [{ name: 'No unlocks yet', value: 1, color: '#E5E7EB' }];

  if (loading) {
    return (
      <div className="h-[70vh] w-full flex flex-col items-center justify-center gap-3">
        <Loader2 className="animate-spin text-blue-600" size={36} />
        <p className="text-sm font-medium text-gray-500">Loading platform metrics…</p>
      </div>
    );
  }

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      <div>
        <h1 style={{ color: '#1A1A1A' }}>Analytics</h1>
        <p className="text-sm text-gray-500 mt-0.5">
          Live user and subscription counts from the database (MVP snapshot)
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon={<Users size={20} />} label="Total Users" value={dbMetrics.totalUsers} sub="Registered profiles" color="#007BFF" />
        <StatCard icon={<TrendingUp size={20} />} label="Active (7 days)" value={dbMetrics.activeUsers} sub="Logged in recently" color="#28A745" />
        <StatCard icon={<Award size={20} />} label="Paid Subscribers" value={dbMetrics.basicUsers + dbMetrics.premiumUsers} sub={`${dbMetrics.basicUsers} basic · ${dbMetrics.premiumUsers} premium`} color="#F59E0B" />
        <StatCard icon={<BarChart2 size={20} />} label="Full Unlock (Both)" value={dbMetrics.unlockedBoth} sub="IELTS + PTE access" color="#8B5CF6" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Subscription Mix</h3>
          <p className="text-xs text-gray-400 mb-4">Live tier segmentation</p>
          <div className="h-44 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={finalSubPie} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="value" paddingAngle={dbMetrics.totalUsers > 0 ? 4 : 0}>
                  {finalSubPie.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap gap-3 justify-center mt-3">
            {dbMetrics.totalUsers === 0 ? (
              <span className="text-xs text-gray-400">No users yet</span>
            ) : (
              finalSubPie.map(d => (
                <div key={d.name} className="flex items-center gap-1.5 text-xs">
                  <div className="w-2.5 h-2.5 rounded-full" style={{ background: d.color }} />
                  <span className="text-gray-500 font-medium">{d.name} ({d.value})</span>
                </div>
              ))
            )}
          </div>
        </div>

        <div className="bg-white rounded-xl p-5 border shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Exam Unlock Status</h3>
          <p className="text-xs text-gray-400 mb-4">Paid exam access (`unlocked_exam`)</p>
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
            {unlockPieData.length === 0 ? (
              <span className="text-xs text-gray-400">No paid unlocks yet</span>
            ) : (
              finalUnlockPie.map(d => (
                <div key={d.name} className="flex items-center gap-1.5 text-xs">
                  <div className="w-2.5 h-2.5 rounded-full" style={{ background: d.color }} />
                  <span className="text-gray-500 font-medium">{d.name} ({d.value})</span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
        <p className="text-sm text-gray-600">
          Historical charts, revenue trends, and score averages are not part of this MVP.
          Use <strong>Users</strong> to manage subscriptions and exam unlocks.
        </p>
      </div>
    </div>
  );
}
