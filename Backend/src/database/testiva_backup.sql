
-- ENUMS 
CREATE TYPE public.admin_status AS ENUM (
    'none',
    'flagged',
    'removed'
);

CREATE TYPE public.attempt_status_enum AS ENUM (
    'in_progress',
    'completed',
    'synced'
);
CREATE TYPE public.difficulty_enum AS ENUM (
    'easy',
    'medium',
    'hard'
);
CREATE TYPE public.flag_source AS ENUM (
    'ai',
    'admin'
);
CREATE TYPE public.lesson_section_enum AS ENUM (
    'Reading',
    'Listening',
    'Writing',
    'Speaking'
);
CREATE TYPE public.lesson_status_enum AS ENUM (
    'draft',
    'published'
);
CREATE TYPE public.moderation_action AS ENUM (
    'flag',
    'unflag',
    'delete'
);
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
CREATE TYPE public.otp_type AS ENUM (
    'register',
    'reset'
);
CREATE TYPE public.section_type_enum AS ENUM (
    'reading',
    'listening',
    'writing',
    'speaking'
);
CREATE TYPE public.share_platform AS ENUM (
    'twitter',
    'instagram',
    'whatsapp',
    'facebook',
    'copy_link'
);
CREATE TYPE public.subscription_status_enum AS ENUM (
    'free',
    'basic',
    'premium'
);
CREATE TYPE public.test_category_enum AS ENUM (
    'full_mock',
    'reading',
    'writing',
    'listening',
    'speaking'
);
CREATE TYPE public.test_type_enum AS ENUM (
    'IELTS',
    'PTE'
);
CREATE TYPE public.topic_tag AS ENUM (
    'IELTS',
    'PTE',
    'General'
);
CREATE TYPE public.user_preference AS ENUM (
    'IELTS',
    'PTE',
    'NULL'
);
CREATE TYPE public.user_role_enum AS ENUM (
    'user',
    'admin'
);
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
CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;
--Tables
CREATE TABLE public.admin_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    action character varying(50) NOT NULL,
    target_user_id uuid,
    details jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
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
CREATE TABLE public.comment_likes (
    comment_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
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
CREATE TABLE public.moderation_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    admin_id uuid NOT NULL,
    post_id uuid NOT NULL,
    action public.moderation_action NOT NULL,
    admin_feedback text,
    email_sent boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
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
CREATE TABLE public.post_likes (
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE TABLE public.post_shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    post_id uuid NOT NULL,
    user_id uuid NOT NULL,
    platform public.share_platform NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
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
CREATE TABLE public.prep_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prep_id uuid,
    file_url character varying(255),
    file_name character varying(255),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    file_size integer,
    file_type character varying(50)
);
CREATE TABLE public.prep_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    prep_id uuid,
    part_title character varying(255),
    part_content text,
    order_index integer DEFAULT 0
);
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
CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);
CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

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
CREATE TABLE public.user_progress_stats (
    user_id uuid NOT NULL,
    total_tests_taken integer DEFAULT 0,
    average_band_score numeric(3,1) DEFAULT 0.0,
    last_test_date timestamp without time zone,
    highest_score numeric(3,1) DEFAULT 0.0,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
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