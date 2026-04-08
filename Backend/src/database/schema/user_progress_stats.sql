CREATE TABLE user_progress_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_tests_taken INTEGER DEFAULT 0,
    average_band_score DECIMAL(3, 1) DEFAULT 0.0,
    last_test_date TIMESTAMP,
    highest_score DECIMAL(3, 1) DEFAULT 0.0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);