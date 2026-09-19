import pool from "../src/config/db.js";

try {
  await pool.query(`
    ALTER TABLE public.users
      ADD COLUMN IF NOT EXISTS theme character varying(20) DEFAULT 'light',
      ADD COLUMN IF NOT EXISTS notif_prefs jsonb DEFAULT '{"newUser":true,"subChange":true,"newPost":true,"preferenceChange":true}'::jsonb
  `);
  await pool.query(`
    ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_theme_check
  `);
  await pool.query(`
    ALTER TABLE public.users
      ADD CONSTRAINT users_theme_check
      CHECK (theme IS NULL OR theme = ANY (ARRAY['light'::text, 'dark'::text, 'system'::text]))
  `);
  console.log("OK: theme + notif_prefs columns ready");
} catch (e) {
  console.error("Migration failed:", e.message);
  process.exitCode = 1;
} finally {
  await pool.end();
}
