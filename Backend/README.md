# Testiva - AI-Powered IELTS and PTE Preparation (Backend)

Welcome to the backend repository of **Testiva**, a comprehensive AI-powered platform tailored for IELTS and PTE exam preparation. This backend serves as the core engine powering real-time assessments, AI-driven evaluations, user tracking, community interactions, and seamless offline synchronization.

---

## 📖 Table of Contents

1. [Project Flow & Architecture](#project-flow--architecture)
2. [Key Libraries & Tech Stack](#key-libraries--tech-stack)
3. [Real-World Applications](#real-world-applications)
4. [Future Optimizations (API Performance)](#future-optimizations-api-performance)
5. [Scalability & Clean Code Guidelines](#scalability--clean-code-guidelines)

---

## 🔄 Project Flow & Architecture

The Testiva backend is designed using a **Modular Monolith** architecture to ensure clear separation of concerns while keeping deployment straightforward.

### The Request Lifecycle

1. **Client Request:** Mobile or Web apps send HTTP/HTTPS requests or connect via WebSockets.
2. **Security & Middleware:** Requests pass through security layers (`helmet`, `cors`), payload limits, and API rate limiting.
3. **Routing:** Express routes traffic to the specific modular subsystem (`/api/v1/content`, `/api/v1/auth`, etc.).
4. **Controllers & Services:** Business logic is executed. This may involve:
   - Synchronous database queries (PostgreSQL).
   - Fast cache retrievals (Redis).
   - Enqueueing background jobs for heavy processing (Bull).
   - Triggering AI models for text/speech evaluation (`@google/generative-ai`).
5. **Real-time Engine:** If a state changes (e.g., test evaluated), `Socket.io` or `Firebase Admin` pushes updates to connected clients immediately.

### Modules Breakdown

The codebase is structured into distinct domains under `src/modules/`:

- **M1_Identity:** Authentication, Role-based Access Control (Admin, User).
- **M2_Test:** Mock Tests, Questions, AI Evaluations.
- **M3_Preparation:** Study materials and curated lessons.
- **M4_Progress:** Analytics, scoring history, and performance tracking.
- **M5_Offline:** Synchronization logic for offline study capabilities.
- **M6_AI:** Wrappers and handlers for Google Generative AI processing.
- **M7_Community:** Forums, peer discussions, and leaderboards.
- **M8_Payment:** Subscription and transaction handling.
- **M9_Notification:** In-app WebSocket alerts and Push Notifications.

---

## 🛠 Key Libraries & Tech Stack

The backend leverages a robust Node.js stack with the following core dependencies:

| Category             | Library                            | Purpose                                                                                    |
| :------------------- | :--------------------------------- | :----------------------------------------------------------------------------------------- |
| **Core Framework**   | `express`                          | Web server and API routing.                                                                |
| **Database**         | `pg` (PostgreSQL)                  | Primary relational database.                                                               |
| **Caching & Queues** | `redis`, `bull`                    | High-speed data caching and background task queuing (e.g., email sending, AI async tasks). |
| **Real-time & Comm** | `socket.io`, `firebase-admin`      | Real-time bi-directional events and mobile push notifications.                             |
| **AI Integration**   | `@google/generative-ai`            | Powers automated grading for IELTS/PTE speaking and writing tasks.                         |
| **Security**         | `helmet`, `bcrypt`, `jsonwebtoken` | HTTP headers security, password hashing, and stateless API authentication.                 |
| **File Handling**    | `multer`, `sharp`, `cloudinary`    | Processing multipart form data, image optimization, and cloud storage for media assets.    |
| **Validation**       | `joi`                              | Strict schema validation for incoming API payloads.                                        |
| **Emails**           | `nodemailer`                       | Sending transactional emails (verification, password resets).                              |

---

## 🌍 Real-World Applications

While built specifically for IELTS and PTE, the underlying architecture of this backend is highly versatile. It can be adapted to various real-world platforms:

- **EdTech & E-Learning:** Any learning management system (LMS) requiring structured courses, progress tracking, and interactive quizzes.
- **Corporate Training Portals:** Platforms for employee onboarding, skill assessment, and certification.
- **Automated Assessment Systems:** Platforms requiring subjective grading (essays, spoken answers) utilizing AI rather than manual human review.
- **Offline-First Applications:** The robust `M5_Offline` synchronization logic is perfect for applications deployed in areas with low or intermittent internet connectivity.

---

## 🚀 Future Optimizations (API Performance)

To ensure sub-100ms response times as user traffic scales, the following optimizations should be considered:

1. **Advanced Database Indexing:** Implement B-Tree and Hash indexes on frequently queried columns (e.g., `user_id` in progress tables, `tags` in content).
2. **Aggressive Caching Strategies:** Expand Redis usage to cache serialized JSON responses for static/semi-static endpoints like "Available Mock Tests". Use cache invalidation hooks on update.
3. **Pagination & Cursor Fetching:** Ensure all list endpoints use cursor-based pagination (rather than offset) to prevent performance degradation on large tables.
4. **Query Optimization:** Refactor ORM/Query Builder calls to minimize `N+1` query problems using efficient `JOIN` operations.
5. **CDN for Assets:** Ensure all media (audio, images) uploaded via Cloudinary is served through a globally distributed CDN.

---

## 🏗 Scalability & Clean Code Guidelines

To maintain a pristine, easily navigable, and scalable codebase for future developers:

### 1. Enforce the Modular Architecture

Keep domains strictly separated. The `M1_Identity` module should not write directly to `M2_Test` tables. Use internal service layers or event emitters to communicate between modules.

### 2. Transition to TypeScript

Migrating from raw JavaScript to **TypeScript** will dramatically improve developer experience, catch bugs at compile-time, and serve as self-documenting code via strict typing of payloads and responses.

### 3. Implement Microservices (If Needed)

If the AI Evaluation module (`M6_AI`) becomes a bottleneck due to long processing times, it can be seamlessly decoupled into a separate Python or Go microservice that communicates via a message broker (like RabbitMQ or Redis Pub/Sub).

### 4. Comprehensive Testing

Introduce test-driven development (TDD):

- **Unit Tests:** For discrete functions (e.g., score calculation algorithms).
- **Integration Tests:** For testing API routes and database interactions using tools like `Jest` and `Supertest`.

### 5. Centralized Logging & Monitoring

Replace standard console logs with structured logging (e.g., `Winston` or `Pino`). Integrate a monitoring tool like Datadog, New Relic, or the ELK Stack to track API latencies, error rates, and system health in production.

---

_Built with ❤️ for Testiva._
