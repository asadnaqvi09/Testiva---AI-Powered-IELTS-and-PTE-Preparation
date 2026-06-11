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
CREATE INDEX idx_tests_exam_type ON public.tests USING btree (exam_type);
CREATE INDEX idx_tests_published ON public.tests USING btree (is_published);