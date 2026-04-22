--
-- PostgreSQL database dump
--

\restrict VDFP4vD5DbrYXl9xhG9Y4bkemjX9hcergvtIAbdQeHe01v1fkfMJKVzIlPrQ77E

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-22 12:26:38

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

--
-- TOC entry 5139 (class 1262 OID 16388)
-- Name: Testiva_FYP; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Testiva_FYP" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE "Testiva_FYP" OWNER TO postgres;

\unrestrict VDFP4vD5DbrYXl9xhG9Y4bkemjX9hcergvtIAbdQeHe01v1fkfMJKVzIlPrQ77E
\connect "Testiva_FYP"
\restrict VDFP4vD5DbrYXl9xhG9Y4bkemjX9hcergvtIAbdQeHe01v1fkfMJKVzIlPrQ77E

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

--
-- TOC entry 2 (class 3079 OID 16389)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 5140 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 3 (class 3079 OID 24576)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5141 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 936 (class 1247 OID 24898)
-- Name: attempt_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.attempt_status_enum AS ENUM (
    'in-progress',
    'completed',
    'synced'
);


ALTER TYPE public.attempt_status_enum OWNER TO postgres;

--
-- TOC entry 924 (class 1247 OID 24816)
-- Name: lesson_section_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.lesson_section_enum AS ENUM (
    'Reading',
    'Listening',
    'Writing',
    'Speaking',
    'Speaking & Writing'
);


ALTER TYPE public.lesson_section_enum OWNER TO postgres;

--
-- TOC entry 927 (class 1247 OID 24828)
-- Name: lesson_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.lesson_status_enum AS ENUM (
    'draft',
    'published'
);


ALTER TYPE public.lesson_status_enum OWNER TO postgres;

--
-- TOC entry 960 (class 1247 OID 25073)
-- Name: otp_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.otp_type AS ENUM (
    'register',
    'reset'
);


ALTER TYPE public.otp_type OWNER TO postgres;

--
-- TOC entry 954 (class 1247 OID 25050)
-- Name: subscription_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.subscription_status_enum AS ENUM (
    'free',
    'basic',
    'premium'
);


ALTER TYPE public.subscription_status_enum OWNER TO postgres;

--
-- TOC entry 921 (class 1247 OID 24810)
-- Name: test_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.test_type_enum AS ENUM (
    'IELTS',
    'PTE'
);


ALTER TYPE public.test_type_enum OWNER TO postgres;

--
-- TOC entry 912 (class 1247 OID 24588)
-- Name: user_role_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role_enum AS ENUM (
    'guest',
    'user',
    'admin'
);


ALTER TYPE public.user_role_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 229 (class 1259 OID 25016)
-- Name: lesson_parts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lesson_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    lesson_id uuid NOT NULL,
    part_title character varying(255) NOT NULL,
    part_content text NOT NULL,
    order_number integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.lesson_parts OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 24992)
-- Name: lessons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lessons (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    test_type public.test_type_enum NOT NULL,
    section public.lesson_section_enum NOT NULL,
    summary text,
    status public.lesson_status_enum DEFAULT 'draft'::public.lesson_status_enum NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.lessons OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 24854)
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
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


ALTER TABLE public.questions OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 25110)
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 25109)
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 5142 (class 0 OID 0)
-- Dependencies: 231
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- TOC entry 230 (class 1259 OID 25059)
-- Name: temp_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.temp_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(150),
    password_hash text,
    otp_code text,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    type character varying(20) DEFAULT 'register'::public.otp_type NOT NULL,
    is_verified boolean DEFAULT false,
    attempts integer DEFAULT 0
);


ALTER TABLE public.temp_users OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 24905)
-- Name: test_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_attempts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    test_id uuid,
    overall_band_score numeric(3,1) DEFAULT 0.0,
    writing_score numeric(3,1) DEFAULT 0.0,
    reading_score numeric(3,1) DEFAULT 0.0,
    listening_score numeric(3,1) DEFAULT 0.0,
    speaking_score numeric(3,1) DEFAULT 0.0,
    feedback text,
    status public.attempt_status_enum DEFAULT 'in-progress'::public.attempt_status_enum,
    is_offline boolean DEFAULT false,
    client_started_at timestamp without time zone NOT NULL,
    client_completed_at timestamp without time zone,
    server_synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.test_attempts OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24833)
-- Name: test_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_sections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    test_id uuid,
    section_name public.lesson_section_enum NOT NULL,
    time_limit_minutes integer NOT NULL,
    order_number integer NOT NULL,
    instructions text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.test_sections OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24776)
-- Name: tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    is_full_mock boolean DEFAULT false,
    total_time_minutes integer NOT NULL,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    exam_type public.test_type_enum NOT NULL
);


ALTER TABLE public.tests OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 24958)
-- Name: user_progress_stats; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_progress_stats (
    user_id uuid NOT NULL,
    total_tests_taken integer DEFAULT 0,
    average_band_score numeric(3,1) DEFAULT 0.0,
    last_test_date timestamp without time zone,
    highest_score numeric(3,1) DEFAULT 0.0,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_progress_stats OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 24936)
-- Name: user_responses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
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


ALTER TABLE public.user_responses OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24603)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255),
    password_hash text,
    full_name character varying(150),
    avatar_url text,
    country character varying(100),
    auth_provider character varying(50) DEFAULT 'email'::character varying,
    role public.user_role_enum DEFAULT 'user'::public.user_role_enum NOT NULL,
    is_email_verified boolean DEFAULT false,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    subscription public.subscription_status_enum DEFAULT 'free'::public.subscription_status_enum NOT NULL,
    token_version integer DEFAULT 0
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 4912 (class 2604 OID 25113)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 5130 (class 0 OID 25016)
-- Dependencies: 229
-- Data for Name: lesson_parts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5129 (class 0 OID 24992)
-- Dependencies: 228
-- Data for Name: lessons; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5125 (class 0 OID 24854)
-- Dependencies: 224
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('bf3316e3-756e-49f2-8eac-1cc007f13fe8', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MCQ', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'What is the main idea of the first paragraph?', '["History", "Future", "Science", "Math"]', 'History', NULL, 1, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('12e2da75-d622-4fc3-8a4b-08e5bc1fddf8', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MCQ', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'When did AI research begin?', '["1940s", "1950s", "1960s", "1970s"]', '1950s', NULL, 2, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('8bc8cc89-fe73-43c0-8921-d04e6c2111dd', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'TRUE_FALSE_NOT_GIVEN', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'AI was first developed in the 1940s.', '["True", "False", "Not Given"]', 'False', NULL, 3, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('4f9e264e-5dd5-4910-b379-cdd43dd57e9c', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'FILL_IN_THE_BLANK', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'AI research began in the ______.', NULL, '1950s', NULL, 4, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('636932dd-17af-4975-a5ef-7b22c3661ad7', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MATCH_HEADINGS', 'Paragraph A: AI development history. Paragraph B: Modern AI applications.', 'Match the heading to the paragraph.', '["i. AI Applications", "ii. AI History"]', 'ii. AI History', NULL, 5, 2, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('61dc82a9-161b-41fc-a972-cf021918ec0d', '6ca8272a-d1a1-4619-be4a-f91daeb19528', 'MCQ', NULL, 'What is the speaker mainly talking about?', '["Travel", "Education", "Technology", "Health"]', 'Technology', NULL, 1, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('f197dcd9-193a-48af-aeff-0de5e50baf38', '6ca8272a-d1a1-4619-be4a-f91daeb19528', 'FILL_IN_THE_BLANK', NULL, 'The lecture starts at ______.', NULL, '9 AM', NULL, 2, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('8692daf2-c94e-4853-9f07-0920587403ec', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'MCQ', 'Climate change is one of the most serious environmental issues facing the world today.', 'What is the main topic of the passage?', '["Pollution", "Climate Change", "Technology", "Education"]', 'Climate Change', NULL, 1, 1, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('c9f26fce-2d65-4770-b0e3-81315c6565de', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'TRUE_FALSE_NOT_GIVEN', 'Climate change impacts all regions of the world, though effects vary.', 'Climate change only affects developing countries.', '["True", "False", "Not Given"]', 'False', NULL, 2, 1, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('7a48eead-7a37-4d2f-b962-d5652f162fcb', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'FILL_IN_THE_BLANK', 'Climate change is one of the most serious environmental issues facing the world today.', 'Climate change is a global ______ issue.', NULL, 'environmental', NULL, 3, 1, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('fe1e5212-1f30-47c7-907b-ba1e9df9b07a', 'b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'ESSAY', NULL, 'Some people think technology has made our lives easier. To what extent do you agree or disagree?', NULL, NULL, NULL, 1, 10, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('7860ab1c-132d-4add-b3e8-0b837495f480', 'b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'REPORT', NULL, 'Summarize the information given in the chart.', NULL, NULL, NULL, 2, 10, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('0bf6053b-71ef-4260-9730-77c7e94c55c0', '8b76da74-cfc3-49c3-916c-cc4d4f520361', 'SHORT_ANSWER', NULL, 'Describe your favorite place.', NULL, NULL, NULL, 1, 5, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('a000c4f0-b59e-447d-9b59-70239fc29c8b', '8b76da74-cfc3-49c3-916c-cc4d4f520361', 'DISCUSSION', NULL, 'Do you think technology improves communication?', NULL, NULL, NULL, 2, 5, '2026-04-07 19:52:30.267704');


--
-- TOC entry 5133 (class 0 OID 25110)
-- Dependencies: 232
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (2, '9cafbc0d-e63f-4d62-9349-93cafcc0d09b', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOnsiaWQiOiI5Y2FmYmMwZC1lNjNmLTRkNjItOTM0OS05M2NhZmNjMGQwOWIiLCJyb2xlIjoidXNlciIsInN1YnNjcmlwdGlvbiI6ImZyZWUifSwidG9rZW5JZCI6ImMxMTdjNzcyLTc0N2MtNDRmMi04NWQwLTdjOWQxZGFiYzBlMSIsImlhdCI6MTc3Njc3MDQwNiwiZXhwIjoxNzc3Mzc1MjA2fQ.eNbJCNW7h7O4flESqipRtYytK-5KleDk_246bz4ADC4', '2026-04-28 16:20:06.45', '2026-04-21 16:20:06.451355');


--
-- TOC entry 5131 (class 0 OID 25059)
-- Dependencies: 230
-- Data for Name: temp_users; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5126 (class 0 OID 24905)
-- Dependencies: 225
-- Data for Name: test_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5124 (class 0 OID 24833)
-- Dependencies: 223
-- Data for Name: test_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at) VALUES ('e6a4000d-3539-4127-829a-ff244607bd7c', '34e6142a-53b3-4b88-bb91-576842b056d7', 'Reading', 60, 1, 'Answer all questions based on the passage.', '2026-04-07 16:44:26.705843');
INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at) VALUES ('6ca8272a-d1a1-4619-be4a-f91daeb19528', '34e6142a-53b3-4b88-bb91-576842b056d7', 'Listening', 30, 2, 'Listen carefully and answer the questions.', '2026-04-07 16:44:26.705843');
INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at) VALUES ('637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'd765b23e-5e52-4c19-99fc-be4f0420cf2d', 'Reading', 60, 1, 'Read the passage and answer the questions below.', '2026-04-07 19:52:30.267704');
INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at) VALUES ('b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'd765b23e-5e52-4c19-99fc-be4f0420cf2d', 'Writing', 60, 2, 'Complete both tasks.', '2026-04-07 19:52:30.267704');
INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at) VALUES ('8b76da74-cfc3-49c3-916c-cc4d4f520361', 'd765b23e-5e52-4c19-99fc-be4f0420cf2d', 'Speaking', 40, 3, 'Answer the following speaking questions.', '2026-04-07 19:52:30.267704');


--
-- TOC entry 5123 (class 0 OID 24776)
-- Dependencies: 222
-- Data for Name: tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tests (id, title, is_full_mock, total_time_minutes, created_by, created_at, updated_at, exam_type) VALUES ('d765b23e-5e52-4c19-99fc-be4f0420cf2d', 'IELTS Academic Practice Test 02', true, 160, '3fbc291a-297e-4371-b6de-00e92c845257', '2026-04-07 19:52:30.267704', '2026-04-07 19:52:30.267704', 'IELTS');
INSERT INTO public.tests (id, title, is_full_mock, total_time_minutes, created_by, created_at, updated_at, exam_type) VALUES ('34e6142a-53b3-4b88-bb91-576842b056d7', 'Updated IELTS Test 01', false, 120, '3fbc291a-297e-4371-b6de-00e92c845257', '2026-04-07 16:44:26.705843', '2026-04-07 19:55:22.609119', 'IELTS');


--
-- TOC entry 5128 (class 0 OID 24958)
-- Dependencies: 227
-- Data for Name: user_progress_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5127 (class 0 OID 24936)
-- Dependencies: 226
-- Data for Name: user_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5122 (class 0 OID 24603)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, country, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version) VALUES ('3fbc291a-297e-4371-b6de-00e92c845257', 'nasad8569@gmail.com', '$2b$10$BSywSGIy3SsmWNvHIgMfpuJIxQujOyNDQaTgViPT.VNTpUuOjoP1m', 'Asad Abbas', 'https://res.cloudinary.com/dbsfrh5fa/image/upload/v1775152613/testiva/avatars/v7yhxqh48lk977nebldf.jpg', NULL, 'email', 'admin', false, '2026-04-07 19:51:51.653661', '2026-04-02 21:57:02.327225', '2026-04-07 13:00:41.510649', 'free', 0);
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, country, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version) VALUES ('46cb0317-1ce3-47f0-9c62-81eccc91fd0a', 'ragesr56@gmail.com', '$2b$10$rdz4kJR.gYkrOC5lBTs1A.sq8ClBqOOhwTdvZ/YUe1EmnsNOxwmfy', 'John Doe', NULL, NULL, 'email', 'user', true, '2026-04-21 14:46:29.961396', '2026-04-21 14:40:18.486318', '2026-04-21 14:40:18.486318', 'free', 0);
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, country, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version) VALUES ('9cafbc0d-e63f-4d62-9349-93cafcc0d09b', 'azadari87@gmail.com', '$2b$10$A2tfZ4Wp9Ul5gmLFDTevB.RuCfWMT/.HszNgkQF9gK2HtsNSh.Qdy', 'Ali Khan', NULL, NULL, 'email', 'user', true, '2026-04-21 16:20:06.455709', '2026-04-21 16:02:45.337476', '2026-04-21 16:19:50.660404', 'free', 0);


--
-- TOC entry 5143 (class 0 OID 0)
-- Dependencies: 231
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 2, true);


--
-- TOC entry 4948 (class 2606 OID 25032)
-- Name: lesson_parts lesson_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_parts
    ADD CONSTRAINT lesson_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 4944 (class 2606 OID 25010)
-- Name: lessons lessons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT lessons_pkey PRIMARY KEY (id);


--
-- TOC entry 4929 (class 2606 OID 24867)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 4961 (class 2606 OID 25122)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4963 (class 2606 OID 25124)
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- TOC entry 4952 (class 2606 OID 25071)
-- Name: temp_users temp_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_key UNIQUE (email);


--
-- TOC entry 4954 (class 2606 OID 25094)
-- Name: temp_users temp_users_email_type_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_type_unique UNIQUE (email, type);


--
-- TOC entry 4956 (class 2606 OID 25082)
-- Name: temp_users temp_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_unique UNIQUE (email);


--
-- TOC entry 4958 (class 2606 OID 25069)
-- Name: temp_users temp_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_pkey PRIMARY KEY (id);


--
-- TOC entry 4932 (class 2606 OID 24924)
-- Name: test_attempts test_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_pkey PRIMARY KEY (id);


--
-- TOC entry 4924 (class 2606 OID 24845)
-- Name: test_sections test_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT test_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 4921 (class 2606 OID 24788)
-- Name: tests tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_pkey PRIMARY KEY (id);


--
-- TOC entry 4950 (class 2606 OID 25034)
-- Name: lesson_parts unique_part_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_parts
    ADD CONSTRAINT unique_part_order UNIQUE (lesson_id, order_number);


--
-- TOC entry 4926 (class 2606 OID 24847)
-- Name: test_sections unique_test_section_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT unique_test_section_order UNIQUE (test_id, order_number);


--
-- TOC entry 4937 (class 2606 OID 24967)
-- Name: user_progress_stats user_progress_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4935 (class 2606 OID 24946)
-- Name: user_responses user_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 4917 (class 2606 OID 24623)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4919 (class 2606 OID 24621)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4930 (class 1259 OID 24935)
-- Name: idx_attempts_user_test; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_user_test ON public.test_attempts USING btree (user_id, test_id);


--
-- TOC entry 4945 (class 1259 OID 25045)
-- Name: idx_lesson_parts_lesson_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lesson_parts_lesson_id ON public.lesson_parts USING btree (lesson_id);


--
-- TOC entry 4946 (class 1259 OID 25046)
-- Name: idx_lesson_parts_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lesson_parts_order ON public.lesson_parts USING btree (order_number);


--
-- TOC entry 4938 (class 1259 OID 25043)
-- Name: idx_lessons_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lessons_created_at ON public.lessons USING btree (created_at);


--
-- TOC entry 4939 (class 1259 OID 25044)
-- Name: idx_lessons_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lessons_created_by ON public.lessons USING btree (created_by);


--
-- TOC entry 4940 (class 1259 OID 25041)
-- Name: idx_lessons_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lessons_section ON public.lessons USING btree (section);


--
-- TOC entry 4941 (class 1259 OID 25042)
-- Name: idx_lessons_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lessons_status ON public.lessons USING btree (status);


--
-- TOC entry 4942 (class 1259 OID 25040)
-- Name: idx_lessons_test_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lessons_test_type ON public.lessons USING btree (test_type);


--
-- TOC entry 4927 (class 1259 OID 24873)
-- Name: idx_questions_section_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_section_id ON public.questions USING btree (section_id);


--
-- TOC entry 4959 (class 1259 OID 25131)
-- Name: idx_refresh_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_user ON public.refresh_tokens USING btree (user_id);


--
-- TOC entry 4933 (class 1259 OID 24957)
-- Name: idx_responses_attempt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_responses_attempt ON public.user_responses USING btree (attempt_id);


--
-- TOC entry 4922 (class 1259 OID 24853)
-- Name: idx_sections_test_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_test_id ON public.test_sections USING btree (test_id);


--
-- TOC entry 4914 (class 1259 OID 24624)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 4915 (class 1259 OID 24625)
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- TOC entry 4973 (class 2606 OID 25035)
-- Name: lesson_parts fk_lesson_parts_lesson; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lesson_parts
    ADD CONSTRAINT fk_lesson_parts_lesson FOREIGN KEY (lesson_id) REFERENCES public.lessons(id) ON DELETE CASCADE;


--
-- TOC entry 4972 (class 2606 OID 25011)
-- Name: lessons fk_lessons_created_by; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lessons
    ADD CONSTRAINT fk_lessons_created_by FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4966 (class 2606 OID 24868)
-- Name: questions questions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.test_sections(id) ON DELETE CASCADE;


--
-- TOC entry 4974 (class 2606 OID 25125)
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4967 (class 2606 OID 24930)
-- Name: test_attempts test_attempts_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 4968 (class 2606 OID 24925)
-- Name: test_attempts test_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4965 (class 2606 OID 24848)
-- Name: test_sections test_sections_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT test_sections_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 4964 (class 2606 OID 24789)
-- Name: tests tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4971 (class 2606 OID 24968)
-- Name: user_progress_stats user_progress_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4969 (class 2606 OID 24947)
-- Name: user_responses user_responses_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE;


--
-- TOC entry 4970 (class 2606 OID 24952)
-- Name: user_responses user_responses_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


-- Completed on 2026-04-22 12:26:38

--
-- PostgreSQL database dump complete
--

\unrestrict VDFP4vD5DbrYXl9xhG9Y4bkemjX9hcergvtIAbdQeHe01v1fkfMJKVzIlPrQ77E

