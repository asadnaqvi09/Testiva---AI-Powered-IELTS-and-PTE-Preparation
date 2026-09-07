import React, { useState, useEffect } from 'react';
import { CreditCard, TrendingUp, Users, Unlock, Loader2 } from 'lucide-react';
import { getDashboardStats } from '../services/api';
import { toast } from 'sonner';

const PLANS = [
  { id: 'basic', name: 'Basic', price: 399, color: '#007BFF', tests: 'IELTS or PTE', desc: 'Single-exam unlock via Stripe' },
  { id: 'premium', name: 'Premium', price: 699, color: '#28A745', tests: 'IELTS + PTE', desc: 'Full unlock (BOTH exams)' },
];

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

export function Subscriptions() {
  const [loading, setLoading] = useState(true);
  const [dbMetrics, setDbMetrics] = useState({
    totalUsers: 0,
    freeUsers: 0,
    basicUsers: 0,
    premiumUsers: 0,
    unlockedIelts: 0,
    unlockedPte: 0,
    unlockedBoth: 0,
  });

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
            premiumUsers: parseInt(res.data.premium_users || '0', 10),
            unlockedIelts: parseInt(res.data.unlocked_ielts || '0', 10),
            unlockedPte: parseInt(res.data.unlocked_pte || '0', 10),
            unlockedBoth: parseInt(res.data.unlocked_both || '0', 10),
          });
        } else {
          toast.error('Could not load subscription stats.');
        }
      } catch (err) {
        console.error('Billing sync failure:', err);
        toast.error('Could not load subscription stats.');
      } finally {
        setLoading(false);
      }
    }
    fetchLiveSubs();
  }, []);

  const totalActiveSubs = dbMetrics.basicUsers + dbMetrics.premiumUsers;

  if (loading) {
    return (
      <div className="h-[70vh] w-full flex flex-col items-center justify-center gap-3">
        <Loader2 className="animate-spin text-blue-600" size={36} />
        <p className="text-sm font-medium text-gray-500">Loading subscription breakdown…</p>
      </div>
    );
  }

  return (
    <div className="space-y-5 max-w-7xl mx-auto">
      <div>
        <h1 style={{ color: '#1A1A1A' }}>Subscriptions</h1>
        <p className="text-sm text-gray-500 mt-0.5">
          Live tier and exam-unlock counts (manage individuals on Users)
        </p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard icon={<Users size={20} />} label="Free Users" value={dbMetrics.freeUsers} sub="No paid plan" color="#6C757D" />
        <StatCard icon={<CreditCard size={20} />} label="Basic Subscribers" value={dbMetrics.basicUsers} sub="Single-exam plans" color="#F59E0B" />
        <StatCard icon={<TrendingUp size={20} />} label="Premium Subscribers" value={dbMetrics.premiumUsers} sub="Full access" color="#007BFF" />
        <StatCard icon={<Unlock size={20} />} label="Total Paid" value={totalActiveSubs} sub={`${dbMetrics.totalUsers} registered total`} color="#8B5CF6" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <p className="text-xs font-semibold uppercase text-gray-400">Unlocked IELTS</p>
          <p className="text-2xl font-bold mt-1" style={{ color: '#1A1A1A' }}>{dbMetrics.unlockedIelts}</p>
        </div>
        <div className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <p className="text-xs font-semibold uppercase text-gray-400">Unlocked PTE</p>
          <p className="text-2xl font-bold mt-1" style={{ color: '#1A1A1A' }}>{dbMetrics.unlockedPte}</p>
        </div>
        <div className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
          <p className="text-xs font-semibold uppercase text-gray-400">Unlocked Both</p>
          <p className="text-2xl font-bold mt-1" style={{ color: '#1A1A1A' }}>{dbMetrics.unlockedBoth}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {PLANS.map(plan => (
          <div key={plan.id} className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
            <div className="flex items-center justify-between mb-2">
              <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>{plan.name}</h3>
              <span className="text-sm font-bold" style={{ color: plan.color }}>₨{plan.price}/mo</span>
            </div>
            <p className="text-sm text-gray-600">{plan.desc}</p>
            <p className="text-xs text-gray-400 mt-2">Includes: {plan.tests}</p>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
        <p className="text-sm text-gray-600">
          Stripe Checkout is live in the mobile app. Detailed billing ledgers and CSV export are outside this MVP —
          change a user’s plan and <code className="text-xs bg-gray-100 px-1 rounded">unlocked_exam</code> from the Users page.
        </p>
      </div>
    </div>
  );
}
