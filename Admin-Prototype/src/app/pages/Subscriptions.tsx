import React, { useState, useEffect } from 'react';
import { CreditCard, TrendingUp, Users, DollarSign, X, Check, ChevronUp, Download, Lock, Loader2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { getDashboardStats } from '../services/api';
import { toast } from 'sonner';

const PLANS = [
  { id: 'basic', name: 'Basic', price: 399, color: '#007BFF', tests: 'IELTS Only', desc: 'Full IELTS prep' },
  { id: 'premium', name: 'Premium', price: 699, color: '#28A745', tests: 'All Tests', desc: 'IELTS + TOEFL + PTE' },
];

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

function ComingSoonOverlay({ title, desc }: { title: string; desc: string }) {
  return (
    <div className="absolute inset-0 bg-white/70 backdrop-blur-[3px] flex flex-col items-center justify-center gap-2 z-20 transition-all rounded-xl">
      <div className="p-2 bg-blue-50 text-blue-600 rounded-full shadow-sm animate-pulse">
        <Lock size={18} />
      </div>
      <div className="text-center px-4">
        <h4 className="font-bold text-sm text-gray-800">{title}</h4>
        <p className="text-xs text-gray-500 mt-0.5 max-w-xs mx-auto">{desc}</p>
      </div>
    </div>
  );
}

export function Subscriptions() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'users' | 'institutes'>('users');
  const [loading, setLoading] = useState(true);
  
  const [dbMetrics, setDbMetrics] = useState({
    totalUsers: 0,
    freeUsers: 0,
    basicUsers: 0,
    premiumUsers: 0
  });

  const isSuperAdmin = user?.role === 'super_admin';

  useEffect(() => {
    async function fetchLiveSubs() {
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
        console.error("Billing sync trace failure:", err);
      } finally {
        setLoading(false);
      }
    }
    fetchLiveSubs();
  }, []);

  const totalActiveSubs = dbMetrics.basicUsers + dbMetrics.premiumUsers;

  if (loading) {
    return (
      <div className="h-[70vh] w-100 flex flex-col items-center justify-center gap-3">
        <Loader2 className="animate-spin text-blue-600" size={36} />
        <p className="text-sm font-medium text-gray-500">Compiling financial ledgers & tier breakdowns...</p>
      </div>
    );
  }

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 style={{ color: '#1A1A1A' }}>Subscriptions & Billing</h1>
          <p className="text-sm text-gray-500 mt-0.5">Manage plans and live tier breakdowns</p>
        </div>
        <button 
          disabled
          className="flex items-center gap-2 px-4 py-2 rounded-lg border text-sm font-medium opacity-50 cursor-not-allowed" 
          style={{ borderColor: '#E5E7EB', color: '#1A1A1A', background: 'white' }}
        >
          <Download size={15} /> Export
        </button>
      </div>

      {/* Stats Layer */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon={<DollarSign size={20} />} label="Monthly Revenue" value="₨0.00" sub="Stripe engine offline" color="#28A745" comingSoon />
        <StatCard icon={<Users size={20} />} label="Premium Subscribers" value={dbMetrics.premiumUsers} sub={`₨${dbMetrics.premiumUsers * 699}/mo (Est.)`} color="#007BFF" />
        <StatCard icon={<CreditCard size={20} />} label="Basic Subscribers" value={dbMetrics.basicUsers} sub={`₨${dbMetrics.basicUsers * 399}/mo (Est.)`} color="#F59E0B" />
        <StatCard icon={<TrendingUp size={20} />} label="Total Active Subs" value={totalActiveSubs} sub="Across all premium tiers" color="#8B5CF6" />
      </div>

      {/* Revenue Chart Component (Coming Soon) */}
      <div className="bg-white rounded-xl p-5 border shadow-sm relative min-h-[240px]" style={{ borderColor: '#E5E7EB' }}>
        <ComingSoonOverlay title="Revenue Analytical Trend" desc="Awaiting historical gateway ledger synchronization charts module." />
        <h3 className="mb-1" style={{ color: '#1A1A1A' }}>Revenue Summary (Last 6 Months)</h3>
        <p className="text-xs text-gray-400 mb-4">Monthly subscription revenue in PKR</p>
      </div>

      {/* Navigation Sub-Tabs */}
      {isSuperAdmin && (
        <div className="flex gap-1 bg-white border rounded-lg p-1 w-fit" style={{ borderColor: '#E5E7EB' }}>
          {(['users', 'institutes'] as const).map(tab => (
            <button key={tab} onClick={() => setActiveTab(tab)}
              className="px-4 py-1.5 rounded text-sm font-medium transition-all capitalize"
              style={activeTab === tab ? { background: '#007BFF', color: 'white' } : { color: '#6B7280' }}>
              {tab}
            </button>
          ))}
        </div>
      )}

      {/* User Accounts Grid Panel */}
      {(!isSuperAdmin || activeTab === 'users') && (
        <div className="bg-white rounded-xl border shadow-sm relative min-h-[250px]" style={{ borderColor: '#E5E7EB' }}>
          <ComingSoonOverlay title="User Subscription Matrix" desc="Stripe webhook billing table pipelines are currently under construction." />
          <div className="px-5 py-4 border-b flex items-center justify-between" style={{ borderColor: '#E5E7EB' }}>
            <h3 style={{ color: '#1A1A1A' }}>User Subscriptions</h3>
            <span className="text-xs text-gray-400">{dbMetrics.totalUsers} registered profiles</span>
          </div>
        </div>
      )}

      {/* Institute Accounts Grid Panel */}
      {isSuperAdmin && activeTab === 'institutes' && (
        <div className="bg-white rounded-xl border shadow-sm relative min-h-[250px]" style={{ borderColor: '#E5E7EB' }}>
          <ComingSoonOverlay title="B2B Institute Invoicing" desc="Automated monthly ledger distribution engines are coming soon." />
          <div className="px-5 py-4 border-b" style={{ borderColor: '#E5E7EB' }}>
            <h3 style={{ color: '#1A1A1A' }}>Institute Billing</h3>
          </div>
        </div>
      )}
    </div>
  );
}