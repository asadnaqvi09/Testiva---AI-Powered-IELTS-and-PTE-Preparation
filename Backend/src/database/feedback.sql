CREATE TABLE IF NOT EXISTS ai_feedback (
    id SERIAL PRIMARY KEY,
    attempt_id INTEGER NOT NULL REFERENCES test_attempts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id),
    overall_band_score DECIMAL(3, 1) DEFAULT 0.0,
    task_response_score DECIMAL(3, 1),
    coherence_cohesion_score DECIMAL(3, 1),
    lexical_resource_score DECIMAL(3, 1),
    grammatical_range_score DECIMAL(3, 1),
    detailed_analysis JSONB,
    improvement_suggestions TEXT,
    model_used VARCHAR(50) DEFAULT 'gemini-1.5-flash',
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_feedback_user ON ai_feedback(user_id);
CREATE INDEX idx_feedback_attempt ON ai_feedback(attempt_id);