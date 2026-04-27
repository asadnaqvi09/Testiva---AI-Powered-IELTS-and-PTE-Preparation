CREATE TABLE study_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL, -- "30-Day IELTS Band 7 Plan"
    target_band DECIMAL(3,1) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'completed', 'paused'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE study_plan_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID REFERENCES study_plans(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    item_type VARCHAR(20) NOT NULL, -- 'lesson', 'practice', 'mock_test'
    item_id UUID NOT NULL, -- references lessons.id / questions.id / tests.id
    estimated_minutes INTEGER DEFAULT 30,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP
);