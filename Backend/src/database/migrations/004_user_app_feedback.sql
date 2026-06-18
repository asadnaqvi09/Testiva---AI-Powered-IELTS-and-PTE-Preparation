CREATE TABLE IF NOT EXISTS public.user_app_feedback (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    rating integer NOT NULL,
    category character varying(100) NOT NULL,
    comment text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_app_feedback_pkey PRIMARY KEY (id),
    CONSTRAINT user_app_feedback_rating_check CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT user_app_feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_app_feedback_user_id ON public.user_app_feedback USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_user_app_feedback_created_at ON public.user_app_feedback USING btree (created_at DESC);
