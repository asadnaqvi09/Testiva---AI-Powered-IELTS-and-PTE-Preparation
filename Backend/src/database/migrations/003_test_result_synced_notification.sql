-- Notify users when offline test results finish syncing and evaluation completes.
ALTER TYPE public.notification_type ADD VALUE IF NOT EXISTS 'test_result_synced';
