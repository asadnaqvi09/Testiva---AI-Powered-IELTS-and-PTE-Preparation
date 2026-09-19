import React, { useState, useEffect } from 'react';
import { CreditCard, TrendingUp, Users, Unlock, Loader2 } from 'lucide-react';
import { getDashboardStats, getPaymentPlansAPI } from '../services/api';
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

const PLAN_COLORS: Record<string, string> = {
  basic: '#007BFF',
  basic_ielts: '#007BFF',
  basic_pte: '#8B5CF6',
  premium: '#28A745',
};

type PlanCard = {
  plan: string;
  label: string;
  price_label: string;
  unlocked_exam: string;
  subscription: string;
  desc?: string;
};

export function Subscriptions() {
  const [loading, setLoading] = useState(true);
  const [plans, setPlans] = useState<PlanCard[]>([]);
  const [stripeOk, setStripeOk] = useState(false);
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
    async function load() {
      try {
        setLoading(true);
        const [statsRes, plansRes] = await Promise.all([
          getDashboardStats().catch(() => null),
          getPaymentPlansAPI().catch(() => null),
        ]);

        if (statsRes?.success && statsRes.data) {
          setDbMetrics({
            totalUsers: parseInt(statsRes.data.total_users || '0', 10),
            freeUsers: parseInt(statsRes.data.free_users || '0', 10),
            basicUsers: parseInt(statsRes.data.basic_users || '0', 10),
            premiumUsers: parseInt(statsRes.data.premium_users || '0', 10),
            unlockedIelts: parseInt(statsRes.data.unlocked_ielts || '0', 10),
            unlockedPte: parseInt(statsRes.data.unlocked_pte || '0', 10),
            unlockedBoth: parseInt(statsRes.data.unlocked_both || '0', 10),
          });
        } else {
          toast.error('Could not load subscription stats.');
        }

        if (plansRes?.success && Array.isArray(plansRes.data)) {
          setPlans(plansRes.data);
          setStripeOk(!!plansRes.stripe_configured);
        } else {
          toast.error('Could not load payment plans.');
        }
      } catch {
        toast.error('Could not load subscription data.');
      } finally {
        setLoading(false);
      }
    }
    load();
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
          Live tier counts and plans from the payments API (manage individuals on Users)
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

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {plans.map(plan => {
          const color = PLAN_COLORS[plan.plan] || PLAN_COLORS[plan.subscription] || '#007BFF';
          return (
            <div key={plan.plan} className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
              <div className="flex items-center justify-between mb-2">
                <h3 className="font-semibold" style={{ color: '#1A1A1A' }}>{plan.label}</h3>
                <span className="text-sm font-bold" style={{ color }}>{plan.price_label}/mo</span>
              </div>
              <p className="text-sm text-gray-600">{plan.desc || `${plan.subscription} plan`}</p>
              <p className="text-xs text-gray-400 mt-2">Unlocks: {plan.unlocked_exam}</p>
            </div>
          );
        })}
      </div>

      <div className="bg-white rounded-xl border p-5 shadow-sm" style={{ borderColor: '#E5E7EB' }}>
        <p className="text-sm text-gray-600">
          Stripe Checkout is {stripeOk ? 'configured' : 'not configured'} on the backend.
          Change a user’s plan and unlocked exam from the Users page.
        </p>
      </div>
    </div>
  );
}
