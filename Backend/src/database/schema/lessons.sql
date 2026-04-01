CREATE TYPE test_type_enum AS ENUM (
    'IELTS',
    'PTE'
);
CREATE TYPE lesson_section_enum AS ENUM (
    'Reading',
    'Listening',
    'Writing',
    'Speaking'
);
CREATE TYPE lesson_status_enum AS ENUM (
    'draft',
    'published'
);

CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    test_type test_type_enum NOT NULL,
    section lesson_section_enum NOT NULL,
    summary TEXT,
    status lesson_status_enum NOT NULL DEFAULT 'draft',
    created_by UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lessons_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id)
        ON DELETE SET NULL
);

CREATE TABLE lesson_parts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL,
    part_title VARCHAR(255) NOT NULL,
    part_content TEXT NOT NULL,
    order_number INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_lesson_parts_lesson
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE,
    CONSTRAINT unique_part_order
        UNIQUE (lesson_id, order_number)
);

CREATE INDEX idx_lessons_test_type
ON lessons(test_type);
CREATE INDEX idx_lessons_section
ON lessons(section);
CREATE INDEX idx_lessons_status
ON lessons(status);
CREATE INDEX idx_lessons_created_at
ON lessons(created_at);
CREATE INDEX idx_lessons_created_by
ON lessons(created_by);
CREATE INDEX idx_lesson_parts_lesson_id
ON lesson_parts(lesson_id);
CREATE INDEX idx_lesson_parts_order
ON lesson_parts(order_number);