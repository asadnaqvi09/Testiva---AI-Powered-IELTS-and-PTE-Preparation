CREATE TABLE test_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    -- Scoring (AI generate karega ya rule-based calculation)
    overall_band_score DECIMAL(3, 1) DEFAULT 0.0,
    writing_score DECIMAL(3, 1) DEFAULT 0.0,
    reading_score DECIMAL(3, 1) DEFAULT 0.0,
    listening_score DECIMAL(3, 1) DEFAULT 0.0,
    speaking_score DECIMAL(3, 1) DEFAULT 0.0,
    feedback TEXT, -- AI feedback summarized
    status attempt_status_enum DEFAULT 'in-progress',
    -- Offline/Sync Support
    is_offline BOOLEAN DEFAULT FALSE,
    client_started_at TIMESTAMP NOT NULL, -- Mobile ka time
    client_completed_at TIMESTAMP,        -- Mobile ka completion time
    server_synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Server ka time
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attempts_user_test ON test_attempts(user_id, test_id);