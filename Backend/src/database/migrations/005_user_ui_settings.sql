-- Admin/user UI prefs: theme + TopBar notification filters (server-backed)
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS theme character varying(20) DEFAULT 'light',
  ADD COLUMN IF NOT EXISTS notif_prefs jsonb DEFAULT '{"newUser":true,"subChange":true,"newPost":true,"preferenceChange":true}'::jsonb;

ALTER TABLE public.users
  DROP CONSTRAINT IF EXISTS users_theme_check;

ALTER TABLE public.users
  ADD CONSTRAINT users_theme_check
  CHECK (theme IS NULL OR theme = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text]));
