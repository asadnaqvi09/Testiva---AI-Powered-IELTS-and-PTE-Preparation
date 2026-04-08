CREATE TABLE mocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL, -- e.g., 'IELTS Academic Mock 01'
    exam_type test_type_enum NOT NULL, -- 'IELTS' or 'PTE'
    is_full_mock BOOLEAN DEFAULT FALSE,
    total_time_minutes INTEGER, -- Full test ka combined time (e.g., 160 mins)
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tests_exam_type ON mocks(exam_type);