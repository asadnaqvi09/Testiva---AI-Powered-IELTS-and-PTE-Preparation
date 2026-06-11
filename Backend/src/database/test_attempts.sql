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
CREATE INDEX idx_attempts_user_test ON public.test_attempts USING btree (user_id, test_id);