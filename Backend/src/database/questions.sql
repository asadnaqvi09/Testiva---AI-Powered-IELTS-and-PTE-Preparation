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
CREATE INDEX idx_questions_difficulty ON public.questions USING btree (difficulty);
CREATE INDEX idx_questions_section_id ON public.questions USING btree (section_id);