CREATE TABLE user_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID REFERENCES test_attempts(id) ON DELETE CASCADE,
    question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
    
    -- Data
    user_answer TEXT, -- MCQ choice ya short answer text
    audio_response_url TEXT, -- Cloudinary link agar Speaking test hai
    
    -- Evaluation
    is_correct BOOLEAN,
    marks_obtained DECIMAL(3, 1) DEFAULT 0.0,
    ai_feedback_per_question TEXT,
    
    client_created_at TIMESTAMP, -- Offline sync ke liye time tracking
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_responses_attempt ON user_responses(attempt_id);