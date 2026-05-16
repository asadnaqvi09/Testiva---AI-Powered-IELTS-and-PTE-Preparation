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
CREATE INDEX idx_responses_attempt ON public.user_responses USING btree (attempt_id);