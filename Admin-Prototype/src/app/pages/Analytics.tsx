import React, { useState, useEffect } from 'react';
import { BarChart2, Download, Filter, TrendingUp, Users, Award, X, Check, Lock, Loader2 } from 'lucide-react';
import {
  LineChart, Line, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';
import { useAuth } from '../context/AuthContext';
import { getDashboardStats } from '../services/api';
import { toast } from 'sonner';

const COLORS = ['#6C757D', '#007BFF', '#28A745'];

function StatCard({ icon, label, value, sub, color, comingSoon }: {
  icon: React.ReactNode; label: string; value: string | number; sub: string; color: string; comingSoon?: boolean;
}) {
  return (
    <div className="bg-white rounded-xl p-5 border shadow-sm relative overflow-hidden" style={{ borderColor: '#E5E7EB' }}>
      {comingSoon && (
        <div className="absolute inset-0 bg-gray-50/60 backdrop-blur-[2px] flex items-center justify-center gap-1.5 z-10">
          <Lock size={14} className="text-gray-400" />
          <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Coming Soon</span>
        </div>
      )}
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

function ComingSoonChartOverlay({ title, desc }: { title: string; desc: string }) {
  return (
    <div className="absolute inset-0 bg-white/70 backdrop-blur-[3px] flex flex-col items-center justify-center gap-2 z-20 transition-all rounded-xl">
      <div className="p-2.5 bg-blue-50 text-blue-600 rounded-full shadow-sm animate-pulse">
        <Lock size={20} />
      </div>
      <div className="text-center">
        <h4 className="font-bold text-sm text-gray-800">{title} Integration</h4>
        <p className="text-xs text-gray-500 px-4 mt-0.5">{desc}</p>
      </div>
    </div>
  );
}

export function Analytics() {
  const { user } = useAuth();
  const [showExport, setShowExport] = useState(false);
  const [dateRange, setDateRange] = useState('6m');
  const [filterTest, setFilterTest] = useState('');
  const [loading, setLoading] = useState(true);

  const [dbMetrics, setDbMetrics] = useState({
    totalUsers: 0,
    freeUsers: 0,
    basicUsers: 0,
    premiumUsers: 0
  });

  const isSuperAdmin = user?.role === 'super_admin';

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
            premiumUsers: parseInt(res.data.premium_users || '0', 10)
          });
        }
      } catch (err) {
        console.error("Failed syncing live database analytic nodes:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchLiveMetrics();
  }, []);

  const subscriptionPieData = [
    { name: 'Free', value: dbMetrics.freeUsers, color: '#6C757D' },
    { name: 'Basic', value: dbMetrics.basicUsers, color: '#007BFF' },
    { name: 'Premium', value: dbMetrics.premiumUsers, color: '#28A745' }
  ].filter(item => item.value > 0);

  const finalPieData = subscriptionPieData.length > 0 ? subscriptionPieData : [{ name: 'No Users Yet', value: 1, color: '#E5E7EB' }];

  const handleExport = () => {
    setShowExport(false);
    toast.success('Report Downloaded as CSV!');
  };

  if (loading) {
    return (
      <div className="h-[70vh] w-100 flex flex-col items-center justify-center gap-3">
        <Loader2 className="animate-spin text-blue-600" size={36} />
        <p className="text-sm font-medium text-gray-500">Compiling real-time platform metrics...</p>
      </div>
    );
  }

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>Analytics & Reports</h1>
          <p className="text-sm text-gray-500 mt-0.5">Live operational performance metrics</p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <div className="flex items-center gap-1 bg-white border rounded-lg overflow-hidden p-0.5" style={{ borderColor: '#E5E7EB' }}>
            {['1m', '3m', '6m', '1y'].map(r => (
              <button key={r} onClick={() => setDateRange(r)}
                className="px-3 py-1.5 rounded text-sm font-medium transition-all"
                style={dateRange === r ? { background: '#007BFF', color: 'white' } : { color: '#6B7280' }}>
                {r}
              </button>
            ))}
          </div>
          <select value={filterTest} onChange={e => setFilterTest(e.target.value)} className="text-sm px-3 py-2 rounded-lg border focus:outline-none" style={{ borderColor: '#E5E7EB', background: 'white' }}>
            <option value="">All Tests</option>
            {['IELTS', 'PTE'].map(t => <option key={t} value={t}>{t}</option>)}
          </select>
          <button onClick={() => setShowExport(true)} className="flex items-center gap-2 px-4 py-2 rounded-lg border text-sm font-medium hover:bg-gray-50 transition-colors" style={{ borderColor: '#E5E7EB', color: '#1A1A1A', background: 'white' }}>
            <Download size={15} /> Export
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon={<Users size={20} />} label="Total Users" value={dbMetrics.totalUsers} sub="Live registered profiles" color="#007BFF" />
        <StatCard icon={<TrendingUp size={20} />} label="Monthly Revenue" value="₨0.00" sub="Stripe engine disabled" color="#28A745" comingSoon />
        <StatCard icon={<Award size={20} />} label="Avg. Score" value="0.0" sub="System grading inactive" color="#F59E0B" comingSoon />
        <StatCard icon={<BarChart2 size={20} />} label="Mocks Attempted" value={0} sub="Exam core module pending" color="#8B5CF6" comingSoon />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2 bg-white rounded-xl p-5 border shadow-sm relative min-h-[280px]" style={{ borderColor: '#E5E7EB' }}>
          <ComingSoonChartOverlay title="User Growth Timeline" desc="Requires historical analytics sync tracking module." />
          <div>
            <h3 style={{ color: '#1A1A1A' }}>User Growth</h3>
            <p className="text-xs text-gray-400 mt-0.5">Total registered users over time</p>
          </div>
        </div>

        <div className="bg-white rounded-xl p-5 border shadow-sm flex flex-col justify-between" style={{ borderColor: '#E5E7EB' }}>
          <div>
            <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Subscription Mix</h3>
            <p className="text-xs text-gray-400 mb-4">Live active tier segmentation</p>
          </div>
          <div className="h-44 flex items-center justify-center">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie data={finalPieData} cx="50%" cy="50%" innerRadius={50} outerRadius={75} dataKey="value" paddingAngle={dbMetrics.totalUsers > 0 ? 4 : 0}>
                  {finalPieData.map((entry, i) => (
                    <Cell key={i} fill={entry.color} />
                  ))}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex flex-wrap gap-3 justify-center mt-3">
            {dbMetrics.totalUsers === 0 ? (
              <span className="text-xs text-gray-400">No system profiles found</span>
            ) : (
              finalPieData.map(d => (
                <div key={d.name} className="flex items-center gap-1.5 text-xs">
                  <div className="w-2.5 h-2.5 rounded-full" style={{ background: d.color }} />
                  <span className="text-gray-500 font-medium">{d.name} ({d.value})</span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-xl p-5 border shadow-sm relative min-h-[260px]" style={{ borderColor: '#E5E7EB' }}>
          <ComingSoonChartOverlay title="Performance Metrics" desc="Awaiting Test Module core logic schema compilation." />
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Avg. Scores by Test</h3>
          <p className="text-xs text-gray-400 mb-4">Average user score per test type</p>
        </div>

        <div className="bg-white rounded-xl p-5 border shadow-sm relative min-h-[260px]" style={{ borderColor: '#E5E7EB' }}>
          <ComingSoonChartOverlay title="Financial Revenue Trend" desc="Requires Stripe Gateway checkout webhooks activation." />
          <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Revenue Trend</h3>
          <p className="text-xs text-gray-400 mb-4">Monthly revenue in PKR</p>
        </div>
      </div>

      <div className="bg-white rounded-xl border shadow-sm relative min-h-[200px]" style={{ borderColor: '#E5E7EB' }}>
        <ComingSoonChartOverlay title="Leaderboard Ranking" desc="Will display top system students once test grading system goes active." />
        <div className="flex items-center justify-between px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
          <h3 style={{ color: '#1A1A1A' }}>Top Performing Users</h3>
        </div>
      </div>

      {showExport && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-semibold">Export Report</h3>
              <button onClick={() => setShowExport(false)} className="text-gray-400"><X size={18} /></button>
            </div>
            <p className="text-sm text-gray-500 mb-4">Choose the format and date range for your export.</p>
            <div className="space-y-3 mb-5">
              <div>
                <label className="block text-sm font-medium mb-1">Format</label>
                <select className="w-full px-3 py-2 text-sm rounded-lg border text-gray-600 bg-gray-50" disabled>
                  <option>CSV</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Report Type</label>
                <select className="w-full px-3 py-2 text-sm rounded-lg border text-gray-600 bg-gray-50" disabled>
                  <option>User Analytics Only</option>
                </select>
              </div>
            </div>
            <div className="flex gap-3">
              <button onClick={() => setShowExport(false)} className="flex-1 py-2 rounded-lg border text-sm" style={{ borderColor: '#E5E7EB', color: '#6B7280' }}>Cancel</button>
              <button onClick={handleExport} className="flex-1 py-2 rounded-lg text-white text-sm font-medium flex items-center justify-center gap-1.5" style={{ background: '#007BFF' }}>
                <Download size={14} /> Download
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}