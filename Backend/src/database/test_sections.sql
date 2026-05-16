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
CREATE INDEX idx_sections_question_types ON public.test_sections USING gin (question_types_allowed);
CREATE INDEX idx_sections_test_id ON public.test_sections USING btree (test_id);