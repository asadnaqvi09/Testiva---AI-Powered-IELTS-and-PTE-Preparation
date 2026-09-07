-- Paid exam track unlock (Stripe / admin). NULL = fall back to preference.
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS unlocked_exam VARCHAR(10) DEFAULT NULL;

COMMENT ON COLUMN public.users.unlocked_exam IS 'IELTS | PTE | BOTH | NULL — set by Stripe payment or admin override';

-- Optional payments ledger for idempotent Stripe webhooks
CREATE TABLE IF NOT EXISTS public.payment_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  stripe_session_id TEXT UNIQUE,
  stripe_payment_intent TEXT,
  plan TEXT NOT NULL,
  unlocked_exam TEXT,
  subscription TEXT,
  amount_total INTEGER,
  currency TEXT,
  status TEXT DEFAULT 'completed',
  raw_payload JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_events_user_id ON public.payment_events(user_id);

-- Ensure community preference fan-out notification types exist
DO $$ BEGIN
  ALTER TYPE public.notification_type ADD VALUE IF NOT EXISTS 'preference_new_post';
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
  ALTER TYPE public.notification_type ADD VALUE IF NOT EXISTS 'preference_change_request';
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
