--
-- PostgreSQL database dump
--

\restrict 2b0mqRuadMY3Bjba1rNFJLdQbcOKHCsIII4pXhSjbVuwCiwssIWr6GMnsQfuRmZ

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-22 23:12:56

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
-- TOC entry 224 (class 1259 OID 24854)
-- Name: questions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.questions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    section_id uuid,
    question_type character varying(50) NOT NULL,
    passage_text text,
    question_text text NOT NULL,
    options jsonb,
    correct_answer text,
    audio_url text,
    order_number integer NOT NULL,
    marks integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.questions OWNER TO postgres;

--
-- TOC entry 5004 (class 0 OID 24854)
-- Dependencies: 224
-- Data for Name: questions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('bf3316e3-756e-49f2-8eac-1cc007f13fe8', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MCQ', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'What is the main idea of the first paragraph?', '["History", "Future", "Science", "Math"]', 'History', NULL, 1, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('12e2da75-d622-4fc3-8a4b-08e5bc1fddf8', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MCQ', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'When did AI research begin?', '["1940s", "1950s", "1960s", "1970s"]', '1950s', NULL, 2, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('8bc8cc89-fe73-43c0-8921-d04e6c2111dd', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'TRUE_FALSE_NOT_GIVEN', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'AI was first developed in the 1940s.', '["True", "False", "Not Given"]', 'False', NULL, 3, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('4f9e264e-5dd5-4910-b379-cdd43dd57e9c', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'FILL_IN_THE_BLANK', 'The history of AI dates back to the 1950s when early scientists began exploring machine intelligence.', 'AI research began in the ______.', NULL, '1950s', NULL, 4, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('636932dd-17af-4975-a5ef-7b22c3661ad7', 'e6a4000d-3539-4127-829a-ff244607bd7c', 'MATCH_HEADINGS', 'Paragraph A: AI development history. Paragraph B: Modern AI applications.', 'Match the heading to the paragraph.', '["i. AI Applications", "ii. AI History"]', 'ii. AI History', NULL, 5, 2, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('61dc82a9-161b-41fc-a972-cf021918ec0d', '6ca8272a-d1a1-4619-be4a-f91daeb19528', 'MCQ', NULL, 'What is the speaker mainly talking about?', '["Travel", "Education", "Technology", "Health"]', 'Technology', NULL, 1, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('f197dcd9-193a-48af-aeff-0de5e50baf38', '6ca8272a-d1a1-4619-be4a-f91daeb19528', 'FILL_IN_THE_BLANK', NULL, 'The lecture starts at ______.', NULL, '9 AM', NULL, 2, 1, '2026-04-07 16:44:26.705843');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('8692daf2-c94e-4853-9f07-0920587403ec', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'MCQ', 'Climate change is one of the most serious environmental issues facing the world today.', 'What is the main topic of the passage?', '["Pollution", "Climate Change", "Technology", "Education"]', 'Climate Change', NULL, 1, 1, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('c9f26fce-2d65-4770-b0e3-81315c6565de', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'TRUE_FALSE_NOT_GIVEN', 'Climate change impacts all regions of the world, though effects vary.', 'Climate change only affects developing countries.', '["True", "False", "Not Given"]', 'False', NULL, 2, 1, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('7a48eead-7a37-4d2f-b962-d5652f162fcb', '637a9af7-e6ae-47db-9d49-ec8b6e6c4720', 'FILL_IN_THE_BLANK', 'Climate change is one of the most serious environmental issues facing the world today.', 'Climate change is a global ______ issue.', NULL, 'environmental', NULL, 3, 1, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('fe1e5212-1f30-47c7-907b-ba1e9df9b07a', 'b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'ESSAY', NULL, 'Some people think technology has made our lives easier. To what extent do you agree or disagree?', NULL, NULL, NULL, 1, 10, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('7860ab1c-132d-4add-b3e8-0b837495f480', 'b3b1a52b-fb4a-47d4-bf67-767f3c48d6dc', 'REPORT', NULL, 'Summarize the information given in the chart.', NULL, NULL, NULL, 2, 10, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('0bf6053b-71ef-4260-9730-77c7e94c55c0', '8b76da74-cfc3-49c3-916c-cc4d4f520361', 'SHORT_ANSWER', NULL, 'Describe your favorite place.', NULL, NULL, NULL, 1, 5, '2026-04-07 19:52:30.267704');
INSERT INTO public.questions (id, section_id, question_type, passage_text, question_text, options, correct_answer, audio_url, order_number, marks, created_at) VALUES ('a000c4f0-b59e-447d-9b59-70239fc29c8b', '8b76da74-cfc3-49c3-916c-cc4d4f520361', 'DISCUSSION', NULL, 'Do you think technology improves communication?', NULL, NULL, NULL, 2, 5, '2026-04-07 19:52:30.267704');


--
-- TOC entry 4855 (class 2606 OID 24867)
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- TOC entry 4853 (class 1259 OID 24873)
-- Name: idx_questions_section_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_questions_section_id ON public.questions USING btree (section_id);


--
-- TOC entry 4856 (class 2606 OID 24868)
-- Name: questions questions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.questions
    ADD CONSTRAINT questions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.test_sections(id) ON DELETE CASCADE;


-- Completed on 2026-04-22 23:12:57

--
-- PostgreSQL database dump complete
--

\unrestrict 2b0mqRuadMY3Bjba1rNFJLdQbcOKHCsIII4pXhSjbVuwCiwssIWr6GMnsQfuRmZ

