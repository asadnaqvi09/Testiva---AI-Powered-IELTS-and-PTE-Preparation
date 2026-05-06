SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;

-- ============================================
-- CUSTOM TYPES
-- ============================================

CREATE TYPE public.attempt_status_enum AS ENUM (
    'in_progress',
    'completed',
    'synced'
);

CREATE TYPE public.lesson_section_enum AS ENUM (
    'Reading',
    'Listening',
    'Writing',
    'Speaking',
    'Speaking & Writing'
);

CREATE TYPE public.lesson_status_enum AS ENUM (
    'draft',
    'published'
);

CREATE TYPE public.otp_type AS ENUM (
    'register',
    'reset'
);

CREATE TYPE public.subscription_status_enum AS ENUM (
    'free',
    'basic',
    'premium'
);

CREATE TYPE public.test_type_enum AS ENUM (
    'IELTS',
    'PTE'
);

CREATE TYPE public.user_role_enum AS ENUM (
    '',
    'user',
    'admin'
);

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    email character varying(255) UNIQUE,
    password_hash text,
    full_name character varying(150),
    avatar_url text,
    auth_provider character varying(50) DEFAULT 'email',
    role public.user_role_enum DEFAULT 'user' NOT NULL,
    is_email_verified boolean DEFAULT false,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    subscription public.subscription_status_enum DEFAULT 'free' NOT NULL,
    token_version integer DEFAULT 0,
    bio text DEFAULT 'No bio provided'
);

CREATE TABLE public.admin_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    admin_id uuid NOT NULL,
    action character varying(50) NOT NULL,
    target_user_id uuid,
    details jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.refresh_tokens (
    id serial PRIMARY KEY,
    user_id uuid NOT NULL,
    token text NOT NULL UNIQUE,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);

CREATE TABLE public.temp_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    email character varying(255) NOT NULL UNIQUE,
    full_name character varying(150),
    password_hash text,
    otp_code text,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    type character varying(20) DEFAULT 'register' NOT NULL,
    is_verified boolean DEFAULT false,
    attempts integer DEFAULT 0,
    CONSTRAINT temp_users_email_type_unique UNIQUE (email, type)
);

CREATE TABLE public.tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    title character varying(255) NOT NULL,
    is_full_mock boolean DEFAULT false,
    total_time_minutes integer NOT NULL,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    exam_type public.test_type_enum NOT NULL
);

CREATE TABLE public.test_sections (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    test_id uuid,
    section_name public.lesson_section_enum NOT NULL,
    time_limit_minutes integer NOT NULL,
    order_number integer NOT NULL,
    instructions text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_test_section_order UNIQUE (test_id, order_number)
);

CREATE TABLE public.questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    section_id uuid,
    question_type character varying(50) NOT NULL,
    passage_text text,
    question_text text NOT NULL,
    options jsonb,
    correct_answer text,
    audio_url text,
    order_number integer NOT NULL,
    marks integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.test_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    user_id uuid,
    test_id uuid,
    overall_band_score numeric(3,1) DEFAULT 0.0,
    writing_score numeric(3,1) DEFAULT 0.0,
    reading_score numeric(3,1) DEFAULT 0.0,
    listening_score numeric(3,1) DEFAULT 0.0,
    speaking_score numeric(3,1) DEFAULT 0.0,
    feedback text,
    status public.attempt_status_enum DEFAULT 'in_progress',
    is_offline boolean DEFAULT false,
    client_started_at timestamp without time zone NOT NULL,
    client_completed_at timestamp without time zone,
    server_synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    attempt_id uuid,
    question_id uuid,
    user_answer text,
    audio_response_url text,
    is_correct boolean,
    marks_obtained numeric(3,1) DEFAULT 0.0,
    ai_feedback_per_question text,
    client_created_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.ai_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES test_attempts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id), -- Type matched with users table
    overall_band_score DECIMAL(3, 1) DEFAULT 0.0,
    task_response_score DECIMAL(3, 1),
    coherence_cohesion_score DECIMAL(3, 1),
    lexical_resource_score DECIMAL(3, 1),
    grammatical_range_score DECIMAL(3, 1),
    detailed_analysis JSONB, -- Stores strengths/weaknesses/mistakes
    improvement_suggestions TEXT,
    model_used VARCHAR(50) DEFAULT 'gemini-1.5-flash',
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_progress_stats (
    user_id uuid NOT NULL PRIMARY KEY,
    total_tests_taken integer DEFAULT 0,
    average_band_score numeric(3,1) DEFAULT 0.0,
    last_test_date timestamp without time zone,
    highest_score numeric(3,1) DEFAULT 0.0,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.lessons (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    title character varying(255) NOT NULL,
    test_type public.test_type_enum NOT NULL,
    section public.lesson_section_enum NOT NULL,
    summary text,
    status public.lesson_status_enum DEFAULT 'draft' NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    min_subscription character varying(20) DEFAULT 'free' NOT NULL
);

CREATE TABLE public.lesson_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    lesson_id uuid NOT NULL,
    part_title character varying(255) NOT NULL,
    part_content text NOT NULL,
    order_number integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    part_type character varying(20),
    media_url text,
    CONSTRAINT unique_part_order UNIQUE (lesson_id, order_number)
);

CREATE TABLE public.practice_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    user_id uuid NOT NULL,
    section_name character varying(50) NOT NULL,
    question_type character varying(50),
    difficulty_level integer DEFAULT 1,
    status character varying(20) DEFAULT 'in_progress',
    total_questions integer DEFAULT 0,
    correct_answers integer DEFAULT 0,
    accuracy numeric(5,2) DEFAULT 0.00,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT practice_sessions_difficulty_level_check CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    CONSTRAINT practice_sessions_status_check CHECK (status IN ('in_progress', 'completed'))
);

CREATE TABLE public.practice_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    session_id uuid NOT NULL,
    question_id uuid NOT NULL,
    user_answer text,
    is_correct boolean,
    marks_obtained integer DEFAULT 0,
    time_taken_seconds integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT practice_responses_session_id_question_id_key UNIQUE (session_id, question_id)
);

CREATE TABLE public.study_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    target_band numeric(3,1) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status character varying(20) DEFAULT 'active',
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT study_plans_status_check CHECK (status IN ('active', 'completed', 'paused'))
);

CREATE TABLE public.study_plan_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
    plan_id uuid NOT NULL,
    day_number integer NOT NULL,
    item_type character varying(20) NOT NULL,
    item_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    estimated_minutes integer DEFAULT 30,
    is_completed boolean DEFAULT false,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT study_plan_items_item_type_check CHECK (item_type IN ('lesson', 'practice', 'mock_test'))
);

-- ============================================
-- FOREIGN KEYS
-- ============================================

ALTER TABLE public.admin_logs
    ADD CONSTRAINT admin_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE CASCADE,
    ADD CONSTRAINT admin_logs_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.tests
    ADD CONSTRAINT tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE public.test_sections
    ADD CONSTRAINT test_sections_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;

ALTER TABLE public.questions
    ADD CONSTRAINT questions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.test_sections(id) ON DELETE CASCADE;

ALTER TABLE public.test_attempts
    ADD CONSTRAINT test_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE,
    ADD CONSTRAINT test_attempts_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;

ALTER TABLE public.user_responses
    ADD CONSTRAINT user_responses_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE,
    ADD CONSTRAINT user_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;

ALTER TABLE public.ai_feedback
    ADD CONSTRAINT ai_feedback_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE,
    ADD CONSTRAINT ai_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);

ALTER TABLE public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.lessons
    ADD CONSTRAINT fk_lessons_created_by FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE public.lesson_parts
    ADD CONSTRAINT fk_lesson_parts_lesson FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;

ALTER TABLE public.practice_sessions
    ADD CONSTRAINT practice_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.practice_responses
    ADD CONSTRAINT practice_responses_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.practice_sessions(id) ON DELETE CASCADE,
    ADD CONSTRAINT practice_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;

ALTER TABLE public.study_plans
    ADD CONSTRAINT study_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE public.study_plan_items
    ADD CONSTRAINT study_plan_items_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.study_plans(id) ON DELETE CASCADE;

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_users_email ON public.users USING btree (email);
CREATE INDEX idx_users_role ON public.users USING btree (role);
CREATE INDEX idx_refresh_user ON public.refresh_tokens USING btree (user_id);
CREATE INDEX idx_sections_test_id ON public.test_sections USING btree (test_id);
CREATE INDEX idx_questions_section_id ON public.questions USING btree (section_id);
CREATE INDEX idx_attempts_user_test ON public.test_attempts USING btree (user_id, test_id);
CREATE INDEX idx_responses_attempt ON public.user_responses USING btree (attempt_id);
CREATE INDEX idx_feedback_attempt ON public.ai_feedback USING btree (attempt_id);
CREATE INDEX idx_feedback_user ON public.ai_feedback USING btree (user_id);
CREATE INDEX idx_lessons_test_type ON public.lessons USING btree (test_type);
CREATE INDEX idx_lessons_section ON public.lessons USING btree (section);
CREATE INDEX idx_lessons_status ON public.lessons USING btree (status);
CREATE INDEX idx_lessons_created_by ON public.lessons USING btree (created_by);
CREATE INDEX idx_lessons_created_at ON public.lessons USING btree (created_at);
CREATE INDEX idx_lessons_min_subscription ON public.lessons USING btree (min_subscription);
CREATE INDEX idx_lessons_target_band ON public.lessons USING btree (target_band);
CREATE INDEX idx_lessons_tags ON public.lessons USING gin (tags);
CREATE INDEX idx_lesson_parts_lesson_id ON public.lesson_parts USING btree (lesson_id);
CREATE INDEX idx_lesson_parts_order ON public.lesson_parts USING btree (order_number);
CREATE INDEX idx_practice_sessions_user ON public.practice_sessions USING btree (user_id);
CREATE INDEX idx_practice_sessions_section ON public.practice_sessions USING btree (section_name);
CREATE INDEX idx_practice_sessions_status ON public.practice_sessions USING btree (status);
CREATE INDEX idx_practice_responses_session ON public.practice_responses USING btree (session_id);
CREATE INDEX idx_practice_responses_question ON public.practice_responses USING btree (question_id);
CREATE INDEX idx_study_plans_user ON public.study_plans USING btree (user_id);
CREATE INDEX idx_study_plans_status ON public.study_plans USING btree (status);
CREATE INDEX idx_study_plan_items_plan ON public.study_plan_items USING btree (plan_id);
CREATE INDEX idx_study_plan_items_day ON public.study_plan_items USING btree (day_number);
-- ============================================
-- SAMPLE DATA
-- ============================================

INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio) VALUES
('3fbc291a-297e-4371-b6de-00e92c845257', 'nasad8569@gmail.com', '$2b$10$BSywSGIy3SsmWNvHIgMfpuJIxQujOyNDQaTgViPT.VNTpUuOjoP1m', 'Asad Abbas', 'https://res.cloudinary.com/dbsfrh5fa/image/upload/v1775152613/testiva/avatars/v7yhxqh48lk977nebldf.jpg', 'email', 'admin', false, '2026-04-07 19:51:51.653661', '2026-04-02 21:57:02.327225', '2026-04-07 13:00:41.510649', 'free', 0, 'No bio provided'),
('46cb0317-1ce3-47f0-9c62-81eccc91fd0a', 'ragesr56@gmail.com', '$2b$10$rdz4kJR.gYkrOC5lBTs1A.sq8ClBqOOhwTdvZ/YUe1EmnsNOxwmfy', 'John Doe', NULL, 'email', 'user', true, '2026-04-21 14:46:29.961396', '2026-04-21 14:40:18.486318', '2026-04-21 14:40:18.486318', 'free', 0, 'No bio provided'),
('e6149e25-93db-496d-8aab-b4c800874fc0', 'azadari87@gmail.com', '$2b$12$bQiJFFr5OFuGqvHMRdTGLuGNphIgRVK97zAD6yORYZbBPEZvWDSdC', 'Asad Updated', 'https://res.cloudinary.com/dbsfrh5fa/image/upload/v1776856751/testiva/avatars/felocgkslmje2id2fqkz.png', 'email', 'user', true, '2026-04-26 12:26:58.803381', '2026-04-22 15:39:30.698238', '2026-04-22 16:19:09.306303', 'free', 1, 'IELTS aspirant from Lahore');

INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES
(4, 'e6149e25-93db-496d-8aab-b4c800874fc0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlNjE0OWUyNS05M2RiLTQ5NmQtOGFhYi1iNGM4MDA4NzRmYzAiLCJ0b2tlbklkIjoiMmExNGY4Y2YtY2EwNy00ZTNkLTgzOTAtZmVmMmI4YmE3NjBkIiwiaWF0IjoxNzc2ODU1MDA5LCJleHAiOjE3Nzc0NTk4MDl9.P_RWTnbmYSM1g6QV-CEjfZMDsqQqmCr5g6pJ6-yWYXI', '2026-04-29 15:50:09.21', '2026-04-22 15:50:09.21095'),
(5, 'e6149e25-93db-496d-8aab-b4c800874fc0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlNjE0OWUyNS05M2RiLTQ5NmQtOGFhYi1iNGM4MDA4NzRmYzAiLCJ0b2tlbklkIjoiY2QwMjc3ZjktZTEyMS00MmJlLWE5NWItYzhlNTMyZWYzYmUyIiwiaWF0IjoxNzc2ODU2MjQxLCJleHAiOjE3Nzc0NjEwNDF9.GFCKetVTTqcd2UUTo7RqmluXJgc_J_mwkakYJZeFDJQ', '2026-04-29 16:10:41.252', '2026-04-22 16:10:41.253029'),
(6, 'e6149e25-93db-496d-8aab-b4c800874fc0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlNjE0OWUyNS05M2RiLTQ5NmQtOGFhYi1iNGM4MDA4NzRmYzAiLCJ0b2tlbklkIjoiMzlkMDk5YmQtMGUxNi00ZTBlLTgyN2EtM2QwMTNmMTEyMWY4IiwiaWF0IjoxNzc2ODU2OTQ1LCJleHAiOjE3Nzc0NjE3NDV9.GjIsiaAgulURba7oGTgJszuqEklph62Hp6xNSS5OOUc', '2026-04-29 16:22:25.201', '2026-04-22 16:22:25.20242'),
(7, 'e6149e25-93db-496d-8aab-b4c800874fc0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlNjE0OWUyNS05M2RiLTQ5NmQtOGFhYi1iNGM4MDA4NzRmYzAiLCJ0b2tlbklkIjoiODMzOTA1NmQtN2IzOS00NzBhLThhOWEtODIzODZiZWI1MjYwIiwiaWF0IjoxNzc3MTg2NDc4LCJleHAiOjE3Nzc3OTEyNzh9.RAlyMjQOKan6h87QAeGPaBemtxFTNk1NLUodE0_rzfU', '2026-05-03 11:54:38.419', '2026-04-26 11:54:38.422248'),
(8, 'e6149e25-93db-496d-8aab-b4c800874fc0', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlNjE0OWUyNS05M2RiLTQ5NmQtOGFhYi1iNGM4MDA4NzRmYzAiLCJ0b2tlbklkIjoiNTM3OGI5MjQtYjg2Zi00MDgxLThkZjAtNDFkOTBlODRlM2Q2IiwiaWF0IjoxNzc3MTg4NDE4LCJleHAiOjE3Nzc3OTMyMTh9.sO5flXb_o0wXQZTyWgpPZ4oBNj4xYE898ouWBdm9QiU', '2026-05-03 12:26:58.799', '2026-04-26 12:26:58.800161');

INSERT INTO public.tests (id, title, is_full_mock, total_time_minutes, created_by, created_at, updated_at, exam_type) VALUES
('d765b23e-5e52-4c19-99fc-be4f0420cf2d', 'IELTS Academic Practice Test 02', true, 160, '3fbc291a-297e-4371-b6de-00e92c845257', '2026-04-07 19:52:30.267704', '2026-04-07 19:52:30.267704', 'IELTS'),
('34e6142a-53b3-4b88-bb91-576842b056d7', 'Updated IELTS Test 01', false, 120, '3fbc291a-297e-4371-b6de-00e92c845257', '2026-04-07 16:44:26.705843', '2026-04-07 19:55:22.609119', 'IELTS');

INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at) VALUES
('e6a4000d-3539-4127-829a-ff244607bd7c', '34e6142a-53b3-4b88-bb91-576842b056d7', 'Reading', 60, 1, 'Answer all questions based on the passage.', '2026-04-07 16:44:26.705843'),
('6ca8272a-d1a1-4619-be4a-f91daeb19528', '34e6142a-53b3-4b88-bb91-576842b056d7', 'Listening', 30, 2, 'Listen carefully and answer the questions.', '2026-04-07 16:44:26.705843'),
('637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'd765b23e-5e52-4c19-99fc-be4f0420cf2d', 'Reading', 60, 1, 'Read the passage and answer the questions below.', '2026-04-07 19:52:30.267704'),
('b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'd765b23e-5e52-4c19-99fc-be4f0420cf2d', 'Writing', 60, 2, 'Complete both tasks.', '2026-04-07 19:52:30.267704'),
('8b76da74-cfc3-49c3-916c-cc4d4f520361', 'd765b23e-5e52-4c19-99fc-be4f0420cf2d', 'Speaking', 40, 3, 'Answer the following speaking questions.', '2026-04-07 19:52:30.267704');

INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES
('bf3316e3-756e-49f2-8eac-1cc007f13fe8', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MCQ', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'What is the main idea of the first paragraph?', '["History", "Future", "Science", "Math"]', 'History', NULL, 1, 1, '2026-04-07 16:44:26.705843'),
('12e2da75-d622-4fc3-8a4b-08e5bc1fddf8', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MCQ', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'When did AI research begin?', '["1940s", "1950s", "1960s", "1970s"]', '1950s', NULL, 2, 1, '2026-04-07 16:44:26.705843'),
('8bc8cc89-fe73-43c0-8921-d04e6c2111dd', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'TRUE_FALSE_NOT_GIVEN', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'AI was first developed in the 1940s.', '["True", "False", "Not Given"]', 'False', NULL, 3, 1, '2026-04-07 16:44:26.705843'),
('4f9e264e-5dd5-4910-b379-cdd43dd57e9c', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'FILL_IN_THE_BLANK', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'AI research began in the ______.', NULL, '1950s', NULL, 4, 1, '2026-04-07 16:44:26.705843'),
('636932dd-17af-4975-a5ef-7b22c3661ad7', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MATCH_HEADINGS', 'Paragraph A: AI development history. Paragraph B: Modern AI applications.', 'Match the heading to the paragraph.', '["i. AI Applications", "ii. AI History"]', 'ii. AI History', NULL, 5, 2, '2026-04-07 16:44:26.705843'),
('61dc82a9-161b-41fc-a972-cf021918ec0d', '6ca8272a-d1a1-4619-be4a-f91daeb19528', 'MCQ', NULL, 'What is the speaker mainly talking about?', '["Travel", "Education", "Technology", "Health"]', 'Technology', NULL, 1, 1, '2026-04-07 16:44:26.705843'),
('f197dcd9-193a-48af-aeff-0de5e50baf38', '6ca8272a-d1a1-4619-be4a-f91daeb19528', 'FILL_IN_THE_BLANK', NULL, 'The lecture starts at ______.', NULL, '9 AM', NULL, 2, 1, '2026-04-07 16:44:26.705843'),
('8692daf2-c94e-4853-9f07-0920587403ec', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'MCQ', 'Climate change is one of the most serious environmental issues facing the world today.', 'What is the main topic of the passage?', '["Pollution", "Climate Change", "Technology", "Education"]', 'Climate Change', NULL, 1, 1, '2026-04-07 19:52:30.267704'),
('c9f26fce-2d65-4770-b0e3-81315c6565de', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'TRUE_FALSE_NOT_GIVEN', 'Climate change impacts all regions of the world, though effects vary.', 'Climate change only affects developing countries.', '["True", "False", "Not Given"]', 'False', NULL, 2, 1, '2026-04-07 19:52:30.267704'),
('7a48eead-7a37-4d2f-b962-d5652f162fcb', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'FILL_IN_THE_BLANK', 'Climate change is one of the most serious environmental issues facing the world today.', 'Climate change is a global ______ issue.', NULL, 'environmental', NULL, 3, 1, '2026-04-07 19:52:30.267704'),
('fe1e5212-1f30-47c7-907b-ba1e9df9b07a', 'b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'ESSAY', NULL, 'Some people think technology has made our lives easier. To what extent do you agree or disagree?', NULL, NULL, NULL, 1, 10, '2026-04-07 19:52:30.267704'),
('7860ab1c-132d-4add-b3e8-0b837495f480', 'b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'REPORT', NULL, 'Summarize the information given in the chart.', NULL, NULL, NULL, 2, 10, '2026-04-07 19:52:30.267704'),
('0bf6053b-71ef-4260-9730-77c7e94c55c0', '8b76da74-cfc3-49c3-916c-cc4d4f520361', 'SHORT_ANSWER', NULL, 'Describe your favorite place.', NULL, NULL, NULL, 1, 5, '2026-04-07 19:52:30.267704'),
('a000c4f0-b59e-447d-9b59-70239fc29c8b', '8b76da74-cfc3-49c3-916c-cc4d4f520361', 'DISCUSSION', NULL, 'Do you think technology improves communication?', NULL, NULL, NULL, 2, 5, '2026-04-07 19:52:30.267704');

SELECT pg_catalog.setval('public.ai_feedback_id_seq', 1, false);
SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 8, true);