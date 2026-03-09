CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_role_enum AS ENUM (
    'user',
    'admin'
);

CREATE TYPE subscription_status_enum AS ENUM (
    'free',
    'premium'
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    email VARCHAR(255) UNIQUE NOT NULL,

    password_hash TEXT,

    full_name VARCHAR(150),

    avatar_url TEXT,

    country VARCHAR(100),

    auth_provider VARCHAR(50) DEFAULT 'email',

    role user_role_enum NOT NULL DEFAULT 'user',

    subscription subscription_status_enum NOT NULL DEFAULT 'free',

    is_email_verified BOOLEAN DEFAULT FALSE,

    last_login_at TIMESTAMP,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email
ON users(email);

CREATE INDEX idx_users_role
ON users(role);

CREATE INDEX idx_users_subscription
ON users(subscription);