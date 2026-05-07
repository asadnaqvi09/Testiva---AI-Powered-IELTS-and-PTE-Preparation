
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
CREATE DATABASE "Testiva_FYP" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
ALTER DATABASE "Testiva_FYP" OWNER TO postgres;
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
CREATE SCHEMA public;
ALTER SCHEMA public OWNER TO pg_database_owner;
COMMENT ON SCHEMA public IS 'standard public schema';
CREATE TYPE public.admin_status AS ENUM (
    'none',
    'flagged',
    'removed'
);
ALTER TYPE public.admin_status OWNER TO postgres;
CREATE TYPE public.attempt_status_enum AS ENUM (
    'in_progress',
    'completed',
    'synced'
);
ALTER TYPE public.attempt_status_enum OWNER TO postgres;
CREATE TYPE public.difficulty_enum AS ENUM (
    'easy',
    'medium',
    'hard',
    'mixed'
);
ALTER TYPE public.difficulty_enum OWNER TO postgres;
CREATE TYPE public.flag_source AS ENUM (
    'ai',
    'admin'
);
ALTER TYPE public.flag_source OWNER TO postgres;
CREATE TYPE public.lesson_section_enum AS ENUM (
    'Reading',
    'Listening',
    'Writing',
    'Speaking',
    'Speaking & Writing'
);
ALTER TYPE public.lesson_section_enum OWNER TO postgres;
CREATE TYPE public.lesson_status_enum AS ENUM (
    'draft',
    'published'
);
ALTER TYPE public.lesson_status_enum OWNER TO postgres;
CREATE TYPE public.moderation_action AS ENUM (
    'flag',
    'unflag',
    'delete',
    'restore'
);
ALTER TYPE public.moderation_action OWNER TO postgres;
CREATE TYPE public.otp_type AS ENUM (
    'register',
    'reset'
);
ALTER TYPE public.otp_type OWNER TO postgres;
CREATE TYPE public.share_platform AS ENUM (
    'twitter',
    'instagram',
    'whatsapp',
    'facebook',
    'copy_link'
);


ALTER TYPE public.share_platform OWNER TO postgres;
CREATE TYPE public.subscription_status_enum AS ENUM (
    'free',
    'basic',
    'premium'
);


ALTER TYPE public.subscription_status_enum OWNER TO postgres;
CREATE TYPE public.test_category_enum AS ENUM (
    'full_mock',
    'module_wise'
);


ALTER TYPE public.test_category_enum OWNER TO postgres;
CREATE TYPE public.test_type_enum AS ENUM (
    'IELTS',
    'PTE'
);


ALTER TYPE public.test_type_enum OWNER TO postgres;
CREATE TYPE public.topic_tag AS ENUM (
    'IELTS',
    'PTE',
    'General'
);


ALTER TYPE public.topic_tag OWNER TO postgres;
CREATE TYPE public.user_role_enum AS ENUM (
    '',
    'user',
    'admin'
);


ALTER TYPE public.user_role_enum OWNER TO postgres;
CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;
CREATE TABLE public.admin_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    action character varying(50) NOT NULL,
    target_user_id uuid,
    details jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admin_logs OWNER TO postgres;
CREATE TABLE public.ai_feedback (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    attempt_id uuid NOT NULL,
    user_id uuid NOT NULL,
    overall_band_score numeric(3,1) DEFAULT 0.0,
    task_response_score numeric(3,1),
    coherence_cohesion_score numeric(3,1),
    lexical_resource_score numeric(3,1),
    grammatical_range_score numeric(3,1),
    detailed_analysis jsonb,
    improvement_suggestions text,
    model_used character varying(50) DEFAULT 'gemini-1.5-flash'::character varying,
    evaluated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ai_feedback OWNER TO postgres;
CREATE TABLE public.comment_likes (
    comment_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.comment_likes OWNER TO postgres;
CREATE TABLE public.comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    parent_id uuid,
    content text NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    flagged_by public.flag_source,
    flag_reason text,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.comments OWNER TO postgres;
CREATE TABLE public.moderation_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    target_type character varying(10) NOT NULL,
    target_id uuid NOT NULL,
    action public.moderation_action NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    admin_feedback text,
    email_sent boolean DEFAULT false NOT NULL,
    CONSTRAINT moderation_log_target_type_check CHECK (((target_type)::text = ANY ((ARRAY['post'::character varying, 'comment'::character varying])::text[])))
);
ALTER TABLE public.moderation_log OWNER TO postgres;
CREATE TABLE public.post_likes (
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.post_likes OWNER TO postgres;
CREATE TABLE public.post_shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    platform public.share_platform NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.post_shares OWNER TO postgres;
CREATE TABLE public.posts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    topic_tag public.topic_tag DEFAULT 'General'::public.topic_tag NOT NULL,
    title character varying(200) NOT NULL,
    content text NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    flagged_by public.flag_source,
    flag_reason text,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.posts OWNER TO postgres;
CREATE TABLE public.practice_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    question_id uuid NOT NULL,
    user_answer text,
    is_correct boolean,
    marks_obtained integer DEFAULT 0,
    time_taken_seconds integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.practice_responses OWNER TO postgres;
CREATE TABLE public.practice_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    section_name character varying(50) NOT NULL,
    question_type character varying(50),
    difficulty_level integer DEFAULT 1,
    status character varying(20) DEFAULT 'in_progress'::character varying,
    total_questions integer DEFAULT 0,
    correct_answers integer DEFAULT 0,
    accuracy numeric(5,2) DEFAULT 0.00,
    started_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT practice_sessions_difficulty_level_check CHECK (((difficulty_level >= 1) AND (difficulty_level <= 5))),
    CONSTRAINT practice_sessions_status_check CHECK (((status)::text = ANY ((ARRAY['in_progress'::character varying, 'completed'::character varying])::text[])))
);


ALTER TABLE public.practice_sessions OWNER TO postgres;
CREATE TABLE public.prep_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prep_id uuid,
    file_url character varying(255),
    file_name character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    file_size integer,
    file_type character varying(50)
);
ALTER TABLE public.prep_media OWNER TO postgres;
CREATE TABLE public.prep_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prep_id uuid,
    part_title character varying(255),
    part_content text,
    order_index integer DEFAULT 0
);


ALTER TABLE public.prep_parts OWNER TO postgres;
CREATE TABLE public.preparations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    test_type public.test_type_enum,
    section public.lesson_section_enum,
    summary text,
    status character varying(20) DEFAULT 'Draft'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.preparations OWNER TO postgres;
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    difficulty public.difficulty_enum DEFAULT 'medium'::public.difficulty_enum,
    tags jsonb DEFAULT '[]'::jsonb,
    image_url text
);


ALTER TABLE public.questions OWNER TO postgres;
CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;
CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_id_seq OWNER TO postgres;
ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- TOC entry 235 (class 1259 OID 25279)
-- Name: study_plan_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_plan_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    plan_id uuid NOT NULL,
    day_number integer NOT NULL,
    item_type character varying(20) NOT NULL,
    item_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    estimated_minutes integer DEFAULT 30,
    is_completed boolean DEFAULT false,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT study_plan_items_item_type_check CHECK (((item_type)::text = ANY ((ARRAY['lesson'::character varying, 'practice'::character varying, 'mock_test'::character varying])::text[])))
);


ALTER TABLE public.study_plan_items OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 25258)
-- Name: study_plans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.study_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    target_band numeric(3,1) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status character varying(20) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT study_plans_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'completed'::character varying, 'paused'::character varying])::text[])))
);


ALTER TABLE public.study_plans OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 25059)
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
    status public.attempt_status_enum DEFAULT 'in_progress'::public.attempt_status_enum,
    is_offline boolean DEFAULT false,
    client_started_at timestamp without time zone NOT NULL,
    client_completed_at timestamp without time zone,
    server_synced_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sync_status text DEFAULT 'pending'::text,
    CONSTRAINT test_attempts_sync_status_check CHECK ((sync_status = ANY (ARRAY['pending'::text, 'synced'::text, 'failed'::text])))
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    question_types_allowed jsonb DEFAULT '[]'::jsonb,
    task_count integer DEFAULT 1
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
    exam_type public.test_type_enum NOT NULL,
    is_published boolean DEFAULT false,
    test_category public.test_category_enum DEFAULT 'full_mock'::public.test_category_enum NOT NULL,
    passing_score numeric(3,1) DEFAULT 6.5,
    difficulty_level public.difficulty_enum DEFAULT 'mixed'::public.difficulty_enum
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
    user_answer jsonb,
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
    auth_provider character varying(50) DEFAULT 'email'::character varying,
    role public.user_role_enum DEFAULT 'user'::public.user_role_enum NOT NULL,
    is_email_verified boolean DEFAULT false,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    subscription public.subscription_status_enum DEFAULT 'free'::public.subscription_status_enum NOT NULL,
    token_version integer DEFAULT 0,
    bio text DEFAULT 'No bio provided'::text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 4989 (class 2604 OID 25113)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 5332 (class 0 OID 25133)
-- Dependencies: 231
-- Data for Name: admin_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('9b548522-4ceb-4ebf-a89b-4e4acfe95fec', '660c49f1-a752-420e-a27c-fe53a73d71db', 'Subscription Change', '46cb0317-1ce3-47f0-9c62-81eccc91fd0a', '{"message": "Changed subscription to basic"}', '2026-04-30 23:36:14.098673');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('a54b095f-29d7-42e4-94a8-74e89cceaf58', '660c49f1-a752-420e-a27c-fe53a73d71db', 'Subscription Change', 'fc44aed3-2a8d-4bca-82e0-fc9e2b6fb4a5', '{"message": "Changed subscription to basic"}', '2026-05-03 13:31:46.098364');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('4aed160a-ac29-4c56-802b-135ab78bec83', '660c49f1-a752-420e-a27c-fe53a73d71db', 'Subscription Change', 'fc44aed3-2a8d-4bca-82e0-fc9e2b6fb4a5', '{"message": "Changed subscription to free"}', '2026-05-03 13:31:49.257461');


--
-- TOC entry 5337 (class 0 OID 25331)
-- Dependencies: 236
-- Data for Name: ai_feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5344 (class 0 OID 42050)
-- Dependencies: 243
-- Data for Name: comment_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5342 (class 0 OID 41993)
-- Dependencies: 241
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5346 (class 0 OID 42093)
-- Dependencies: 245
-- Data for Name: moderation_log; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5343 (class 0 OID 42030)
-- Dependencies: 242
-- Data for Name: post_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5345 (class 0 OID 42070)
-- Dependencies: 244
-- Data for Name: post_shares; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5341 (class 0 OID 41963)
-- Dependencies: 240
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5334 (class 0 OID 25228)
-- Dependencies: 233
-- Data for Name: practice_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5333 (class 0 OID 25205)
-- Dependencies: 232
-- Data for Name: practice_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5340 (class 0 OID 41596)
-- Dependencies: 239
-- Data for Name: prep_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('7221cf8e-79f8-4532-b177-c8ad89345d24', '7f04bbea-7791-47bc-8399-910fecb8db34', 'https://res.cloudinary.com/dbsfrh5fa/raw/upload/v1778051156/testiva/documents/1778051142575-BSCS_Batch_18th_1-6_Fall_2025.pdf', 'BSCS Batch 18th 1-6 Fall 2025.pdf', '2026-05-06 12:13:26.336241', 817256, 'application/pdf');


--
-- TOC entry 5339 (class 0 OID 41581)
-- Dependencies: 238
-- Data for Name: prep_parts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('3144a5f2-81b3-4841-8a7a-a29eb6a29faf', '7f04bbea-7791-47bc-8399-910fecb8db34', 'Introduction to Skimming', 'Skimming is a reading technique that allows you to quickly get the main idea of a text.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('4ff73d80-976b-4d03-898b-7c99b6928067', '7f04bbea-7791-47bc-8399-910fecb8db34', 'Scanning Techniques', 'Scanning helps you locate specific information such as dates, names, or keywords quickly.', 2);


--
-- TOC entry 5338 (class 0 OID 41566)
-- Dependencies: 237
-- Data for Name: preparations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('7f04bbea-7791-47bc-8399-910fecb8db34', 'IELTS Reading - Skimming and Scanning Techniques', 'IELTS', 'Reading', 'This lesson covers effective skimming and scanning methods for IELTS Reading section.', 'published', '2026-05-06 12:13:26.336241', '2026-05-06 12:13:26.336241');


--
-- TOC entry 5325 (class 0 OID 24854)
-- Dependencies: 224
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('43534088-6c85-42d4-a350-f8594046bce8', '9ccf64ac-4138-43f1-92c7-b972947daf12', 'mcq', NULL, 'What is the main idea of the passage?', '["Option A", "Option B", "Option C", "Option D"]', 'Option A', NULL, 1, 1, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('f9a05f27-eae8-4b20-bdbd-d6beff5adc50', '9ccf64ac-4138-43f1-92c7-b972947daf12', 'fill_blank', NULL, 'The scientist discovered that the cell __________ rapidly.', NULL, 'divides', NULL, 2, 1, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('86f32b9c-baeb-4906-9ef9-b3369e593e13', '9ccf64ac-4138-43f1-92c7-b972947daf12', 'mcq', NULL, 'Which year did the project start?', '["2010", "2015", "2020", "2022"]', '2015', NULL, 3, 1, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('5207944e-2da0-4dac-a53b-a53883452e26', '9ccf64ac-4138-43f1-92c7-b972947daf12', 'short_answer', NULL, 'Briefly explain the conclusion.', NULL, 'The project was successful.', NULL, 4, 2, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('806e1600-c55f-4c6b-a3ac-f1f0d26e7794', '6d52502a-1fb4-47c8-a09e-25b0652a2c3d', 'mcq', NULL, 'What does the speaker prefer?', '["Coffee", "Tea", "Juice", "Water"]', 'Tea', NULL, 1, 1, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('c06c7bad-cb63-463c-b2f3-cae55b30d162', '6d52502a-1fb4-47c8-a09e-25b0652a2c3d', 'fill_blank', NULL, 'The meeting is scheduled for __________.', NULL, 'Monday', NULL, 2, 1, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('5cdc59aa-add1-40ff-90bb-79281e3060f6', '6d52502a-1fb4-47c8-a09e-25b0652a2c3d', 'mcq', NULL, 'How many people attended?', '["5", "10", "15", "20"]', '10', NULL, 3, 1, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('b9869f77-c66a-411d-88d7-4276d72994cb', '6d52502a-1fb4-47c8-a09e-25b0652a2c3d', 'short_answer', NULL, 'Why did the plane delay?', NULL, 'Bad weather', NULL, 4, 2, '2026-05-02 12:47:43.209982', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('0e3772a2-f7fd-4f3c-b2be-76d9eee0f4b5', '9b4648d5-b0b5-488f-9702-f16765ab27dc', 'essay', 'Global climate patterns are shifting...', 'Write a 200-word essay on climate change.', NULL, NULL, NULL, 1, 15, '2026-05-02 12:50:16.491209', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('312ed8ec-a2d4-4d41-828c-d8199fb32ec6', '9b4648d5-b0b5-488f-9702-f16765ab27dc', 'short_answer', 'The quick brown fox jumps over the lazy dog.', 'Read the following text aloud.', NULL, NULL, NULL, 2, 5, '2026-05-02 12:50:16.491209', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('3ff7e20d-3f1e-4c17-bfb4-09eed569ed94', '9ccf64ac-4138-43f1-92c7-b972947daf12', 'mcq', NULL, 'Select the correct term for the definition provided.', '["Algorithm", "Variable", "Function", "Loop"]', 'Algorithm', NULL, 9, 2, '2026-05-02 14:22:21.17474', 'medium', '[]', NULL);
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at, difficulty, tags, image_url) VALUES ('b365f240-4ef0-4d60-ad8c-54a2c28d525e', '9ccf64ac-4138-43f1-92c7-b972947daf12', 'mcq', NULL, 'Select the correct term for the definition provided.', '["Algorithm", "Variable", "Function", "Loop"]', 'Algorithm', NULL, 9, 2, '2026-05-02 14:54:47.890016', 'medium', '[]', NULL);


--
-- TOC entry 5331 (class 0 OID 25110)
-- Dependencies: 230
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (17, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiNGI1N2U2NDQtNTQ4Yy00ZmIzLTg0YTMtYjliNDNhYjJlMDZhIiwiaWF0IjoxNzc3Nzg4NjcyLCJleHAiOjE3NzgzOTM0NzJ9.13-RDlup4RsBvBGUX9bbI7OH0_MmQOyP2Ca2PZfbpOk', '2026-05-10 11:11:12.432', '2026-05-03 11:11:12.433253');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (18, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiMjE2OTQzNTUtZjNkZC00NjZlLWEyOWItYTY2NmE2ZDIyZGI3IiwiaWF0IjoxNzc3Nzg4NzAwLCJleHAiOjE3NzgzOTM1MDB9.VIoFBH0rwfpSIyYZt2IkJuJSo3slIfP9GXnFl-Npah4', '2026-05-10 11:11:40.588', '2026-05-03 11:11:40.589327');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (19, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiMjY5NDVkNDQtZmMzYi00M2ZjLTgzMjUtMTJhYmM0ZDlhZWMzIiwiaWF0IjoxNzc3Nzk2NzMzLCJleHAiOjE3Nzg0MDE1MzN9.AkJJPu0ffw-dKsuNdRIAEMADpZZOW-RT6-O6b8PY0Cc', '2026-05-10 13:25:33.608', '2026-05-03 13:25:33.611032');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (20, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiNmVmMzJkYjUtM2YwNC00MGU0LTlkODctMzU2YmUwZGQzMTU0IiwiaWF0IjoxNzc3OTE4MzUyLCJleHAiOjE3Nzg1MjMxNTJ9.jOeNvDldaUCof6BZTmJQUNVJJOU3w-5eSG-lP2zTppo', '2026-05-11 23:12:32.604', '2026-05-04 23:12:32.605501');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (21, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiZDZjZDBlZGItMzhhNS00NGIzLTg1MWUtYjM1Yzg3MmJhZDlkIiwiaWF0IjoxNzc3OTE5MDIzLCJleHAiOjE3Nzg1MjM4MjN9.2N3XlGpSOn4L5X66BJQ_GXiQ5Pp28QbTkaFoSp755ME', '2026-05-11 23:23:43.717', '2026-05-04 23:23:43.717872');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (22, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiOGVlOGVhM2ItMWQ4MS00MjhmLWE4YmMtNjBjODRhNzEwMDI1IiwiaWF0IjoxNzc3OTY2MTc1LCJleHAiOjE3Nzg1NzA5NzV9.p7cqu9newV8yqlqmzP1bPponar6Rr4T64_EtfSRb3WQ', '2026-05-12 12:29:35.121', '2026-05-05 12:29:35.12278');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (23, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiNjJlYmRlNzgtNWViMS00NzYwLTg0ZGEtYjdhYmYzZDNiYTg1IiwiaWF0IjoxNzc3OTk0NjY0LCJleHAiOjE3Nzg1OTk0NjR9.B9RlcGozzahibRGtPWTxbBKRe1DQbB4-jZ7GvcPSucE', '2026-05-12 20:24:24.906', '2026-05-05 20:24:24.908582');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (24, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiMGQxMTU4MTMtZDE5Zi00NTRhLWI3YTctMDI3MmQ2YjEyOWI1IiwiaWF0IjoxNzc3OTk4MTgxLCJleHAiOjE3Nzg2MDI5ODF9.b6hUpEztKeUYx_lNEUf5cQSZhk407H2DiRUfVx73n5E', '2026-05-12 21:23:01.125', '2026-05-05 21:23:01.126354');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (25, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiNDA1MTY5NGUtYzdiMi00M2E5LTg4MzMtYzJiOTcwMzY2ZDgzIiwiaWF0IjoxNzc4MDA2MTIzLCJleHAiOjE3Nzg2MTA5MjN9.r55U531-pjDv5d2rN618ERK9SacWfHum7wSvACRh5To', '2026-05-12 23:35:23.718', '2026-05-05 23:35:23.719263');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (26, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiY2EwODZkOWMtY2JjOC00Mjg0LWJlYmQtMjI4ODMyZjM4MTRiIiwiaWF0IjoxNzc4MDA4MTYyLCJleHAiOjE3Nzg2MTI5NjJ9.qRQJIJRZfRwyyjI07AlOxGvrlYqwZHPo_K3SF9PsMQw', '2026-05-13 00:09:22.543', '2026-05-06 00:09:22.545392');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (27, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiNGUxZjM0NDEtMzkxZi00Y2ZiLWE5YmMtYzFmZThiOWFlMDFjIiwiaWF0IjoxNzc4MDEyMDUzLCJleHAiOjE3Nzg2MTY4NTN9.vUTCexufqaYOq9RtzvT5Y0EOwWsKqZELkPRF1ahpp30', '2026-05-13 01:14:13.558', '2026-05-06 01:14:13.559188');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (28, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiYzVlN2E4YzMtNGU0OC00MjlhLWJmMmMtMTYwMGZkZTFkODFjIiwiaWF0IjoxNzc4MDEyOTY5LCJleHAiOjE3Nzg2MTc3Njl9.CYxdJDT4Vjo7sZfpwFw-Uhv6vpD3x4VtXNLqwrpwZIM', '2026-05-13 01:29:29.53', '2026-05-06 01:29:29.532303');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (29, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiYWE3YWVmNmItMWY2OS00ZTlmLThiMWUtMzc4NDE3MzNiYmU2IiwiaWF0IjoxNzc4MDE1MTM1LCJleHAiOjE3Nzg2MTk5MzV9.l9XnnBbc98I-IbdU3a5xeajlUwhBVcNifELQxHw8wto', '2026-05-13 02:05:35.63', '2026-05-06 02:05:35.63131');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (30, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiZGU3MjYzNzctMDNjOS00N2I0LWJlYjMtNDJlM2MzNTMyZTVlIiwiaWF0IjoxNzc4MDQ5OTMyLCJleHAiOjE3Nzg2NTQ3MzJ9.mFKXR_gJCpzoFiWffPA1PbUBkC2Q66nCf9is6iF_Kj4', '2026-05-13 11:45:32.243', '2026-05-06 11:45:32.244559');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (31, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiMjY5ZmZlYjMtOGE0Ny00NzUyLThjNDUtYjVkODE0NzRkMTQ4IiwiaWF0IjoxNzc4MDUxMTE1LCJleHAiOjE3Nzg2NTU5MTV9.4gUaG8C-ROPv7KVG7bn__P6RkpR5QGm3TQbKBN50Dlo', '2026-05-13 12:05:15.607', '2026-05-06 12:05:15.608069');


--
-- TOC entry 5336 (class 0 OID 25279)
-- Dependencies: 235
-- Data for Name: study_plan_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5335 (class 0 OID 25258)
-- Dependencies: 234
-- Data for Name: study_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5329 (class 0 OID 25059)
-- Dependencies: 228
-- Data for Name: temp_users; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5326 (class 0 OID 24905)
-- Dependencies: 225
-- Data for Name: test_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5324 (class 0 OID 24833)
-- Dependencies: 223
-- Data for Name: test_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at, question_types_allowed, task_count) VALUES ('9ccf64ac-4138-43f1-92c7-b972947daf12', 'fe1ba307-b518-4c28-b5ec-278f7261e15a', 'Reading', 60, 1, 'Read the passages and answer the questions.', '2026-05-02 12:47:43.209982', '["mcq", "fill_blank", "short_answer"]', 4);
INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at, question_types_allowed, task_count) VALUES ('6d52502a-1fb4-47c8-a09e-25b0652a2c3d', 'fe1ba307-b518-4c28-b5ec-278f7261e15a', 'Listening', 30, 2, 'Listen to the audio and answer.', '2026-05-02 12:47:43.209982', '["mcq", "fill_blank", "short_answer"]', 4);
INSERT INTO public.test_sections (id, test_id, section_name, time_limit_minutes, order_number, instructions, created_at, question_types_allowed, task_count) VALUES ('9b4648d5-b0b5-488f-9702-f16765ab27dc', 'a1e80ec6-b4a7-4abc-944f-a13a5cd8a6de', 'Speaking & Writing', 77, 1, 'Complete the integrated tasks within the given time.', '2026-05-02 12:50:16.491209', '["read_aloud", "repeat_sentence", "essay"]', 5);


--
-- TOC entry 5323 (class 0 OID 24776)
-- Dependencies: 222
-- Data for Name: tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.tests (id, title, is_full_mock, total_time_minutes, created_by, created_at, updated_at, exam_type, is_published, test_category, passing_score, difficulty_level) VALUES ('fe1ba307-b518-4c28-b5ec-278f7261e15a', 'IELTS Full Mock 001 Test', false, 90, '660c49f1-a752-420e-a27c-fe53a73d71db', '2026-05-02 12:47:43.209982', '2026-05-02 13:42:33.137503', 'IELTS', true, 'full_mock', 70.0, 'hard');
INSERT INTO public.tests (id, title, is_full_mock, total_time_minutes, created_by, created_at, updated_at, exam_type, is_published, test_category, passing_score, difficulty_level) VALUES ('a1e80ec6-b4a7-4abc-944f-a13a5cd8a6de', 'PTE Speaking & Writing Module Practice', false, 77, '660c49f1-a752-420e-a27c-fe53a73d71db', '2026-05-02 12:50:16.491209', '2026-05-02 14:16:20.557403', 'PTE', true, 'module_wise', 50.0, 'hard');


--
-- TOC entry 5328 (class 0 OID 24958)
-- Dependencies: 227
-- Data for Name: user_progress_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5327 (class 0 OID 24936)
-- Dependencies: 226
-- Data for Name: user_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5322 (class 0 OID 24603)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio) VALUES ('46cb0317-1ce3-47f0-9c62-81eccc91fd0a', 'ragesr56@gmail.com', '$2b$10$rdz4kJR.gYkrOC5lBTs1A.sq8ClBqOOhwTdvZ/YUe1EmnsNOxwmfy', 'John Doe', NULL, 'email', 'user', true, '2026-04-21 14:46:29.961396', '2026-04-21 14:40:18.486318', '2026-04-30 23:36:14.095603', 'basic', 0, 'No bio provided');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio) VALUES ('fc44aed3-2a8d-4bca-82e0-fc9e2b6fb4a5', 'azadari87@gmail.com', '$2b$10$Az2BUcRiBZccQmbrpd9jBueSJZQBsiaTg.HHyy1UdWEHQjvEIwA/2', 'Syed Muhammad Asad Abbas', 'https://res.cloudinary.com/dbsfrh5fa/image/upload/v1777571846/testiva/avatars/aekkls7jwhzhyhy03yql.jpg', 'email', 'user', true, '2026-04-30 22:29:43.487863', '2026-04-30 22:11:58.628148', '2026-05-03 13:31:49.256137', 'free', 1, 'IELTS aspirant from Wah Cantt');
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio) VALUES ('660c49f1-a752-420e-a27c-fe53a73d71db', 'nasad8569@gmail.com', '$2b$10$tF7HIGDtS.Fh1RL55vo0nuttSq3MWs1Up6KyIjgaj6BRdAk4Req6W', 'Admin Asad', NULL, 'email', 'admin', true, '2026-05-06 12:05:15.621951', '2026-04-30 23:18:29.343738', '2026-05-03 11:10:19.180363', 'premium', 1, 'No bio provided');


--
-- TOC entry 5355 (class 0 OID 0)
-- Dependencies: 229
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 31, true);


--
-- TOC entry 5089 (class 2606 OID 25144)
-- Name: admin_logs admin_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 25344)
-- Name: ai_feedback ai_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_feedback
    ADD CONSTRAINT ai_feedback_pkey PRIMARY KEY (id);


--
-- TOC entry 5136 (class 2606 OID 42058)
-- Name: comment_likes comment_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (comment_id, user_id);


--
-- TOC entry 5127 (class 2606 OID 42010)
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 5143 (class 2606 OID 42108)
-- Name: moderation_log moderation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5134 (class 2606 OID 42038)
-- Name: post_likes post_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 5140 (class 2606 OID 42081)
-- Name: post_shares post_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_shares
    ADD CONSTRAINT post_shares_pkey PRIMARY KEY (id);


--
-- TOC entry 5125 (class 2606 OID 41982)
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 5098 (class 2606 OID 25240)
-- Name: practice_responses practice_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 25242)
-- Name: practice_responses practice_responses_session_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_session_id_question_id_key UNIQUE (session_id, question_id);


--
-- TOC entry 5094 (class 2606 OID 25222)
-- Name: practice_sessions practice_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_sessions
    ADD CONSTRAINT practice_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5118 (class 2606 OID 41605)
-- Name: prep_media prep_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_media
    ADD CONSTRAINT prep_media_pkey PRIMARY KEY (id);


--
-- TOC entry 5116 (class 2606 OID 41590)
-- Name: prep_parts prep_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_parts
    ADD CONSTRAINT prep_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 5114 (class 2606 OID 41578)
-- Name: preparations preparations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preparations
    ADD CONSTRAINT preparations_pkey PRIMARY KEY (id);


--
-- TOC entry 5066 (class 2606 OID 24867)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 5085 (class 2606 OID 25122)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5087 (class 2606 OID 25124)
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- TOC entry 5108 (class 2606 OID 25294)
-- Name: study_plan_items study_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plan_items
    ADD CONSTRAINT study_plan_items_pkey PRIMARY KEY (id);


--
-- TOC entry 5104 (class 2606 OID 25273)
-- Name: study_plans study_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plans
    ADD CONSTRAINT study_plans_pkey PRIMARY KEY (id);


--
-- TOC entry 5076 (class 2606 OID 25071)
-- Name: temp_users temp_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_key UNIQUE (email);


--
-- TOC entry 5078 (class 2606 OID 25094)
-- Name: temp_users temp_users_email_type_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_type_unique UNIQUE (email, type);


--
-- TOC entry 5080 (class 2606 OID 25082)
-- Name: temp_users temp_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_unique UNIQUE (email);


--
-- TOC entry 5082 (class 2606 OID 25069)
-- Name: temp_users temp_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_pkey PRIMARY KEY (id);


--
-- TOC entry 5069 (class 2606 OID 24924)
-- Name: test_attempts test_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_pkey PRIMARY KEY (id);


--
-- TOC entry 5060 (class 2606 OID 24845)
-- Name: test_sections test_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT test_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 5056 (class 2606 OID 24788)
-- Name: tests tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_pkey PRIMARY KEY (id);


--
-- TOC entry 5062 (class 2606 OID 24847)
-- Name: test_sections unique_test_section_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT unique_test_section_order UNIQUE (test_id, order_number);


--
-- TOC entry 5074 (class 2606 OID 24967)
-- Name: user_progress_stats user_progress_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5072 (class 2606 OID 24946)
-- Name: user_responses user_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 5049 (class 2606 OID 24623)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5051 (class 2606 OID 24621)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5067 (class 1259 OID 24935)
-- Name: idx_attempts_user_test; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_user_test ON public.test_attempts USING btree (user_id, test_id);


--
-- TOC entry 5137 (class 1259 OID 42069)
-- Name: idx_comment_likes_comment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comment_likes_comment_id ON public.comment_likes USING btree (comment_id);


--
-- TOC entry 5128 (class 1259 OID 42029)
-- Name: idx_comments_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_created_at ON public.comments USING btree (created_at DESC);


--
-- TOC entry 5129 (class 1259 OID 42027)
-- Name: idx_comments_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_parent_id ON public.comments USING btree (parent_id);


--
-- TOC entry 5130 (class 1259 OID 42026)
-- Name: idx_comments_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_post_id ON public.comments USING btree (post_id);


--
-- TOC entry 5131 (class 1259 OID 42028)
-- Name: idx_comments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_user_id ON public.comments USING btree (user_id);


--
-- TOC entry 5111 (class 1259 OID 25356)
-- Name: idx_feedback_attempt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_attempt ON public.ai_feedback USING btree (attempt_id);


--
-- TOC entry 5112 (class 1259 OID 25355)
-- Name: idx_feedback_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_user ON public.ai_feedback USING btree (user_id);


--
-- TOC entry 5141 (class 1259 OID 42114)
-- Name: idx_modlog_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_modlog_target ON public.moderation_log USING btree (target_type, target_id);


--
-- TOC entry 5132 (class 1259 OID 42049)
-- Name: idx_post_likes_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_likes_post_id ON public.post_likes USING btree (post_id);


--
-- TOC entry 5138 (class 1259 OID 42092)
-- Name: idx_post_shares_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_shares_post_id ON public.post_shares USING btree (post_id);


--
-- TOC entry 5119 (class 1259 OID 41991)
-- Name: idx_posts_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_created_at ON public.posts USING btree (created_at DESC);


--
-- TOC entry 5120 (class 1259 OID 41992)
-- Name: idx_posts_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_deleted_at ON public.posts USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- TOC entry 5121 (class 1259 OID 41990)
-- Name: idx_posts_is_flagged; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_is_flagged ON public.posts USING btree (is_flagged);


--
-- TOC entry 5122 (class 1259 OID 41989)
-- Name: idx_posts_topic_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_topic_tag ON public.posts USING btree (topic_tag);


--
-- TOC entry 5123 (class 1259 OID 41988)
-- Name: idx_posts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_user_id ON public.posts USING btree (user_id);


--
-- TOC entry 5095 (class 1259 OID 25257)
-- Name: idx_practice_responses_question; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_responses_question ON public.practice_responses USING btree (question_id);


--
-- TOC entry 5096 (class 1259 OID 25256)
-- Name: idx_practice_responses_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_responses_session ON public.practice_responses USING btree (session_id);


--
-- TOC entry 5090 (class 1259 OID 25254)
-- Name: idx_practice_sessions_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_sessions_section ON public.practice_sessions USING btree (section_name);


--
-- TOC entry 5091 (class 1259 OID 25255)
-- Name: idx_practice_sessions_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_sessions_status ON public.practice_sessions USING btree (status);


--
-- TOC entry 5092 (class 1259 OID 25253)
-- Name: idx_practice_sessions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_sessions_user ON public.practice_sessions USING btree (user_id);


--
-- TOC entry 5063 (class 1259 OID 33377)
-- Name: idx_questions_difficulty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_difficulty ON public.questions USING btree (difficulty);


--
-- TOC entry 5064 (class 1259 OID 24873)
-- Name: idx_questions_section_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_section_id ON public.questions USING btree (section_id);


--
-- TOC entry 5083 (class 1259 OID 25131)
-- Name: idx_refresh_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_user ON public.refresh_tokens USING btree (user_id);


--
-- TOC entry 5070 (class 1259 OID 24957)
-- Name: idx_responses_attempt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_responses_attempt ON public.user_responses USING btree (attempt_id);


--
-- TOC entry 5057 (class 1259 OID 33376)
-- Name: idx_sections_question_types; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_question_types ON public.test_sections USING gin (question_types_allowed);


--
-- TOC entry 5058 (class 1259 OID 24853)
-- Name: idx_sections_test_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_test_id ON public.test_sections USING btree (test_id);


--
-- TOC entry 5105 (class 1259 OID 25303)
-- Name: idx_study_plan_items_day; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plan_items_day ON public.study_plan_items USING btree (day_number);


--
-- TOC entry 5106 (class 1259 OID 25302)
-- Name: idx_study_plan_items_plan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plan_items_plan ON public.study_plan_items USING btree (plan_id);


--
-- TOC entry 5101 (class 1259 OID 25301)
-- Name: idx_study_plans_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plans_status ON public.study_plans USING btree (status);


--
-- TOC entry 5102 (class 1259 OID 25300)
-- Name: idx_study_plans_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plans_user ON public.study_plans USING btree (user_id);


--
-- TOC entry 5052 (class 1259 OID 33373)
-- Name: idx_tests_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tests_category ON public.tests USING btree (test_category);


--
-- TOC entry 5053 (class 1259 OID 33374)
-- Name: idx_tests_exam_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tests_exam_type ON public.tests USING btree (exam_type);


--
-- TOC entry 5054 (class 1259 OID 33375)
-- Name: idx_tests_published; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tests_published ON public.tests USING btree (is_published);


--
-- TOC entry 5046 (class 1259 OID 24624)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 5047 (class 1259 OID 24625)
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- TOC entry 5153 (class 2606 OID 25145)
-- Name: admin_logs admin_logs_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5154 (class 2606 OID 25150)
-- Name: admin_logs admin_logs_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5160 (class 2606 OID 25345)
-- Name: ai_feedback ai_feedback_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_feedback
    ADD CONSTRAINT ai_feedback_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE;


--
-- TOC entry 5161 (class 2606 OID 25350)
-- Name: ai_feedback ai_feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_feedback
    ADD CONSTRAINT ai_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5170 (class 2606 OID 42059)
-- Name: comment_likes comment_likes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_likes
    ADD CONSTRAINT comment_likes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5171 (class 2606 OID 42064)
-- Name: comment_likes comment_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_likes
    ADD CONSTRAINT comment_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5165 (class 2606 OID 42021)
-- Name: comments comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5166 (class 2606 OID 42011)
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5167 (class 2606 OID 42016)
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5174 (class 2606 OID 42109)
-- Name: moderation_log moderation_log_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id);


--
-- TOC entry 5168 (class 2606 OID 42039)
-- Name: post_likes post_likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5169 (class 2606 OID 42044)
-- Name: post_likes post_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5172 (class 2606 OID 42082)
-- Name: post_shares post_shares_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_shares
    ADD CONSTRAINT post_shares_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5173 (class 2606 OID 42087)
-- Name: post_shares post_shares_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_shares
    ADD CONSTRAINT post_shares_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5164 (class 2606 OID 41983)
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5156 (class 2606 OID 25248)
-- Name: practice_responses practice_responses_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- TOC entry 5157 (class 2606 OID 25243)
-- Name: practice_responses practice_responses_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.practice_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5155 (class 2606 OID 25223)
-- Name: practice_sessions practice_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_sessions
    ADD CONSTRAINT practice_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5163 (class 2606 OID 41606)
-- Name: prep_media prep_media_prep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_media
    ADD CONSTRAINT prep_media_prep_id_fkey FOREIGN KEY (prep_id) REFERENCES public.preparations(id) ON DELETE CASCADE;


--
-- TOC entry 5162 (class 2606 OID 41591)
-- Name: prep_parts prep_parts_prep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_parts
    ADD CONSTRAINT prep_parts_prep_id_fkey FOREIGN KEY (prep_id) REFERENCES public.preparations(id) ON DELETE CASCADE;


--
-- TOC entry 5146 (class 2606 OID 24868)
-- Name: questions questions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.test_sections(id) ON DELETE CASCADE;


--
-- TOC entry 5152 (class 2606 OID 25125)
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5159 (class 2606 OID 25295)
-- Name: study_plan_items study_plan_items_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plan_items
    ADD CONSTRAINT study_plan_items_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.study_plans(id) ON DELETE CASCADE;


--
-- TOC entry 5158 (class 2606 OID 25274)
-- Name: study_plans study_plans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plans
    ADD CONSTRAINT study_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5147 (class 2606 OID 24930)
-- Name: test_attempts test_attempts_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 5148 (class 2606 OID 24925)
-- Name: test_attempts test_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5145 (class 2606 OID 24848)
-- Name: test_sections test_sections_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT test_sections_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 5144 (class 2606 OID 24789)
-- Name: tests tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5151 (class 2606 OID 24968)
-- Name: user_progress_stats user_progress_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5149 (class 2606 OID 24947)
-- Name: user_responses user_responses_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE;


--
-- TOC entry 5150 (class 2606 OID 24952)
-- Name: user_responses user_responses_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


-- Completed on 2026-05-07 20:31:10

--
-- PostgreSQL database dump complete
--

\unrestrict pSLodzM6isrhF6P7tXMIwt8o9KMhR8kssuxiAJobFOCnBw0k4ccBorDoSXEq12b

