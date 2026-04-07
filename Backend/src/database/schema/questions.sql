CREATE TABLE questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID REFERENCES test_sections(id) ON DELETE CASCADE,
    -- Question Type: 'MCQ', 'short-answer', 'essay-prompt', 'audio-recording'
    question_type VARCHAR(50) NOT NULL, 
    -- Passage: Reading ke lambe paragraphs yahan ayenge
    passage_text TEXT, 
    -- Question: Asli sawal ya prompt
    question_text TEXT NOT NULL,
    -- Options: JSON format mein ["Option A", "Option B"]
    options JSONB, 
    -- Correct Answer: Validation ke liye
    correct_answer TEXT,
    -- Audio URL: Cloudinary ka link (Listening/Speaking ke liye)
    audio_url TEXT, 
    -- Sequence: Section ke andar sawal ka number
    order_number INTEGER NOT NULL, 
    marks INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_questions_section_id ON questions(section_id);