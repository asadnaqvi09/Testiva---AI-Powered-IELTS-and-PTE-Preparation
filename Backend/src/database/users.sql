--
-- PostgreSQL database dump
--

\restrict YkcyqpcTa7ckHjg9gb5cuQg3sKLiXmSeSigp2zxDVRY35y3t4Po2fFr1fOiwWGJ

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-22 12:30:25

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
-- TOC entry 5014 (class 1262 OID 16388)
-- Name: Testiva_FYP; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "Testiva_FYP" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';


ALTER DATABASE "Testiva_FYP" OWNER TO postgres;

\unrestrict YkcyqpcTa7ckHjg9gb5cuQg3sKLiXmSeSigp2zxDVRY35y3t4Po2fFr1fOiwWGJ
\connect "Testiva_FYP"
\restrict YkcyqpcTa7ckHjg9gb5cuQg3sKLiXmSeSigp2zxDVRY35y3t4Po2fFr1fOiwWGJ

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
-- TOC entry 221 (class 1259 OID 24603)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255),
    password_hash text,
    full_name character varying(150),
    avatar_url text,
    country character varying(100),
    auth_provider character varying(50) DEFAULT 'email'::character varying,
    role public.user_role_enum DEFAULT 'user'::public.user_role_enum NOT NULL,
    is_email_verified boolean DEFAULT false,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    subscription public.subscription_status_enum DEFAULT 'free'::public.subscription_status_enum NOT NULL,
    token_version integer DEFAULT 0
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 5008 (class 0 OID 24603)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES ('3fbc291a-297e-4371-b6de-00e92c845257', 'nasad8569@gmail.com', '$2b$10$BSywSGIy3SsmWNvHIgMfpuJIxQujOyNDQaTgViPT.VNTpUuOjoP1m', 'Asad Abbas', 'https://res.cloudinary.com/dbsfrh5fa/image/upload/v1775152613/testiva/avatars/v7yhxqh48lk977nebldf.jpg', NULL, 'email', 'admin', false, '2026-04-07 19:51:51.653661', '2026-04-02 21:57:02.327225', '2026-04-07 13:00:41.510649', 'free', 0);
INSERT INTO public.users VALUES ('46cb0317-1ce3-47f0-9c62-81eccc91fd0a', 'ragesr56@gmail.com', '$2b$10$rdz4kJR.gYkrOC5lBTs1A.sq8ClBqOOhwTdvZ/YUe1EmnsNOxwmfy', 'John Doe', NULL, NULL, 'email', 'user', true, '2026-04-21 14:46:29.961396', '2026-04-21 14:40:18.486318', '2026-04-21 14:40:18.486318', 'free', 0);
INSERT INTO public.users VALUES ('9cafbc0d-e63f-4d62-9349-93cafcc0d09b', 'azadari87@gmail.com', '$2b$10$A2tfZ4Wp9Ul5gmLFDTevB.RuCfWMT/.HszNgkQF9gK2HtsNSh.Qdy', 'Ali Khan', NULL, NULL, 'email', 'user', true, '2026-04-21 16:20:06.455709', '2026-04-21 16:02:45.337476', '2026-04-21 16:19:50.660404', 'free', 0);


--
-- TOC entry 4858 (class 2606 OID 24623)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4860 (class 2606 OID 24621)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4855 (class 1259 OID 24624)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 4856 (class 1259 OID 24625)
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


-- Completed on 2026-04-22 12:30:25

--
-- PostgreSQL database dump complete
--

\unrestrict YkcyqpcTa7ckHjg9gb5cuQg3sKLiXmSeSigp2zxDVRY35y3t4Po2fFr1fOiwWGJ

