# Task 4: Improvements & Complete System Flow

## 1. Production-Level Improvements

To transition the backend from a functional state to a highly scalable, production-ready system, the following improvements should be implemented across four key areas:

### Security Improvements
- **HttpOnly Cookies for JWT**: Currently, Access and Refresh tokens are returned in the JSON body. **Improvement**: Set the Refresh Token inside a secure, `HttpOnly`, `SameSite=Strict` cookie. This completely mitigates Cross-Site Scripting (XSS) attacks from stealing the token. The short-lived Access token can remain in memory.
- **Strict Validation Layer**: While Joi is used, implement a generic global validation middleware to automatically sanitize inputs and strip unknown fields before they reach the controller (`stripUnknown: true` in Joi). This prevents malicious payload injection.
- **Distributed Rate Limiting**: The current rate limiter relies on server memory. **Improvement**: Back the rate limiter with Redis (`rate-limit-redis`). In a production environment with multiple Node.js instances (Load Balancing), memory-based limiters fail to share state. Redis ensures global limits.
- **SQL Safety & ORM**: Using raw `pool.query` with `$1` protects against basic SQL injection, but is prone to human error and difficult to maintain. **Improvement**: Adopt a Query Builder (like **Knex.js**) or a modern ORM (like **Prisma** or **Drizzle**) to abstract query strings, enforce type safety, and handle migrations cleanly.

### Scalability Improvements
- **Strict Domain-Driven Design (DDD)**: As highlighted in Task 1, move models and validators directly into their respective feature folders in `src/modules/`. This makes microservice extraction trivial in the future.
- **Redis Caching**: Implement caching for read-heavy, low-mutation routes (e.g., `GET /api/v1/content/test/available`). Cache invalidation should only trigger when an admin creates or updates a test.
- **Message Queues (BullMQ)**: Node.js is single-threaded. Holding an HTTP connection open while waiting for file uploads and AI APIs will block the event loop and crash the server under load. **Improvement**: Offload all heavy tasks (AI processing, Email sending) to a Redis-backed Queue (e.g., Bull).

### Database Improvements
- **Strategic Indexing**: Ensure B-Tree indexes are applied to frequently queried columns (e.g., `users.email`, `test_attempts.user_id`, `test_attempts.status`).
- **Referential Integrity**: Ensure all tables strictly enforce `ON DELETE CASCADE` (or `RESTRICT`) to prevent orphaned records if an admin deletes a test or a user deletes their account.
- **JSONB for Dynamic AI Rubrics**: IELTS/PTE scoring rubrics and AI feedback can be highly dynamic. Instead of creating 20 rigid columns for "grammar_score", "vocab_score", etc., utilize PostgreSQL's powerful `JSONB` column type. Store the entire AI evaluation payload in an `evaluation_data JSONB` column. This allows dynamic scaling while still being indexable and queryable.

### AI-Related Improvements
- **Async Processing via Queues**: Never wait for Gemini/Deepgram sequentially in an HTTP request. Accept the request, return a `202 Accepted` status, and process the AI request in a background worker.
- **Retries with Exponential Backoff**: External AI providers frequently timeout or hit rate limits. Configure your queue to automatically retry failed AI jobs (e.g., 3 retries, waiting 2s, then 4s, then 8s) before marking the attempt as failed.
- **Circuit Breakers**: If the Gemini API goes down completely, implement a Circuit Breaker pattern to immediately notify the user ("AI Service currently unavailable") rather than endlessly queuing jobs.

---

## 2. Complete App System Flow

This workflow maps the end-to-end journey of a user interacting with the AI-powered testing system, illustrating how data moves through the architecture.

### Step 1: User Journey Initiation (Auth & Discovery)
- **Action**: User registers, verifies OTP, logs in, and browses available mock tests.
- **Backend Flow**: The request hits `GET /available-tests`. The Controller calls the Service layer, which checks the user's `subscription` tier via the `req.user` JWT payload. The Repository queries PostgreSQL and returns only tests the user is authorized to take.

### Step 2: Test Execution & Live Sync
- **Action**: User starts a test and begins answering questions (Reading, Listening, Writing, Speaking).
- **Backend Flow**: To prevent data loss (e.g., app crashes, internet drop), the frontend periodically calls `POST /api/v1/progress/sync`. The backend securely upserts the current answers into a `user_responses` table.

### Step 3: Test Submission
- **Action**: User clicks "Submit Test".
- **Backend Flow**: 
  - **Objective Sections** (Reading/Listening) are evaluated instantaneously by the backend Service comparing answers to the DB.
  - **Subjective Sections** (Speaking): Audio buffers are uploaded to your cloud storage (Cloudinary/S3), which returns an audio URL.
  - The test status in the `test_attempts` table is marked as `processing`.
  - The backend responds immediately to the frontend: `{ "message": "Test submitted. AI is evaluating your responses." }`.

### Step 4: AI Evaluation (Background Worker)
- **Action**: The backend pushes a job to the Redis Queue (e.g., `ai-eval-queue`).
- **Backend Flow**: A separate background worker picks up the job.
  - **Speaking Evaluation**: The worker sends the audio URL to **Deepgram** to get a precise transcript, pronunciation scores, and fluency metrics. The transcript is then forwarded to **Gemini** with an IELTS/PTE prompt to evaluate grammatical range and lexical resource.
  - **Writing Evaluation**: The essay text is sent directly to **Gemini** to evaluate task achievement, coherence, and grammar.

### Step 5: Aggregation & Notification
- **Action**: The AI completes processing.
- **Backend Flow**: 
  - The worker passes the raw AI scores into your `bandScoreCalculator.js` utility.
  - The final scores and detailed feedback strings are aggregated into a single JSON object.
  - The `test_attempts` table is updated: `evaluation_data = <jsonb>`, `status = 'completed'`.
  - **Notification**: The backend emits a WebSocket event (e.g., using `Socket.io`) or sends a Push Notification telling the frontend the results are ready.

### Step 6: Reviewing Results
- **Action**: User views their test report.
- **Backend Flow**: `GET /api/v1/progress/test-report/:attemptId`. The backend fetches the `JSONB` evaluation data and serves it. The frontend renders dynamic radar charts, band scores, grammar corrections, and speaking weakness highlights.
