CREATE TABLE test_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id UUID REFERENCES tests(id) ON DELETE CASCADE,
    section_name lesson_section_enum NOT NULL, -- 'Reading', 'Listening', etc.
    time_limit_minutes INTEGER NOT NULL, -- Admin yahan timer set karega
    order_number INTEGER NOT NULL, -- Sequence: 1, 2, 3...
    instructions TEXT, -- Specific instructions for this section
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- Aik test mein aik hi section double nahi hona chahiye (Except PTE special cases)
    CONSTRAINT unique_section_order UNIQUE (test_id, order_number)
);

CREATE INDEX idx_sections_test_id ON test_sections(test_id);