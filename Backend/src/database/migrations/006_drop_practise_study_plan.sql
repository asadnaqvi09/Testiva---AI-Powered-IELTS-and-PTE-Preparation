-- Drop Practise + Study Plan tables (modules removed from product scope).
-- Safe to re-run.

DROP TABLE IF EXISTS public.practice_responses CASCADE;
DROP TABLE IF EXISTS public.practice_sessions CASCADE;
DROP TABLE IF EXISTS public.study_plan_items CASCADE;
DROP TABLE IF EXISTS public.study_plans CASCADE;
