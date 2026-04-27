--
-- PostgreSQL database dump
--

\restrict 3MGbsbz5BgCKuDbPWyq1fvXnGpOYaOW5o0fPC3THRjygHccCkInu4XS8qfoCk3M

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-25 23:13:33

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

SET default_tablespace = '';

SET default_table_access_method = heap;

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
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.test_attempts OWNER TO postgres;

--
-- TOC entry 5013 (class 0 OID 24905)
-- Dependencies: 225
-- Data for Name: test_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.test_attempts (id, user_id, test_id, overall_band_score, writing_score, reading_score, listening_score, speaking_score, feedback, status, is_offline, client_started_at, client_completed_at, server_synced_at, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4863 (class 2606 OID 24924)
-- Name: test_attempts test_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_pkey PRIMARY KEY (id);


--
-- TOC entry 4861 (class 1259 OID 24935)
-- Name: idx_attempts_user_test; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_attempts_user_test ON public.test_attempts USING btree (user_id, test_id);


--
-- TOC entry 4864 (class 2606 OID 24930)
-- Name: test_attempts test_attempts_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.tests(id) ON DELETE CASCADE;


--
-- TOC entry 4865 (class 2606 OID 24925)
-- Name: test_attempts test_attempts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2026-04-25 23:13:33

--
-- PostgreSQL database dump complete
--

\unrestrict 3MGbsbz5BgCKuDbPWyq1fvXnGpOYaOW5o0fPC3THRjygHccCkInu4XS8qfoCk3M

