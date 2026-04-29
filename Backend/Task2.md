# Task 2: User Roles & Access System

## 1. System Overview & Roles

For an AI-powered IELTS & PTE learning app, the system requires a hybrid access model: **Role-Based Access Control (RBAC)** to distinguish staff from customers, and **Subscription-Based Access Control** to govern customer feature tiers.

1. **Admin**: Has unrestricted system access. Can manage users, oversee platform analytics, create/edit study content (questions, mocks), and manage AI configurations.
2. **Free User**: An unpaying customer. Has access to a highly restricted set of features designed to act as a "hook." They can view limited sample questions, practice basic sets, but cannot take full mock tests or receive AI-powered evaluations.
3. **Basic User**: A lower-tier paying subscriber. Has access to the full practice library, a limited quota of mock tests (e.g., 2 per month), and basic AI scoring (overall band score) without deep, granular feedback.
4. **Premium User**: A top-tier subscriber. Unlocks the full potential of the platform: unlimited mock tests, detailed AI feedback (grammar analysis, speaking cadence, vocabulary suggestions), and priority support.

## 2. Permissions Matrix

| Feature | Free User | Basic User | Premium User | Admin |
| :--- | :---: | :---: | :---: | :---: |
| Access Dashboard | ✅ | ✅ | ✅ | ✅ |
| View Sample Practice | ✅ | ✅ | ✅ | ✅ |
| Full Practice Library | ❌ | ✅ | ✅ | ✅ |
| Mock Tests | ❌ | Limited Quota | ✅ (Unlimited) | ✅ |
| AI Feedback (Band Score)| ❌ | ✅ | ✅ | ✅ |
| AI Feedback (Detailed Analysis)| ❌ | ❌ | ✅ | ✅ |
| Access Admin Panel | ❌ | ❌ | ❌ | ✅ |
| Manage Content (Mocks/Tests)| ❌ | ❌ | ❌ | ✅ |
| View Global Analytics | ❌ | ❌ | ❌ | ✅ |

## 3. Backend Enforcement (Middleware & RBAC Design)

To enforce this at the backend level, access control should be split into distinct, reusable Express middlewares. 

### Middleware 1: Authentication (`requireAuth`)
Validates the JWT and attaches the `user` object to the request (`req.user`). It should decode `id`, `role`, and `subscription` directly from the token to avoid redundant database queries.

### Middleware 2: Role Enforcement (`requireRole`)
Ensures the user has the administrative privileges necessary for a route.
```javascript
export const requireRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ success: false, message: "Forbidden: Insufficient role permissions" });
    }
    next();
  };
};
// Usage: router.post('/test', requireAuth, requireRole('admin'), createTest);
```

### Middleware 3: Subscription Enforcement (`requireSubscription`)
Uses a hierarchical mapping to determine if a user meets the tier requirements.
```javascript
const tierHierarchy = { free: 0, basic: 1, premium: 2, admin: 99 };

export const requireSubscription = (minimumTier) => {
  return (req, res, next) => {
    // Admins bypass subscription checks
    if (req.user.role === 'admin') return next();

    const userTierVal = tierHierarchy[req.user.subscription] || 0;
    const requiredTierVal = tierHierarchy[minimumTier];

    if (userTierVal < requiredTierVal) {
      return res.status(402).json({ 
        success: false, 
        message: `Please upgrade to ${minimumTier} to access this feature.`,
        required_tier: minimumTier
      });
    }
    next();
  };
};
// Usage: router.post('/evaluate/detailed', requireAuth, requireSubscription('premium'), getDetailedFeedback);
```

### Middleware 4: Quota Enforcement (`checkQuota`)
For Basic Users who have limited mock tests, a quota middleware intercepts the request and validates remaining usages against Redis or PostgreSQL before proceeding.

## 4. Suggested Database Structure

A robust database design ensures data integrity for roles and billing states.

```sql
-- 1. Enums for Data Integrity
CREATE TYPE user_role AS ENUM ('user', 'admin');
CREATE TYPE subscription_tier AS ENUM ('free', 'basic', 'premium');

-- 2. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role DEFAULT 'user',
    subscription subscription_tier DEFAULT 'free',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Billing & Subscription Table (Decoupled from Users)
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    stripe_customer_id VARCHAR(255) UNIQUE,
    stripe_subscription_id VARCHAR(255) UNIQUE,
    tier subscription_tier NOT NULL,
    status VARCHAR(50) NOT NULL, -- e.g., 'active', 'past_due', 'canceled'
    current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. User Quotas Table (For Tracking Limited Features)
CREATE TABLE user_quotas (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    feature_name VARCHAR(100) NOT NULL, -- e.g., 'mock_tests_monthly'
    used_count INT DEFAULT 0,
    reset_date TIMESTAMP WITH TIME ZONE NOT NULL,
    PRIMARY KEY (user_id, feature_name)
);
```

## 5. Real-World Scalable Approach

1. **Token Payload Optimization**: Store both `role` and `subscription` in the JWT payload. This allows your middlewares to execute authorization checks synchronously without hitting the database on every single API call. When a user upgrades, issue a new JWT.
2. **Webhook-Driven Billing**: Never trust the frontend for subscription updates. Rely entirely on secure webhooks from your payment provider (e.g., Stripe `invoice.payment_succeeded`). When the webhook arrives, update the `subscriptions` table, the `users.subscription` column, and increment the user's `token_version` to force them to fetch a new token reflecting their new tier.
3. **Redis Quota Tracking**: Instead of running `UPDATE user_quotas SET used_count = used_count + 1` in PostgreSQL every time an AI evaluation occurs, track feature usage quotas in Redis using INCR and TTL. Sync it back to Postgres via a CRON job or background worker. This significantly reduces database write load for high-traffic features.
4. **Attribute-Based Access Control (ABAC)**: If the app scales to include organizations, schools, or custom roles (e.g., "Content Editor" or "Tutor"), migrate from simple Roles to an ABAC/Permissions model where users are assigned specific permission strings (e.g., `create:mock_test`, `view:reports`) handled by libraries like `@casl/ability`.
