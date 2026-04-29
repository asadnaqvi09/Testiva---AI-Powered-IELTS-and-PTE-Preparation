# Task 1: Codebase Review & Architecture

## 1. Request Lifecycle (Starting from `index.js`)

The request lifecycle in your backend follows a clear and linear flow:
1. **Entry Point (`index.js`)**: The express server is initialized and the port is bound.
2. **Global Middlewares**: Incoming requests first pass through standard security and utility middlewares:
   - `cors()`: Handles Cross-Origin Resource Sharing.
   - `helmet()`: Sets security-related HTTP headers.
   - `morgan("dev")`: Logs request details to the console for debugging.
   - `express.json()` & `express.urlencoded()`: Parses incoming JSON and URL-encoded payloads.
3. **Static File Serving**: The `/uploads` route serves static media files via `express.static`.
4. **Routing (`/api/v1/*`)**: The request is matched against feature-based routers mounted in `index.js` (e.g., `/api/v1/auth`, `/api/v1/user`, `/api/v1/ai`).
5. **Controller Layer**: The matched router delegates the request to the corresponding controller function (e.g., `loginUser` in `auth.controller.js`).
6. **Validation**: Controllers typically use Joi schemas from `src/validators` to validate `req.body` before processing.
7. **Business Logic & Database Interaction**: If validation passes, the controller processes the logic and interacts with the PostgreSQL database. It does this either by calling functions from `src/models/` or executing raw SQL directly via the `pool`.
8. **Response / Error Handling**: The controller returns a JSON response. If any exception is thrown, it is caught in a `try-catch` block and/or forwarded to the global `errorHandler` middleware.

## 2. Folder Structure and Responsibilities

Current structure breakdown:
- **`index.js`**: Application entry point, server setup, global middleware registration, and route mounting.
- **`src/config/`**: Configuration instances for external services and the DB (e.g., `db.js`, `redis.js`, `cloudinary.js`, `deepgram.js`, `gemini.js`).
- **`src/database/`**: Contains raw `.sql` files for database table schemas (e.g., `users.sql`, `testiva.sql`). These act as manual migrations.
- **`src/email_templates/`**: Holds HTML templates and email transport logic (Nodemailer setup).
- **`src/middleware/`**: Cross-cutting concerns and guards like `auth.middleware.js`, `error.middleware.js`, `rateLimiter.middleware.js`, and `upload.middleware.js`.
- **`src/models/`**: Data access layer containing raw SQL query functions mapped to business entities (e.g., `user.model.js`, `test.model.js`).
- **`src/modules/`**: Feature-specific folders (e.g., `auth`, `user`, `ai`) containing Express routes and controller logic.
- **`src/uploads/`**: Local storage destination for uploaded files (images, audio) via Multer.
- **`src/utils/`**: Helper functions (e.g., `jwt.js`, `helpers.js`, `password.js`) and business logic tools (`bandScoreCalculator.js`).
- **`src/validators/`**: Joi validation schemas for validating incoming request payloads.

## 3. Best Practices Implemented

- **Security Focus**: You are correctly using `helmet` for secure headers, `bcrypt` for password hashing, and token versioning alongside Redis blocklisting for robust JWT invalidation on logout.
- **Global Error Handling**: A centralized `errorHandler` middleware ensures consistent error structures and prevents unhandled promise rejections from crashing the app.
- **Partial Modularity**: Grouping routes and controllers into `src/modules/` avoids massive monolithic route/controller files, making feature logic easier to find.
- **Rate Limiting**: Implementation of API rate limiting protects endpoints against brute force attacks and DDoS.
- **Advanced Token Management**: The architecture implements both Access and Refresh tokens with `token_version` tracking in the database, allowing for secure and programmatic session revocation.

## 4. Bad Practices & Risks

- **Missing Service Layer (Fat Controllers)**: Business logic is tightly coupled with HTTP concerns in the Controllers. For instance, `auth.controller.js` directly manages DB transactions, password hashing, and token logic. Controllers should ideally only parse requests, call a Service, and format the HTTP response.
- **Raw SQL scattered in Controllers**: While you have a `src/models/` folder, some controllers (like `auth.controller.js` on lines 44, 91, 168) run raw SQL `pool.query` directly instead of relying entirely on the model layer. This violates the Single Responsibility Principle.
- **Fragmented Feature Modularity**: While controllers and routes are contained in `src/modules/`, their corresponding models and validators are globally floating in `src/models/` and `src/validators/`. If you want to remove or extract a feature, you have to hunt down files in 4 different directories.
- **Lack of Database Migrations**: Relying on manual `.sql` files in `src/database` is difficult to track across environments. Missing a proper migration tool (like Knex migrations, Prisma, or node-pg-migrate) makes schema evolution risky in production.
- **Raw SQL without ORM/Query Builder**: Heavy reliance on raw SQL queries in string templates makes the codebase hard to scale for complex dynamic queries (like advanced filtering) and increases the risk of subtle SQL injection vulnerabilities if parameters are ever mishandled.

## 5. Proposed Improved Feature-Based Scalable Folder Structure

To ensure the backend is easily navigable, highly cohesive, and loosely coupled (even months down the line), we should shift to a strict **Domain-Driven Module Structure** (also known as component-based architecture). In this pattern, every feature (e.g., Auth, User, Test) is completely self-contained.

**Core Principles of the new architecture:**
- **Controllers**: Handle HTTP Request/Response only.
- **Services**: Handle pure business logic and orchestration.
- **Repositories (Models)**: Handle all database interactions (strictly no raw SQL in controllers or services).
- **Schemas/Validators**: Co-located inside the module they validate.

## 6. Final Recommended Folder Tree

```text
Backend/
├── index.js                     # Main server entry & bootstrap
├── package.json
├── .env
├── src/
│   ├── config/                  # Global configurations (DB pool, Redis client)
│   ├── database/
│   │   ├── migrations/          # Timestamped, automated DB migrations
│   │   ├── seeds/               # Seed data for development/testing
│   ├── core/                    # App-wide core utilities & shared logic
│   │   ├── middleware/          # Global middlewares (auth, error, upload, rateLimiter)
│   │   ├── utils/               # General helpers (jwt, otp, helpers)
│   │   └── exceptions/          # Custom Error classes (AppError, NotFoundError)
│   ├── modules/                 # Self-contained feature domains
│   │   ├── auth/                
│   │   │   ├── auth.controller.js
│   │   │   ├── auth.service.js  # Business logic (handling OTP, tokens, password checks)
│   │   │   ├── auth.routes.js
│   │   │   ├── auth.schema.js   # Joi validators for auth payload
│   │   │   └── google.service.js
│   │   ├── user/
│   │   │   ├── user.controller.js
│   │   │   ├── user.service.js
│   │   │   ├── user.routes.js
│   │   │   ├── user.repository.js # DB interactions (replaces user.model.js)
│   │   │   └── user.schema.js
│   │   ├── ai/
│   │   │   ├── ai.controller.js
│   │   │   ├── ai.service.js
│   │   │   ├── ai.routes.js
│   │   │   ├── evaluators/
│   │   │   └── prompts/
│   │   └── test/
│   │       ├── test.controller.js
│   │       ├── test.service.js
│   │       ├── test.routes.js
│   │       └── test.repository.js
```
