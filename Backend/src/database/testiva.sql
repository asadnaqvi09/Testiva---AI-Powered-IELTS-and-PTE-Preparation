--
-- PostgreSQL database dump
--

\restrict x32DtVlKzAPksLoRDI9OPpmpCYBxd0t4hXGDdVPGKuFVEySzU4V0rVFMuBf3a4U

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-05-16 11:55:43

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
-- TOC entry 5386 (class 1262 OID 16388)
-- Name: Testiva_FYP; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Testiva_FYP" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE "Testiva_FYP" OWNER TO postgres;

\unrestrict x32DtVlKzAPksLoRDI9OPpmpCYBxd0t4hXGDdVPGKuFVEySzU4V0rVFMuBf3a4U
\connect "Testiva_FYP"
\restrict x32DtVlKzAPksLoRDI9OPpmpCYBxd0t4hXGDdVPGKuFVEySzU4V0rVFMuBf3a4U

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
-- TOC entry 5387 (class 0 OID 0)
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
-- TOC entry 5388 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1003 (class 1247 OID 41630)
-- Name: admin_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.admin_status AS ENUM (
    'none',
    'flagged',
    'removed'
);


ALTER TYPE public.admin_status OWNER TO postgres;

--
-- TOC entry 952 (class 1247 OID 24898)
-- Name: attempt_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.attempt_status_enum AS ENUM (
    'in_progress',
    'completed',
    'synced'
);


ALTER TYPE public.attempt_status_enum OWNER TO postgres;

--
-- TOC entry 1051 (class 1247 OID 42335)
-- Name: difficulty_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.difficulty_enum AS ENUM (
    'easy',
    'medium',
    'hard'
);


ALTER TYPE public.difficulty_enum OWNER TO postgres;

--
-- TOC entry 1009 (class 1247 OID 41936)
-- Name: flag_source; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.flag_source AS ENUM (
    'ai',
    'admin'
);


ALTER TYPE public.flag_source OWNER TO postgres;

--
-- TOC entry 940 (class 1247 OID 24816)
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
-- TOC entry 943 (class 1247 OID 24828)
-- Name: lesson_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.lesson_status_enum AS ENUM (
    'draft',
    'published'
);


ALTER TYPE public.lesson_status_enum OWNER TO postgres;

--
-- TOC entry 1030 (class 1247 OID 42118)
-- Name: moderation_action; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.moderation_action AS ENUM (
    'flag',
    'unflag',
    'delete'
);


ALTER TYPE public.moderation_action OWNER TO postgres;

--
-- TOC entry 1036 (class 1247 OID 42153)
-- Name: notification_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.notification_type AS ENUM (
    'post_like',
    'comment_like',
    'post_comment',
    'comment_reply',
    'post_flagged',
    'post_unflagged',
    'post_deleted',
    'admin_new_user',
    'admin_subscription_changed',
    'admin_new_post'
);


ALTER TYPE public.notification_type OWNER TO postgres;

--
-- TOC entry 970 (class 1247 OID 25073)
-- Name: otp_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.otp_type AS ENUM (
    'register',
    'reset'
);


ALTER TYPE public.otp_type OWNER TO postgres;

--
-- TOC entry 1045 (class 1247 OID 42279)
-- Name: section_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.section_type_enum AS ENUM (
    'reading',
    'listening',
    'writing',
    'speaking'
);


ALTER TYPE public.section_type_enum OWNER TO postgres;

--
-- TOC entry 1012 (class 1247 OID 41942)
-- Name: share_platform; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.share_platform AS ENUM (
    'twitter',
    'instagram',
    'whatsapp',
    'facebook',
    'copy_link'
);


ALTER TYPE public.share_platform OWNER TO postgres;

--
-- TOC entry 964 (class 1247 OID 25050)
-- Name: subscription_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.subscription_status_enum AS ENUM (
    'free',
    'basic',
    'premium'
);


ALTER TYPE public.subscription_status_enum OWNER TO postgres;

--
-- TOC entry 1048 (class 1247 OID 42300)
-- Name: test_category_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.test_category_enum AS ENUM (
    'full_mock',
    'reading',
    'writing',
    'listening',
    'speaking'
);


ALTER TYPE public.test_category_enum OWNER TO postgres;

--
-- TOC entry 937 (class 1247 OID 24810)
-- Name: test_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.test_type_enum AS ENUM (
    'IELTS',
    'PTE'
);


ALTER TYPE public.test_type_enum OWNER TO postgres;

--
-- TOC entry 1006 (class 1247 OID 41929)
-- Name: topic_tag; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.topic_tag AS ENUM (
    'IELTS',
    'PTE',
    'General'
);


ALTER TYPE public.topic_tag OWNER TO postgres;

--
-- TOC entry 1042 (class 1247 OID 42203)
-- Name: user_preference; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_preference AS ENUM (
    'IELTS',
    'PTE',
    'NULL'
);


ALTER TYPE public.user_preference OWNER TO postgres;

--
-- TOC entry 928 (class 1247 OID 24588)
-- Name: user_role_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_role_enum AS ENUM (
    '',
    'user',
    'admin'
);


ALTER TYPE public.user_role_enum OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 42215)
-- Name: notify_subscription_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_subscription_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF NEW.subscription IS DISTINCT FROM OLD.subscription THEN
          PERFORM pg_notify('subscription_changes', json_build_object(
            'user_id', NEW.id,
            'full_name', NEW.full_name,
            'old_sub', OLD.subscription,
            'new_sub', NEW.subscription
          )::text);
        END IF;
        RETURN NEW;
      END;
      $$;


ALTER FUNCTION public.notify_subscription_change() OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 41734)
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- TOC entry 231 (class 1259 OID 25133)
-- Name: admin_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    action character varying(50) NOT NULL,
    target_user_id uuid,
    details jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.admin_logs OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 25331)
-- Name: ai_feedback; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- TOC entry 243 (class 1259 OID 42050)
-- Name: comment_likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comment_likes (
    comment_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.comment_likes OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 41993)
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- TOC entry 245 (class 1259 OID 42125)
-- Name: moderation_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moderation_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    post_id uuid NOT NULL,
    action public.moderation_action NOT NULL,
    admin_feedback text,
    email_sent boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.moderation_log OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 42167)
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    actor_id uuid,
    post_id uuid,
    comment_id uuid,
    type public.notification_type NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 42030)
-- Name: post_likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_likes (
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_likes OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 42070)
-- Name: post_shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.post_shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    platform public.share_platform NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.post_shares OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 41963)
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- TOC entry 233 (class 1259 OID 25228)
-- Name: practice_responses; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- TOC entry 232 (class 1259 OID 25205)
-- Name: practice_sessions; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- TOC entry 239 (class 1259 OID 41596)
-- Name: prep_media; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- TOC entry 238 (class 1259 OID 41581)
-- Name: prep_parts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prep_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prep_id uuid,
    part_title character varying(255),
    part_content text,
    order_index integer DEFAULT 0
);


ALTER TABLE public.prep_parts OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 41566)
-- Name: preparations; Type: TABLE; Schema: public; Owner: postgres
--

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
    options jsonb DEFAULT '[]'::jsonb,
    correct_answer jsonb DEFAULT '{}'::jsonb,
    audio_url text,
    order_number integer NOT NULL,
    marks numeric(3,1) DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    difficulty public.difficulty_enum DEFAULT 'medium'::public.difficulty_enum,
    tags jsonb DEFAULT '[]'::jsonb,
    image_url text,
    content jsonb DEFAULT '{}'::jsonb,
    sub_question_type character varying(50),
    prep_time_seconds integer DEFAULT 0,
    record_time_seconds integer DEFAULT 0,
    min_words integer DEFAULT 0,
    max_words integer DEFAULT 0,
    word_limit_instruction text
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 25110)
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
-- TOC entry 229 (class 1259 OID 25109)
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
-- TOC entry 5389 (class 0 OID 0)
-- Dependencies: 229
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

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
    section_name character varying(255) NOT NULL,
    time_limit_minutes integer NOT NULL,
    order_number integer NOT NULL,
    instructions text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    question_types_allowed jsonb DEFAULT '[]'::jsonb,
    task_count integer DEFAULT 1,
    section_type public.section_type_enum,
    sub_type character varying(50)
);


ALTER TABLE public.test_sections OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 24776)
-- Name: tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(255) NOT NULL,
    total_duration integer CONSTRAINT tests_total_time_minutes_not_null NOT NULL,
    created_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    exam_type public.test_type_enum NOT NULL,
    is_published boolean DEFAULT false,
    passing_score numeric(3,1) DEFAULT 6.5,
    difficulty_level public.difficulty_enum DEFAULT 'medium'::public.difficulty_enum,
    is_premium boolean DEFAULT false,
    test_category public.test_category_enum DEFAULT 'full_mock'::public.test_category_enum NOT NULL,
    display_id character varying(20),
    min_required_band numeric(3,1) DEFAULT 6.0
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ai_metrics jsonb DEFAULT '{}'::jsonb,
    time_taken_seconds integer,
    word_count integer DEFAULT 0,
    time_spent_seconds integer DEFAULT 0
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
    bio text DEFAULT 'No bio provided'::text,
    preference public.user_preference,
    fcm_token text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5014 (class 2604 OID 25113)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 5365 (class 0 OID 25133)
-- Dependencies: 231
-- Data for Name: admin_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('9b548522-4ceb-4ebf-a89b-4e4acfe95fec', '660c49f1-a752-420e-a27c-fe53a73d71db', 'Subscription Change', NULL, '{"message": "Changed subscription to basic"}', '2026-04-30 23:36:14.098673');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('a54b095f-29d7-42e4-94a8-74e89cceaf58', '660c49f1-a752-420e-a27c-fe53a73d71db', 'Subscription Change', NULL, '{"message": "Changed subscription to basic"}', '2026-05-03 13:31:46.098364');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('4aed160a-ac29-4c56-802b-135ab78bec83', '660c49f1-a752-420e-a27c-fe53a73d71db', 'Subscription Change', NULL, '{"message": "Changed subscription to free"}', '2026-05-03 13:31:49.257461');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('ffcc1b03-8eba-4c3d-9fd7-624be7a2735d', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to premium"}', '2026-05-13 19:45:30.979932');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('a271ab01-d058-4848-bdca-ad5bb8299579', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to premium"}', '2026-05-13 19:58:16.329467');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('d917f0f9-f7b0-44a0-96a4-f133eee9a2af', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to premium"}', '2026-05-13 20:06:50.307906');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('2137649c-9492-4873-9601-faa26821f339', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', 'f81c2b76-cf4c-4718-8872-ba3afc90af2a', '{"message": "Changed subscription to free"}', '2026-05-13 20:09:59.581323');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('4d1c22ab-7ea9-4180-ad81-934d6500cbf7', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to premium"}', '2026-05-13 20:17:23.858769');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('669341ca-cd95-4032-8803-02c1ee4da87a', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:17:35.804385');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('66696687-12b7-44ab-90c4-4c414098f905', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:24:41.304062');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('c448382e-a89b-4dc1-997b-23921e854895', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:26:33.735065');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('19236726-b1c2-4715-a935-0387f4f8b1c6', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:34:55.921935');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('78105c3f-3055-4723-9d52-34f7b9030e79', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:35:08.065972');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('702682e0-edb2-4675-9dc5-30dcb86fc192', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:35:11.737799');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('a4f410de-a858-4a98-9d78-6aea59538dd2', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:36:09.230081');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('146ee0ed-b748-45c2-bb77-0105f608d26d', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to free"}', '2026-05-13 20:41:26.38322');
INSERT INTO public.admin_logs (id, admin_id, action, target_user_id, details, created_at) VALUES ('c90e95e6-e669-4a4d-b82b-e5a198770977', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'Subscription Change', '660c49f1-a752-420e-a27c-fe53a73d71db', '{"message": "Changed subscription to premium"}', '2026-05-13 22:15:36.836687');


--
-- TOC entry 5370 (class 0 OID 25331)
-- Dependencies: 236
-- Data for Name: ai_feedback; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5377 (class 0 OID 42050)
-- Dependencies: 243
-- Data for Name: comment_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5375 (class 0 OID 41993)
-- Dependencies: 241
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5379 (class 0 OID 42125)
-- Dependencies: 245
-- Data for Name: moderation_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('55b34e80-d69c-49a2-b3b8-e38cc10a07bc', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'flag', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', true, '2026-05-13 11:24:53.478773+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('25c32603-8e1c-4f67-a5ba-cb43ca612a58', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'unflag', NULL, false, '2026-05-13 11:30:17.756328+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('86b2c170-ed8e-4c77-8a79-3e14ec6efbf7', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'flag', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', true, '2026-05-13 11:30:33.834997+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('e13b6f22-c8ce-47e7-a52e-324e3198dd8f', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'unflag', NULL, false, '2026-05-13 11:34:01.248609+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('3fd20ca3-ab98-4495-97dd-14e50e375c2d', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'flag', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', true, '2026-05-13 11:34:16.426602+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('307b6489-ab77-48e3-ba03-92222c5a7626', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'unflag', NULL, false, '2026-05-13 11:44:05.433779+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('b740c8c7-bb28-4211-b104-6367aa0c88b0', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'flag', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', true, '2026-05-13 11:44:16.665802+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('7fc3d0ae-a8f0-4f5d-a04e-40daef082995', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'unflag', NULL, false, '2026-05-13 11:51:47.771761+05');
INSERT INTO public.moderation_log (id, admin_id, post_id, action, admin_feedback, email_sent, created_at) VALUES ('978273a1-5084-4719-ae1c-4a0ec27452da', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '57bb735d-452f-468a-bd1a-dac28b145e2c', 'flag', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', true, '2026-05-13 11:51:55.871951+05');


--
-- TOC entry 5380 (class 0 OID 42167)
-- Dependencies: 246
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.notifications (id, user_id, actor_id, post_id, comment_id, type, title, message, is_read, created_at) VALUES ('f3e6c124-ed5a-4a30-ab52-821aa7ba08f3', 'f81c2b76-cf4c-4718-8872-ba3afc90af2a', NULL, NULL, NULL, 'post_flagged', 'Post Flagged', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', false, '2026-05-13 11:51:55.884527+05');
INSERT INTO public.notifications (id, user_id, actor_id, post_id, comment_id, type, title, message, is_read, created_at) VALUES ('d1c93164-258e-484a-ac1d-c3f3c9f72d12', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '660c49f1-a752-420e-a27c-fe53a73d71db', NULL, NULL, 'admin_subscription_changed', 'Manual Subscription Update', 'Admin Asad''s subscription was manually changed from premium to free.', false, '2026-05-13 20:17:35.818806+05');
INSERT INTO public.notifications (id, user_id, actor_id, post_id, comment_id, type, title, message, is_read, created_at) VALUES ('ea2b4697-9775-476c-8fa9-e53904828084', '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', '660c49f1-a752-420e-a27c-fe53a73d71db', NULL, NULL, 'admin_subscription_changed', 'Manual Subscription Update', 'Admin Asad''s subscription was manually changed from free to premium.', false, '2026-05-13 22:15:37.068036+05');


--
-- TOC entry 5376 (class 0 OID 42030)
-- Dependencies: 242
-- Data for Name: post_likes; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5378 (class 0 OID 42070)
-- Dependencies: 244
-- Data for Name: post_shares; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5374 (class 0 OID 41963)
-- Dependencies: 240
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.posts (id, user_id, topic_tag, title, content, is_flagged, flagged_by, flag_reason, deleted_at, created_at, updated_at) VALUES ('57bb735d-452f-468a-bd1a-dac28b145e2c', 'f81c2b76-cf4c-4718-8872-ba3afc90af2a', 'IELTS', 'Need IELTS writing tips', 'How can I improve coherence and cohesion?', true, 'admin', 'Your post has been removed because it violates our Community Guidelines. Please ensure all content is respectful, relevant, and appropriate for an academic learning environment.', NULL, '2026-05-09 14:01:57.009047+05', '2026-05-13 11:51:53.710632+05');


--
-- TOC entry 5367 (class 0 OID 25228)
-- Dependencies: 233
-- Data for Name: practice_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5366 (class 0 OID 25205)
-- Dependencies: 232
-- Data for Name: practice_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5373 (class 0 OID 41596)
-- Dependencies: 239
-- Data for Name: prep_media; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('41d7b598-2197-4251-a4a0-c2765adce8bb', '0743bc02-cbee-4ed7-9b77-59951d3d83e8', 'https://placeholder.com/ielts-academic-writing-sample-tasks-2023.pdf', 'ielts-academic-writing-sample-tasks-2023.pdf', '2026-05-13 10:39:01.829403', 1, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('3bfb5b21-d519-4d29-be3f-6737fe09b985', 'a01ad9f9-11af-4d58-8679-6bab26d6e75c', 'https://placeholder.com/ielts-academic-reading-sample-tasks-2023.pdf', 'ielts-academic-reading-sample-tasks-2023.pdf', '2026-05-14 14:24:51.254361', 912, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('a8f344d3-dfff-483a-b4da-05facd19d3a6', '98cc1119-6a29-47dc-9435-412e6f097647', 'https://placeholder.com/ielts-listening-sample-tasks-2023.pdf', 'ielts-listening-sample-tasks-2023.pdf', '2026-05-14 14:28:32.838539', 519, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('7041d916-26f3-402c-80db-9cb15d50d204', '3e11922a-537c-4a1e-a936-c79af934ce15', 'https://res.cloudinary.com/dbsfrh5fa/raw/upload/v1778751500/testiva/documents/1778751495115-PTE-Reading-Practice-Test-9.pdf', 'PTE-Reading-Practice.pdf', '2026-05-14 14:39:59.034901', 90096, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('78fff146-43cc-4de4-9154-bcd88cc3f1c7', '0e6a6611-80a1-455e-805f-abd2265d65b4', 'https://res.cloudinary.com/dbsfrh5fa/raw/upload/v1778751870/testiva/documents/1778751865317-PTE-Listening-Practice-Test-7.pdf', 'pte-listening-strategies.pdf', '2026-05-14 14:45:13.788473', 74173, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('67c95f9d-9d3e-4a0a-8079-5d9ce7eb11e4', '0a85f43e-e16e-47dc-93fb-549f705878a3', 'https://res.cloudinary.com/dbsfrh5fa/raw/upload/v1778751984/testiva/documents/1778751980805-PTE-Writing-Practice-test-2.pdf', 'pte-speaking-strategies.pdf', '2026-05-14 14:46:56.777784', 52980, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('469515bd-182f-4246-8324-31421393c538', '30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'https://res.cloudinary.com/dbsfrh5fa/raw/upload/v1778751984/testiva/documents/1778751980805-PTE-Writing-Practice-test-2.pdf', 'pte-writing-strategies.pdf', '2026-05-14 14:47:33.536223', 52980, 'application/pdf');
INSERT INTO public.prep_media (id, prep_id, file_url, file_name, created_at, file_size, file_type) VALUES ('25e8ac12-ed19-4091-9b0d-28544282eeea', 'c5531fba-586a-44dc-ae11-ea966b1ef5b0', 'https://placeholder.com/ielts-speaking-sample-tasks-2023.pdf', 'ielts-speaking-sample-tasks-2023.pdf', '2026-05-14 14:51:42.761617', 470, 'application/pdf');


--
-- TOC entry 5372 (class 0 OID 41581)
-- Dependencies: 238
-- Data for Name: prep_parts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('8f48c45b-7604-4a06-b8d8-d0c6668552b2', '0743bc02-cbee-4ed7-9b77-59951d3d83e8', 'Part 1 : Writing Fundamentals', '📚 Task 1 vs Task 2
Task 1 (20 min, 150 words): Describe a graph, chart, or diagram. Task 2 (40 min, 250 words): Write an essay responding to a point of view or argument.
💡 Task Achievement
For Task 2, make sure you fully address all parts of the question. Many students lose marks by only partially answering the prompt.
📚 Coherence & Cohesion
Use linking words: Furthermore, In addition, However, On the other hand, In conclusion. Structure your essay: Introduction → Body × 2 → Conclusion
💡 Vocabulary Range
Avoid repeating the same words. Use synonyms: big→significant, show→demonstrate, important→crucial. This directly impacts your Lexical Resource score.
🎯 Grammar Quiz
Identify the error: "The graph show a increase in temperature." Correction: "The graph shows AN increase in temperature." (subject-verb agreement + article)', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('d4c536b9-a57c-40e8-a093-21f78e6987ba', '0743bc02-cbee-4ed7-9b77-59951d3d83e8', 'Part 2 Essay Writing', '📚 Essay Introduction Template
Paraphrase the question → State your position. Example: "It is argued that technology has improved education. While this view has merit, I believe its benefits must be carefully managed."
💡 Body Paragraph Structure
PEEL method: Point → Explain → Evidence → Link back. Each body paragraph should develop ONE main idea with supporting details and examples.
🎯 Sample Essay Analysis
Topic: "Online education is as effective as traditional education." Analyze: This is a "discuss both views" essay. Present pros and cons with your own conclusion.', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('d0b957fa-7473-4b09-ad33-79fa490276e1', 'a01ad9f9-11af-4d58-8679-6bab26d6e75c', 'Introduction To Reading', '📚 Types of Reading Questions
IELTS Reading includes MCQ, True/False/Not Given, Matching Headings, Summary Completion, and Short Answer questions. Understanding each type is crucial for effective preparation.
💡 Skimming and Scanning
Skimming means reading quickly for the main idea. Scanning means looking for specific information. Practice both until they become second nature.
📚 Time Management
You have 60 minutes for 40 questions (3 passages). Allocate about 20 minutes per passage. Never spend more than 2 minutes on a single question.
🎯 Quick Quiz: Question Types
Q: What should you do first when starting a reading passage? A) Read every word carefully B) Skim for the main idea C) Read all questions first. Answer: B – Skim first to understand the topic.
💡 Vocabulary in Context
Use context clues to deduce unknown words. Look at the words before and after the unfamiliar term. This skill is tested heavily in all IELTS sections.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('05f6aaf7-a494-4270-aed1-09f3fbc6a750', 'a01ad9f9-11af-4d58-8679-6bab26d6e75c', 'Advanced Strategies', '📚 True/False/Not Given Mastery
"Not Given" means the passage neither confirms nor contradicts the statement. This is the most common trap. Never assume – only use passage evidence.
💡 Matching Headings Strategy
Read the first and last sentence of each paragraph. The main idea is usually there. Match that to a heading before reading the full paragraph.
📚 Summary Completion Tips
Look for paraphrased language in summaries. The answer is usually one or two words taken directly from the passage. Keep to the word limit.
🎯 Practice Exercise
Read this: "Climate change poses a significant threat to biodiversity." Now answer: Does the passage state this is the biggest threat? Answer: Not Given – no comparison is made', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('6d9e6322-6fe4-471e-bd79-75b72350e971', 'a01ad9f9-11af-4d58-8679-6bab26d6e75c', 'Practice & Review', '💡 Daily Reading Habit
Read academic articles from The Economist, BBC News, or Scientific American for 30 minutes daily. This builds vocabulary and comprehension naturally.
📚 Sample Passage Practice
Lorem ipsum: "The industrial revolution fundamentally transformed how societies organized work and production. The shift from agrarian to urban living reshaped social structures globally."
🎯 Final Review Quiz
Q: How many passages are in IELTS Academic Reading? Answer: 3 passages, each with 12-14 questions, totaling 40 questions in 60 minutes.', 3);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('e7edf4d9-4b74-49fe-bceb-fa567c582e6c', '98cc1119-6a29-47dc-9435-412e6f097647', 'Listening Basics', '📚 Test Structure
IELTS Listening: 4 sections, 40 questions, approximately 30 minutes + 10 min transfer time. Sections go from easy (everyday) to difficult (academic monologue).
💡 Prediction Skills
Always read the questions BEFORE listening. Predict what type of information you need (name, number, date, place). This dramatically improves accuracy.
📚 Spelling Matters
Answers are marked wrong for spelling errors even if the answer is correct. Practice spelling common words: accommodation, necessary, government, environment.
💡 Distractor Awareness
Speakers often give one answer then correct themselves. Listen for "Actually, I meant..." or "Sorry, let me correct that..." The FINAL answer is correct.
🎯 Practice Task
Listen activity: Tune into BBC Radio 4 daily. Practice noting key information: names, numbers, places. Try to write them while listening without pausing.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('346aceda-dda4-49d5-87ee-a4eb98479aff', '98cc1119-6a29-47dc-9435-412e6f097647', 'Advanced Listening', '📚 Multiple Choice Strategies
Eliminate obviously wrong answers first. The correct answer usually paraphrases what was said, not repeats it verbatim. Watch for synonyms.
💡 Map & Diagram Questions
Study the map/diagram carefully before listening. Note reference points. Track speaker descriptions carefully – they often use directional language (opposite, next to, between).
🎯 Numbers & Dates
Common traps: 13 vs 30, 14 vs 40, 50 vs 15. Dates can be written as: 5th May OR May 5th. Make sure to write them correctly.', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('c0bad74d-d306-45f7-b686-d343322e0d75', '3e11922a-537c-4a1e-a936-c79af934ce15', 'Understand the PTE Reading Structure', 'Before attempting the exam, candidates must understand that the PTE Reading section tests both comprehension and speed. The section usually contains multiple question types including Fill in the Blanks, Reorder Paragraphs, Multiple Choice Questions, and Reading & Writing integrated tasks. Students should avoid spending too much time on one question because every second matters in PTE. A strong understanding of the exam structure reduces panic during the actual test.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('8ab8144c-cb9a-4879-bea7-66e21bf7f0f1', '3e11922a-537c-4a1e-a936-c79af934ce15', 'Skimming and Scanning Techniques', 'Skimming helps identify the main idea of a paragraph quickly while scanning helps locate keywords and specific information. During the test, students should first skim the passage to understand the topic and tone. After that, they should scan for names, dates, keywords, and transition words that connect ideas together. These techniques improve reading speed and reduce unnecessary rereading.', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('ea777c76-5e97-42fa-a380-7e57449439d3', '3e11922a-537c-4a1e-a936-c79af934ce15', 'Mastering Reorder Paragraph Questions', 'In Reorder Paragraph tasks, students should identify the opening sentence first because it usually introduces the main topic without using pronouns. After finding the introduction, look for logical connectors such as however, therefore, additionally, and meanwhile. Pronouns like he, she, they, or this often refer to information mentioned in previous sentences. Building these logical relationships increases accuracy significantly.', 3);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('2c52faf3-6c0c-4712-8a08-a4b5694442ae', '3e11922a-537c-4a1e-a936-c79af934ce15', 'Smart Time Management Strategy', 'Time management is one of the biggest factors in achieving a high PTE Reading score. Students should not spend more than two minutes on difficult questions. If an answer seems confusing, make the best possible choice and move forward. Keeping track of time prevents panic in the final minutes of the test. Practicing under timed conditions before the real exam is highly recommended.', 4);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('63c8186c-ea7e-48ea-b92c-95add4ded9d2', '3e11922a-537c-4a1e-a936-c79af934ce15', 'Avoid Common Reading Mistakes', 'Many students lose marks because they read every word slowly or change answers repeatedly. Candidates should trust their first logical choice unless there is clear evidence it is wrong. Another common mistake is ignoring grammar clues in Fill in the Blanks questions. Reading newspapers, academic articles, and sample passages daily can gradually improve vocabulary and comprehension skills.', 5);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('ad755937-07c0-43e3-a51d-090588350fba', '0e6a6611-80a1-455e-805f-abd2265d65b4', 'Understand the PTE Listening Format', 'The PTE Listening section contains several task types including Summarize Spoken Text, Multiple Choice Questions, Fill in the Blanks, Highlight Incorrect Words, Select Missing Word, and Write From Dictation. Students should understand that audio plays only once, so full concentration is extremely important. Losing focus for even a few seconds can affect the answer. Practicing with headphones before the exam helps improve listening accuracy and comfort during the actual test.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('0c78472f-a57d-42e4-8631-8b78bbd4b3bf', '0e6a6611-80a1-455e-805f-abd2265d65b4', 'Develop Effective Note-Taking Skills', 'Good note-taking is one of the most important listening skills in PTE. Students should not try to write every sentence because it wastes time and causes loss of concentration. Instead, focus on keywords, numbers, names, transitions, and repeated ideas. Use short forms and symbols while listening. Fast note-taking helps students remember important information when answering questions after the recording ends.', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('14e082ce-102c-411b-98ab-50b5d329cd18', '0e6a6611-80a1-455e-805f-abd2265d65b4', 'Improve Focus and Active Listening', 'Many candidates understand English well but still lose marks because their attention breaks during long recordings. Active listening means mentally following the speaker’s ideas while identifying tone, purpose, and important arguments. Students should practice listening to podcasts, lectures, and academic discussions daily. Avoid translating into your native language during the exam because it slows understanding and creates confusion.', 3);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('cd25a699-5534-46a5-8b2e-54232fc78359', '0e6a6611-80a1-455e-805f-abd2265d65b4', 'Master Fill in the Blanks and Dictation', 'Fill in the Blanks and Write From Dictation are high-scoring question types in PTE Listening. Students should improve spelling, grammar, and typing speed because small mistakes can reduce marks. Predicting the type of missing word before hearing it improves accuracy. During dictation tasks, focus on sentence structure and common collocations. Repeated listening practice with subtitles can help improve recognition of fast English speech patterns.', 4);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('0028ef79-3222-4300-a0c3-8138f8fc5ce5', '0e6a6611-80a1-455e-805f-abd2265d65b4', 'Handle Difficult Audio Accents and Speed', 'PTE recordings may contain different English accents including British, Australian, and American speakers. Students should expose themselves to different accents before the exam through YouTube lectures, news channels, and podcasts. If the speaker talks quickly, do not panic. Focus on understanding the main idea and keywords instead of every single word. Staying calm under pressure improves listening performance significantly.', 5);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('38549509-ef96-49e5-a0f9-bc3ce387d095', '0a85f43e-e16e-47dc-93fb-549f705878a3', 'Understand the PTE Speaking Tasks', 'The PTE Speaking section includes Read Aloud, Repeat Sentence, Describe Image, Re-tell Lecture, and Answer Short Questions. Students should understand the format of every task before the exam because hesitation and confusion reduce fluency scores. Confidence and clarity are extremely important during speaking tasks. Regular practice with a microphone can help students become comfortable with the computer-based speaking environment.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('d722c5a8-33bc-4481-a1fa-672a29f39c6d', '0a85f43e-e16e-47dc-93fb-549f705878a3', 'Improve Pronunciation and Fluency', 'Pronunciation does not mean speaking with a foreign accent. The goal is to speak clearly so the system understands every word correctly. Students should avoid speaking too fast because unclear speech affects scores negatively. Fluency improves through daily English speaking practice, shadowing native speakers, and reading aloud from articles or books. Small pauses are acceptable, but long hesitations should be avoided.', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('c96956ea-6a5f-41b2-89cc-25ca201092e8', '0a85f43e-e16e-47dc-93fb-549f705878a3', 'Master Repeat Sentence Strategy', 'Repeat Sentence is one of the highest scoring tasks in PTE Speaking. Students should focus on understanding the sentence structure instead of memorizing every individual word. Listening carefully to stressed words and keywords improves memory retention. Even if the full sentence is not remembered, speaking partial correct content confidently can still earn marks. Daily listening and repetition exercises improve performance significantly.', 3);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('f4759ed7-ba20-4933-a5eb-5664bcb1195e', '0a85f43e-e16e-47dc-93fb-549f705878a3', 'Handle Describe Image and Re-tell Lecture', 'In Describe Image tasks, students should follow a simple structure including introduction, key details, trends, and conclusion. Avoid long silence while thinking. Fluency matters more than describing every small detail. For Re-tell Lecture, focus on capturing the main idea, examples, and conclusion from the lecture. Using templates during practice helps organize thoughts quickly during the exam.', 4);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('0f875f5e-4b50-4a5b-bb7c-4cb931b576b6', '0a85f43e-e16e-47dc-93fb-549f705878a3', 'Build Confidence Before the Real Exam', 'Many students lose marks because of nervousness rather than lack of English ability. Practicing under timed conditions improves confidence and reduces exam anxiety. Students should record themselves regularly to identify pronunciation and fluency mistakes. Maintaining a calm speaking pace, breathing properly, and focusing on clear delivery can improve overall speaking performance during the actual PTE test.', 5);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('d98716d0-ee68-4cca-8b97-90da24ef6a14', '30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'Understand the PTE Writing Format', 'The PTE Writing section mainly includes Summarize Written Text and Essay Writing tasks. Students should understand the scoring criteria including grammar, vocabulary, spelling, structure, and coherence. Many students focus only on ideas, but language accuracy is equally important. Practicing writing tasks regularly under time limits improves speed and confidence during the actual exam.', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('79fc39b1-4994-436b-891e-13a214110b66', '30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'Master Summarize Written Text', 'In Summarize Written Text tasks, students must write one complete sentence that captures the main idea of the passage. Long unnecessary explanations should be avoided. Use proper connectors such as although, however, because, and therefore to combine ideas smoothly. Grammar and punctuation mistakes can reduce marks even if the main idea is correct. Reading academic passages daily improves summarization skills.', 2);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('5b006b54-24db-45f4-b612-168836db52de', '30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'Build a Strong Essay Structure', 'A good PTE essay should contain a clear introduction, body paragraphs, and conclusion. Students should present ideas logically and support them with examples or explanations. Avoid memorizing complicated vocabulary that may be used incorrectly during the exam. Simple, accurate, and well-structured writing usually scores higher than overly complex sentences with grammar mistakes.', 3);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('ae8cf155-fb00-4721-9053-373780e133e4', '30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'Improve Grammar and Vocabulary', 'Grammar accuracy plays a major role in PTE Writing scores. Students should practice sentence structure, subject-verb agreement, articles, and punctuation regularly. Vocabulary should sound natural and academic rather than forced. Reading newspapers, journals, and English essays daily can improve writing quality and introduce useful expressions for academic writing tasks.', 4);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('bd26a90a-f333-4ccb-ae5e-a0ede1c96b0d', '30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'Manage Time Effectively During Writing', 'Time management is critical because students often spend too much time planning essays and not enough time proofreading. Leave at least two minutes at the end to check spelling and grammar mistakes. Typing speed also affects performance in computer-based exams, so regular keyboard practice is recommended. Calm and organized writing produces better results under exam pressure.', 5);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('6a50d726-dc30-4c01-ae2e-6cad6a834cc9', 'c5531fba-586a-44dc-ae11-ea966b1ef5b0', 'Speaking Fundamentals', '📚 Test Structure
Part 1 (4-5 min): Personal questions about everyday topics. Part 2 (3-4 min): 1-minute prep + 2-min long turn on a cue card. Part 3 (4-5 min): Abstract discussion.
💡 Fluency & Coherence
Speak continuously without long pauses. Use filler phrases naturally: "That''s an interesting question...", "Let me think about that for a moment..." Don''t just say "um" repeatedly.
📚 Pronunciation Tips
Clarity matters more than accent. Stress the right syllables: photo-GRAPH-er not PHO-to-graph-er. Practice tongue twisters for muscle memory.
💡 Part 2 Strategy
Use 1 minute wisely! Make bullet notes: WHO, WHAT, WHERE, WHEN, WHY. This structure ensures you speak for the full 2 minutes confidently.
🎯 Self-Assessment Quiz
Record yourself speaking for 2 minutes on: "Describe a book you recently read." Check: Did you speak for the full time? Did you use varied vocabulary? Were you fluent?', 1);
INSERT INTO public.prep_parts (id, prep_id, part_title, part_content, order_index) VALUES ('7f41ed14-e9a7-4934-a35f-04dd12996a7d', 'c5531fba-586a-44dc-ae11-ea966b1ef5b0', 'Advanced Speaking', '📚 Lexical Resource Boost
Use collocations: make a decision, take an opportunity, have an argument. Avoid overusing "good/bad/nice". Use: remarkable, challenging, worthwhile instead.
💡 Handling Unknown Topics
Never say "I don''t know." Say: "This is not something I''ve thought about before, but I suppose..." Then give a general opinion. Examiners want to hear you speak.
🎯 Part 3 Discussion Practice
Sample question: "How has technology changed communication in your country?" Approach: General statement → Example → Contrast old vs new → Future speculation', 2);


--
-- TOC entry 5371 (class 0 OID 41566)
-- Dependencies: 237
-- Data for Name: preparations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('0743bc02-cbee-4ed7-9b77-59951d3d83e8', 'IELTS Writing', 'IELTS', 'Writing', 'A comprehensive guide to structuring IELTS Writing Tasks', 'published', '2026-05-13 10:39:01.829403', '2026-05-13 10:40:33.119716');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('a01ad9f9-11af-4d58-8679-6bab26d6e75c', 'IELTS Reading', 'IELTS', 'Reading', 'Learn techniques for skimming and scanning to identify key info quickly', 'published', '2026-05-14 14:24:51.254361', '2026-05-14 14:24:51.254361');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('98cc1119-6a29-47dc-9435-412e6f097647', 'IELTS Listening', 'IELTS', 'Listening', 'Effective note-taking methods for IELTS Listening section', 'published', '2026-05-14 14:28:32.838539', '2026-05-14 14:28:32.838539');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('3e11922a-537c-4a1e-a936-c79af934ce15', 'PTE Reading Master Strategy Guide', 'PTE', 'Reading', 'Essential PTE Reading techniques including time management, skimming, scanning, reorder paragraph strategies, and smart answer selection methods to improve overall reading score.', 'published', '2026-05-14 14:39:59.034901', '2026-05-14 14:39:59.034901');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('0e6a6611-80a1-455e-805f-abd2265d65b4', 'PTE Listening High Score Preparation Guide', 'PTE', 'Listening', 'Complete PTE Listening preparation strategies including note-taking techniques, prediction methods, concentration improvement, highlight keyword strategies, and smart answering techniques for all listening tasks.', 'published', '2026-05-14 14:45:13.788473', '2026-05-14 14:45:13.788473');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('0a85f43e-e16e-47dc-93fb-549f705878a3', 'PTE Speaking Complete Preparation Guide', 'PTE', 'Speaking', 'Comprehensive PTE Speaking strategies including pronunciation improvement, fluency development, confidence building, repeat sentence techniques, and speaking template practice for higher scores.', 'published', '2026-05-14 14:46:56.777784', '2026-05-14 14:46:56.777784');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('30162207-e4e4-4b67-ad0d-3f0f7a77249a', 'PTE Writing High Score Strategy Guide', 'PTE', 'Writing', 'Advanced PTE Writing preparation including essay structure, summarize written text techniques, grammar improvement, vocabulary enhancement, and time management strategies for better writing scores.', 'published', '2026-05-14 14:47:33.536223', '2026-05-14 14:47:33.536223');
INSERT INTO public.preparations (id, title, test_type, section, summary, status, created_at, updated_at) VALUES ('c5531fba-586a-44dc-ae11-ea966b1ef5b0', 'IELTS Speaking', 'IELTS', 'Speaking', 'How to organize your thoughts and speak fluently in 40 seconds', 'published', '2026-05-14 14:51:42.761617', '2026-05-14 14:51:42.761617');


--
-- TOC entry 5358 (class 0 OID 24854)
-- Dependencies: 224
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5364 (class 0 OID 25110)
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
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (32, '660c49f1-a752-420e-a27c-fe53a73d71db', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2NjBjNDlmMS1hNzUyLTQyMGUtYTI3Yy1mZTUzYTczZDcxZGIiLCJ0b2tlbklkIjoiZDdmMGQ4NjItNTIyNy00ZWRiLWFjZDAtY2RmNGU3ZWE5NDZjIiwiaWF0IjoxNzc4MzEzNjU3LCJleHAiOjE3Nzg5MTg0NTd9.ns9mFseDYdvHR0SjPjDWLw8Yw_oUk2q7MsKOl2rbbl0', '2026-05-16 13:00:57.039', '2026-05-09 13:00:57.041721');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (33, '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3YzdlNWM5ZS1lYWQ3LTRhOWEtYTc2MS0zNzNiNjEyMWMxOGUiLCJ0b2tlbklkIjoiOTgyYTYxYjgtYzRkZi00ZjgwLTkzMDEtMGM3YWY4YjE5MzEwIiwiaWF0IjoxNzc4MzE1NDk4LCJleHAiOjE3Nzg5MjAyOTh9.5l_cjoNU6CIT3suWyS_JY6TDrn_3qvZhm4SuvGJMQqg', '2026-05-16 13:31:38.488', '2026-05-09 13:31:38.48943');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (35, 'f81c2b76-cf4c-4718-8872-ba3afc90af2a', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJmODFjMmI3Ni1jZjRjLTQ3MTgtODg3Mi1iYTNhZmM5MGFmMmEiLCJ0b2tlbklkIjoiM2ZhYmQ5OWQtOGIzNi00MjkzLTlhOWItMjFiOGE3YzdhMGU4IiwiaWF0IjoxNzc4MzE2NzkzLCJleHAiOjE3Nzg5MjE1OTN9.EvoWGewrIh0xZi4zNwtmh0qSTocw23ivyAaI8BneJMo', '2026-05-16 13:53:13.794', '2026-05-09 13:53:13.795378');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (48, '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3YzdlNWM5ZS1lYWQ3LTRhOWEtYTc2MS0zNzNiNjEyMWMxOGUiLCJ0b2tlbklkIjoiOTkwYjZjNjItNDU3YS00MWMzLWJmYTAtZjVhZjRkOGIzNWJlIiwiaWF0IjoxNzc4NzUxMzYzLCJleHAiOjE3NzkzNTYxNjN9.u3LBNXllYVPSGZaevXPFPbhCrzoy5b_tBrTUYrHt5XE', '2026-05-21 14:36:03.958', '2026-05-14 14:36:03.958401');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (51, '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3YzdlNWM5ZS1lYWQ3LTRhOWEtYTc2MS0zNzNiNjEyMWMxOGUiLCJ0b2tlbklkIjoiNWVjNjJmZjktNTkxYS00NWExLWEzYWQtYjExN2ZiYjNmZGY0IiwiaWF0IjoxNzc4ODczNjQxLCJleHAiOjE3Nzk0Nzg0NDF9.8LyhXtwhzrgQ0AO-dCe2XSBX_jJU7ujBydD2GrPHYCM', '2026-05-23 00:34:01.626', '2026-05-16 00:34:01.627981');
INSERT INTO public.refresh_tokens (id, user_id, token, expires_at, created_at) VALUES (52, '7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI3YzdlNWM5ZS1lYWQ3LTRhOWEtYTc2MS0zNzNiNjEyMWMxOGUiLCJ0b2tlbklkIjoiODYzNmFlZDctZWVlNS00ZjY2LWFiZWItMTRmYzM2YzRhNDU0IiwiaWF0IjoxNzc4OTA4NjM3LCJleHAiOjE3Nzk1MTM0Mzd9.a62BlLcyfOB67Z2L30brzZYloM4Qw6LM2xvep9_ob60', '2026-05-23 10:17:17.681', '2026-05-16 10:17:17.682115');


--
-- TOC entry 5369 (class 0 OID 25279)
-- Dependencies: 235
-- Data for Name: study_plan_items; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5368 (class 0 OID 25258)
-- Dependencies: 234
-- Data for Name: study_plans; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5362 (class 0 OID 25059)
-- Dependencies: 228
-- Data for Name: temp_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.temp_users (id, email, full_name, password_hash, otp_code, expires_at, created_at, type, is_verified, attempts) VALUES ('ac6283fb-b544-406f-8be5-ed08f20652af', 's23-0385@student.uoh.edu.pk', 'S23-0385', '$2b$10$5xiU8XjC0mvUs61baMzlw.zIIjbpVAJVBs8JzIYL6Bza4NJIt7whS', '$2b$10$N38JiSP1xPKYXAGExAyw5udbV5hbogaCdtFbPKsGhzK83MHZi027W', '2026-05-14 13:00:01.3', '2026-05-14 12:45:01.301943', 'register', false, 0);


--
-- TOC entry 5359 (class 0 OID 24905)
-- Dependencies: 225
-- Data for Name: test_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5357 (class 0 OID 24833)
-- Dependencies: 223
-- Data for Name: test_sections; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5356 (class 0 OID 24776)
-- Dependencies: 222
-- Data for Name: tests; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5361 (class 0 OID 24958)
-- Dependencies: 227
-- Data for Name: user_progress_stats; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5360 (class 0 OID 24936)
-- Dependencies: 226
-- Data for Name: user_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5355 (class 0 OID 24603)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio, preference, fcm_token) VALUES ('660c49f1-a752-420e-a27c-fe53a73d71db', 'nasad8569@gmail.com', '$2b$10$tF7HIGDtS.Fh1RL55vo0nuttSq3MWs1Up6KyIjgaj6BRdAk4Req6W', 'Admin Asad', NULL, 'email', 'user', true, '2026-05-09 13:00:57.091733', '2026-04-30 23:18:29.343738', '2026-05-13 22:15:36.866147', 'premium', 1, 'No bio provided', 'IELTS', NULL);
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio, preference, fcm_token) VALUES ('7c7e5c9e-ead7-4a9a-a761-373b6121c18e', 'ragesr56@gmail.com', '$2b$10$nHu4qCDEUz4Dm6jmoaVIke7QdKDvlG8VeFZ464xGw5OnbqPpYZkii', 'Asad Abbas', NULL, 'email', 'admin', true, '2026-05-16 10:17:17.720645', '2026-05-09 13:29:44.911295', '2026-05-14 12:10:45.552511', 'free', 0, 'This is my bio', 'PTE', NULL);
INSERT INTO public.users (id, email, password_hash, full_name, avatar_url, auth_provider, role, is_email_verified, last_login_at, created_at, updated_at, subscription, token_version, bio, preference, fcm_token) VALUES ('f81c2b76-cf4c-4718-8872-ba3afc90af2a', 'azadari87@gmail.com', '$2b$10$NPAPGjSARlJQjF1INwK.Oexf5jMOwGA2iEUBFHSmDRtzZQ9.GaxAG', 'TestFlow IELTS 2', NULL, 'email', 'user', true, '2026-05-09 13:53:13.798891', '2026-05-09 13:52:27.379741', '2026-05-13 20:09:59.576838', 'free', 0, 'No bio provided', 'IELTS', NULL);


--
-- TOC entry 5390 (class 0 OID 0)
-- Dependencies: 229
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 52, true);


--
-- TOC entry 5115 (class 2606 OID 25144)
-- Name: admin_logs admin_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 5136 (class 2606 OID 25344)
-- Name: ai_feedback ai_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_feedback
    ADD CONSTRAINT ai_feedback_pkey PRIMARY KEY (id);


--
-- TOC entry 5162 (class 2606 OID 42058)
-- Name: comment_likes comment_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_likes
    ADD CONSTRAINT comment_likes_pkey PRIMARY KEY (comment_id, user_id);


--
-- TOC entry 5153 (class 2606 OID 42010)
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 5168 (class 2606 OID 42140)
-- Name: moderation_log moderation_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_pkey PRIMARY KEY (id);


--
-- TOC entry 5170 (class 2606 OID 42181)
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 42038)
-- Name: post_likes post_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 5166 (class 2606 OID 42081)
-- Name: post_shares post_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_shares
    ADD CONSTRAINT post_shares_pkey PRIMARY KEY (id);


--
-- TOC entry 5151 (class 2606 OID 41982)
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 5124 (class 2606 OID 25240)
-- Name: practice_responses practice_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 5126 (class 2606 OID 25242)
-- Name: practice_responses practice_responses_session_id_question_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_session_id_question_id_key UNIQUE (session_id, question_id);


--
-- TOC entry 5120 (class 2606 OID 25222)
-- Name: practice_sessions practice_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_sessions
    ADD CONSTRAINT practice_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5144 (class 2606 OID 41605)
-- Name: prep_media prep_media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_media
    ADD CONSTRAINT prep_media_pkey PRIMARY KEY (id);


--
-- TOC entry 5142 (class 2606 OID 41590)
-- Name: prep_parts prep_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_parts
    ADD CONSTRAINT prep_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 5140 (class 2606 OID 41578)
-- Name: preparations preparations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preparations
    ADD CONSTRAINT preparations_pkey PRIMARY KEY (id);


--
-- TOC entry 5092 (class 2606 OID 24867)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 5111 (class 2606 OID 25122)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5113 (class 2606 OID 25124)
-- Name: refresh_tokens refresh_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_key UNIQUE (token);


--
-- TOC entry 5134 (class 2606 OID 25294)
-- Name: study_plan_items study_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plan_items
    ADD CONSTRAINT study_plan_items_pkey PRIMARY KEY (id);


--
-- TOC entry 5130 (class 2606 OID 25273)
-- Name: study_plans study_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plans
    ADD CONSTRAINT study_plans_pkey PRIMARY KEY (id);


--
-- TOC entry 5102 (class 2606 OID 25071)
-- Name: temp_users temp_users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_key UNIQUE (email);


--
-- TOC entry 5104 (class 2606 OID 25094)
-- Name: temp_users temp_users_email_type_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_type_unique UNIQUE (email, type);


--
-- TOC entry 5106 (class 2606 OID 25082)
-- Name: temp_users temp_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_email_unique UNIQUE (email);


--
-- TOC entry 5108 (class 2606 OID 25069)
-- Name: temp_users temp_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.temp_users
    ADD CONSTRAINT temp_users_pkey PRIMARY KEY (id);


--
-- TOC entry 5095 (class 2606 OID 24924)
-- Name: test_attempts test_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_pkey PRIMARY KEY (id);


--
-- TOC entry 5086 (class 2606 OID 24845)
-- Name: test_sections test_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT test_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 5082 (class 2606 OID 24788)
-- Name: tests tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_pkey PRIMARY KEY (id);


--
-- TOC entry 5088 (class 2606 OID 24847)
-- Name: test_sections unique_test_section_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT unique_test_section_order UNIQUE (test_id, order_number);


--
-- TOC entry 5100 (class 2606 OID 24967)
-- Name: user_progress_stats user_progress_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5098 (class 2606 OID 24946)
-- Name: user_responses user_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 5076 (class 2606 OID 24623)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 5078 (class 2606 OID 24621)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5093 (class 1259 OID 24935)
-- Name: idx_attempts_user_test; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_user_test ON public.test_attempts USING btree (user_id, test_id);


--
-- TOC entry 5163 (class 1259 OID 42069)
-- Name: idx_comment_likes_comment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comment_likes_comment_id ON public.comment_likes USING btree (comment_id);


--
-- TOC entry 5154 (class 1259 OID 42029)
-- Name: idx_comments_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_created_at ON public.comments USING btree (created_at DESC);


--
-- TOC entry 5155 (class 1259 OID 42027)
-- Name: idx_comments_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_parent_id ON public.comments USING btree (parent_id);


--
-- TOC entry 5156 (class 1259 OID 42026)
-- Name: idx_comments_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_post_id ON public.comments USING btree (post_id);


--
-- TOC entry 5157 (class 1259 OID 42028)
-- Name: idx_comments_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comments_user_id ON public.comments USING btree (user_id);


--
-- TOC entry 5137 (class 1259 OID 25356)
-- Name: idx_feedback_attempt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_attempt ON public.ai_feedback USING btree (attempt_id);


--
-- TOC entry 5138 (class 1259 OID 25355)
-- Name: idx_feedback_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_feedback_user ON public.ai_feedback USING btree (user_id);


--
-- TOC entry 5158 (class 1259 OID 42049)
-- Name: idx_post_likes_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_likes_post_id ON public.post_likes USING btree (post_id);


--
-- TOC entry 5164 (class 1259 OID 42092)
-- Name: idx_post_shares_post_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_post_shares_post_id ON public.post_shares USING btree (post_id);


--
-- TOC entry 5145 (class 1259 OID 41991)
-- Name: idx_posts_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_created_at ON public.posts USING btree (created_at DESC);


--
-- TOC entry 5146 (class 1259 OID 41992)
-- Name: idx_posts_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_deleted_at ON public.posts USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- TOC entry 5147 (class 1259 OID 41990)
-- Name: idx_posts_is_flagged; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_is_flagged ON public.posts USING btree (is_flagged);


--
-- TOC entry 5148 (class 1259 OID 41989)
-- Name: idx_posts_topic_tag; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_topic_tag ON public.posts USING btree (topic_tag);


--
-- TOC entry 5149 (class 1259 OID 41988)
-- Name: idx_posts_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_posts_user_id ON public.posts USING btree (user_id);


--
-- TOC entry 5121 (class 1259 OID 25257)
-- Name: idx_practice_responses_question; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_responses_question ON public.practice_responses USING btree (question_id);


--
-- TOC entry 5122 (class 1259 OID 25256)
-- Name: idx_practice_responses_session; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_responses_session ON public.practice_responses USING btree (session_id);


--
-- TOC entry 5116 (class 1259 OID 25254)
-- Name: idx_practice_sessions_section; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_sessions_section ON public.practice_sessions USING btree (section_name);


--
-- TOC entry 5117 (class 1259 OID 25255)
-- Name: idx_practice_sessions_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_sessions_status ON public.practice_sessions USING btree (status);


--
-- TOC entry 5118 (class 1259 OID 25253)
-- Name: idx_practice_sessions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_practice_sessions_user ON public.practice_sessions USING btree (user_id);


--
-- TOC entry 5089 (class 1259 OID 42347)
-- Name: idx_questions_difficulty; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_difficulty ON public.questions USING btree (difficulty);


--
-- TOC entry 5090 (class 1259 OID 24873)
-- Name: idx_questions_section_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_section_id ON public.questions USING btree (section_id);


--
-- TOC entry 5109 (class 1259 OID 25131)
-- Name: idx_refresh_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_user ON public.refresh_tokens USING btree (user_id);


--
-- TOC entry 5096 (class 1259 OID 24957)
-- Name: idx_responses_attempt; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_responses_attempt ON public.user_responses USING btree (attempt_id);


--
-- TOC entry 5083 (class 1259 OID 33376)
-- Name: idx_sections_question_types; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_question_types ON public.test_sections USING gin (question_types_allowed);


--
-- TOC entry 5084 (class 1259 OID 24853)
-- Name: idx_sections_test_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sections_test_id ON public.test_sections USING btree (test_id);


--
-- TOC entry 5131 (class 1259 OID 25303)
-- Name: idx_study_plan_items_day; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plan_items_day ON public.study_plan_items USING btree (day_number);


--
-- TOC entry 5132 (class 1259 OID 25302)
-- Name: idx_study_plan_items_plan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plan_items_plan ON public.study_plan_items USING btree (plan_id);


--
-- TOC entry 5127 (class 1259 OID 25301)
-- Name: idx_study_plans_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plans_status ON public.study_plans USING btree (status);


--
-- TOC entry 5128 (class 1259 OID 25300)
-- Name: idx_study_plans_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_study_plans_user ON public.study_plans USING btree (user_id);


--
-- TOC entry 5079 (class 1259 OID 33374)
-- Name: idx_tests_exam_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tests_exam_type ON public.tests USING btree (exam_type);


--
-- TOC entry 5080 (class 1259 OID 33375)
-- Name: idx_tests_published; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tests_published ON public.tests USING btree (is_published);


--
-- TOC entry 5073 (class 1259 OID 24624)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 5074 (class 1259 OID 24625)
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- TOC entry 5207 (class 2620 OID 42216)
-- Name: users user_subscription_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER user_subscription_trigger AFTER UPDATE OF subscription ON public.users FOR EACH ROW EXECUTE FUNCTION public.notify_subscription_change();


--
-- TOC entry 5180 (class 2606 OID 25145)
-- Name: admin_logs admin_logs_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5181 (class 2606 OID 25150)
-- Name: admin_logs admin_logs_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_logs
    ADD CONSTRAINT admin_logs_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5187 (class 2606 OID 25345)
-- Name: ai_feedback ai_feedback_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_feedback
    ADD CONSTRAINT ai_feedback_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE;


--
-- TOC entry 5188 (class 2606 OID 25350)
-- Name: ai_feedback ai_feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ai_feedback
    ADD CONSTRAINT ai_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 5197 (class 2606 OID 42059)
-- Name: comment_likes comment_likes_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_likes
    ADD CONSTRAINT comment_likes_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5198 (class 2606 OID 42064)
-- Name: comment_likes comment_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment_likes
    ADD CONSTRAINT comment_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5192 (class 2606 OID 42021)
-- Name: comments comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5193 (class 2606 OID 42011)
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5194 (class 2606 OID 42016)
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5201 (class 2606 OID 42141)
-- Name: moderation_log moderation_log_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5202 (class 2606 OID 42146)
-- Name: moderation_log moderation_log_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moderation_log
    ADD CONSTRAINT moderation_log_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5203 (class 2606 OID 42187)
-- Name: notifications notifications_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5204 (class 2606 OID 42197)
-- Name: notifications notifications_comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_comment_id_fkey FOREIGN KEY (comment_id) REFERENCES public.comments(id) ON DELETE CASCADE;


--
-- TOC entry 5205 (class 2606 OID 42192)
-- Name: notifications notifications_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5206 (class 2606 OID 42182)
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5195 (class 2606 OID 42039)
-- Name: post_likes post_likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5196 (class 2606 OID 42044)
-- Name: post_likes post_likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_likes
    ADD CONSTRAINT post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5199 (class 2606 OID 42082)
-- Name: post_shares post_shares_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_shares
    ADD CONSTRAINT post_shares_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id) ON DELETE CASCADE;


--
-- TOC entry 5200 (class 2606 OID 42087)
-- Name: post_shares post_shares_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.post_shares
    ADD CONSTRAINT post_shares_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5191 (class 2606 OID 41983)
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5183 (class 2606 OID 25248)
-- Name: practice_responses practice_responses_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


--
-- TOC entry 5184 (class 2606 OID 25243)
-- Name: practice_responses practice_responses_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_responses
    ADD CONSTRAINT practice_responses_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.practice_sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5182 (class 2606 OID 25223)
-- Name: practice_sessions practice_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.practice_sessions
    ADD CONSTRAINT practice_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5190 (class 2606 OID 41606)
-- Name: prep_media prep_media_prep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_media
    ADD CONSTRAINT prep_media_prep_id_fkey FOREIGN KEY (prep_id) REFERENCES public.preparations(id) ON DELETE CASCADE;


--
-- TOC entry 5189 (class 2606 OID 41591)
-- Name: prep_parts prep_parts_prep_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prep_parts
    ADD CONSTRAINT prep_parts_prep_id_fkey FOREIGN KEY (prep_id) REFERENCES public.preparations(id) ON DELETE CASCADE;


--
-- TOC entry 5173 (class 2606 OID 24868)
-- Name: questions questions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.test_sections(id) ON DELETE CASCADE;


--
-- TOC entry 5179 (class 2606 OID 25125)
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5186 (class 2606 OID 25295)
-- Name: study_plan_items study_plan_items_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plan_items
    ADD CONSTRAINT study_plan_items_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.study_plans(id) ON DELETE CASCADE;


--
-- TOC entry 5185 (class 2606 OID 25274)
-- Name: study_plans study_plans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.study_plans
    ADD CONSTRAINT study_plans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5174 (class 2606 OID 24930)
-- Name: test_attempts test_attempts_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 5175 (class 2606 OID 24925)
-- Name: test_attempts test_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5172 (class 2606 OID 24848)
-- Name: test_sections test_sections_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_sections
    ADD CONSTRAINT test_sections_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 5171 (class 2606 OID 24789)
-- Name: tests tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tests
    ADD CONSTRAINT tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 5178 (class 2606 OID 24968)
-- Name: user_progress_stats user_progress_stats_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_progress_stats
    ADD CONSTRAINT user_progress_stats_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 5176 (class 2606 OID 24947)
-- Name: user_responses user_responses_attempt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_attempt_id_fkey FOREIGN KEY (attempt_id) REFERENCES public.test_attempts(id) ON DELETE CASCADE;


--
-- TOC entry 5177 (class 2606 OID 24952)
-- Name: user_responses user_responses_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_responses
    ADD CONSTRAINT user_responses_question_id_fkey FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE;


-- Completed on 2026-05-16 11:55:44

--
-- PostgreSQL database dump complete
--

\unrestrict x32DtVlKzAPksLoRDI9OPpmpCYBxd0t4hXGDdVPGKuFVEySzU4V0rVFMuBf3a4U

