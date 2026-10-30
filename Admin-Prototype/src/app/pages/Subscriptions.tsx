import React, { useState, useEffect } from 'react';
import { CreditCard, TrendingUp, Users, Unlock, Loader2 } from 'lucide-react';
import {
  getDashboardStats,
  getPaymentPlansAPI,
  getPaymentEventsAPI,
} from '../services/api';
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

type PaymentEventRow = {
  id: string;
  user_id: string | null;
  full_name?: string;
  email?: string;
  plan: string;
  amount_total: number | null;
  currency: string | null;
  status: string;
  stripe_session_id: string;
  created_at: string;
};

function formatAmount(amount: number | null, currency: string | null) {
  if (amount == null) return '—';
  const major = amount / 100;
  return `${currency || 'PKR'} ${major.toLocaleString()}`;
}

export function Subscriptions() {
  const [loading, setLoading] = useState(true);
  const [plans, setPlans] = useState<PlanCard[]>([]);
  const [stripeOk, setStripeOk] = useState(false);
  const [events, setEvents] = useState<PaymentEventRow[]>([]);
  const [eventsMeta, setEventsMeta] = useState({ page: 1, total: 0, total_pages: 1 });
  const [dbMetrics, setDbMetrics] = useState({
    totalUsers: 0,
    freeUsers: 0,
    basicUsers: 0,
    premiumUsers: 0,
    unlockedIelts: 0,
    unlockedPte: 0,
    unlockedBoth: 0,
  });

  async function loadEvents(page = 1) {
    try {
      const eventsRes = await getPaymentEventsAPI({ page, limit: 15 });
      if (eventsRes?.success && eventsRes.data) {
        setEvents(eventsRes.data.items || []);
        setEventsMeta({
          page: eventsRes.data.meta?.page || page,
          total: eventsRes.data.meta?.total || 0,
          total_pages: eventsRes.data.meta?.total_pages || 1,
        });
      }
    } catch {
      toast.error('Could not load payment events.');
    }
  }

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

        await loadEvents(1);
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
          Live tier counts, plans, and Stripe payment event ledger
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
        <div className="flex items-center justify-between mb-3 gap-3 flex-wrap">
          <div>
            <h2 className="font-semibold" style={{ color: '#1A1A1A' }}>Payment event log</h2>
            <p className="text-xs text-gray-500 mt-0.5">{eventsMeta.total} events · Stripe Checkout ledger</p>
          </div>
          <div className="flex items-center gap-2">
            <button
              type="button"
              disabled={eventsMeta.page <= 1}
              onClick={() => loadEvents(eventsMeta.page - 1)}
              className="text-sm px-3 py-1.5 rounded-lg border disabled:opacity-40"
            >
              Prev
            </button>
            <span className="text-xs text-gray-500">
              Page {eventsMeta.page} / {eventsMeta.total_pages}
            </span>
            <button
              type="button"
              disabled={eventsMeta.page >= eventsMeta.total_pages}
              onClick={() => loadEvents(eventsMeta.page + 1)}
              className="text-sm px-3 py-1.5 rounded-lg border disabled:opacity-40"
            >
              Next
            </button>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm text-left">
            <thead>
              <tr className="text-xs uppercase text-gray-400 border-b" style={{ borderColor: '#E5E7EB' }}>
                <th className="py-2 pr-3 font-semibold">User</th>
                <th className="py-2 pr-3 font-semibold">Plan</th>
                <th className="py-2 pr-3 font-semibold">Amount</th>
                <th className="py-2 pr-3 font-semibold">Status</th>
                <th className="py-2 pr-3 font-semibold">Session</th>
                <th className="py-2 font-semibold">Date</th>
              </tr>
            </thead>
            <tbody>
              {events.length === 0 ? (
                <tr>
                  <td colSpan={6} className="py-8 text-center text-gray-400">
                    No payment events yet
                  </td>
                </tr>
              ) : (
                events.map((ev) => (
                  <tr key={ev.id} className="border-b last:border-0" style={{ borderColor: '#F3F4F6' }}>
                    <td className="py-2.5 pr-3">
                      <div className="font-medium text-gray-800 truncate max-w-[160px]">
                        {ev.full_name || '—'}
                      </div>
                      <div className="text-xs text-gray-400 truncate max-w-[160px]">{ev.email || ''}</div>
                    </td>
                    <td className="py-2.5 pr-3">{ev.plan}</td>
                    <td className="py-2.5 pr-3">{formatAmount(ev.amount_total, ev.currency)}</td>
                    <td className="py-2.5 pr-3">{ev.status}</td>
                    <td className="py-2.5 pr-3 font-mono text-xs text-gray-500">
                      {(ev.stripe_session_id || '').slice(0, 14)}…
                    </td>
                    <td className="py-2.5 text-xs text-gray-500 whitespace-nowrap">
                      {ev.created_at ? new Date(ev.created_at).toLocaleString() : '—'}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
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
