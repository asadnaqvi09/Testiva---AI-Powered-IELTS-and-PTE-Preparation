# Task 3: API Testing + Documentation

> **Roman Urdu Explanation (Khulasa)**  
> *Is document mein hum aapke backend ki API Testing aur Documentation ke baare mein detail se baat karenge. Pehle hisse mein Postman use kar ke APIs ko step-by-step test karne ka tarika, JSON requests, aur Auth flow (Register -> OTP -> Login -> JWT token) samjhaya gaya hai. Dusre hisse mein APIs ko clean format mein document karne ka tarika aur Swagger/OpenAPI ko project mein integrate karne ka setup bataya gaya hai taake aapki frontend team asani se endpoints ko samajh aur use kar sake.*

---

## Part 1: Postman Testing Guide

Testing APIs sequentially in Postman is crucial. Your application follows an OTP-based registration and a JWT-based authentication flow.

### Step-by-Step Auth Flow (Register → Login → Token → Protected Routes)

**1. Register User**
- **Endpoint**: `POST /api/v1/auth/register`
- **Purpose**: Creates a temporary user and sends an OTP to their email.
- **Body (JSON)**:
  ```json
  {
    "full_name": "Asad Naqvi",
    "email": "asad@example.com",
    "password": "SecurePassword123"
  }
  ```
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "OTP sent",
    "email": "asad@example.com"
  }
  ```

**2. Verify OTP**
- **Endpoint**: `POST /api/v1/auth/verify-otp`
- **Purpose**: Verifies the OTP and permanently saves the user to the database, returning an access token.
- **Body (JSON)**:
  ```json
  {
    "email": "asad@example.com",
    "otp": "123456",
    "type": "register"
  }
  ```
- **Expected Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Account verified",
    "token": "eyJhbGciOiJIUz...",
    "user": {
      "id": "uuid-here",
      "full_name": "Asad Naqvi",
      "email": "asad@example.com",
      "role": "user",
      "subscription": "free"
    }
  }
  ```

**3. Login (Returning Users)**
- **Endpoint**: `POST /api/v1/auth/login`
- **Body (JSON)**:
  ```json
  {
    "email": "asad@example.com",
    "password": "SecurePassword123"
  }
  ```
- **Expected Response (200 OK)**:
  ```json
  {
    "success": true,
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG...",
    "expiresIn": "15m",
    "user": { ... }
  }
  ```

**4. Accessing Protected Routes**
- Now that you have the `accessToken`, you must pass it in the Headers for protected routes.
- **Header Configuration in Postman**:
  - **Key**: `Authorization`
  - **Value**: `Bearer eyJhbG...` *(Replace with actual token)*

**5. Fetch Available Tests (Protected)**
- **Endpoint**: `GET /api/v1/content/test/available`
- **Headers**: `Authorization: Bearer <token>`
- **Expected Response (200 OK)**: Returns an array of test objects available to the user's subscription tier.

### Common Errors & Expected Responses
- **401 Unauthorized**: Missing or invalid JWT token. 
  *Fix: Check Authorization header.*
- **403 Forbidden**: User lacks the required role (e.g., trying to access Admin routes) or subscription tier.
- **400 Bad Request**: Validation failed (e.g., missing email, weak password). Your Joi validator will return: `{"success": false, "message": "\"email\" must be a valid email"}`.
- **409 Conflict**: Email already registered.

---

## Part 2: API Documentation Format & Swagger Integration

Having a clean documentation format is essential for any production-level backend. Here is how your APIs should be structured logically.

### Clean API Docs Format (Example Grouping)

#### 🟢 Authentication (`/api/v1/auth`)
- `POST /register` - Initiates user registration (OTP).
- `POST /verify-otp` - Verifies OTP and logs user in.
- `POST /login` - Authenticates existing user.
- `POST /refresh-token` - Generates a new access token using a refresh token.

#### 🔵 Tests Content (`/api/v1/content/test`)
- `GET /available` - [Auth Required] Fetch all mock tests available to the user.
- `GET /:id` - [Auth Required] Fetch details of a specific test.
- `POST /create-full-test` - [Admin Only] Create a new mock test.

#### 🟣 AI Evaluation (`/api/v1/ai`)
- `POST /evaluate/writing` - [Basic/Premium] Send essay text for AI band scoring and feedback.
- `POST /evaluate/speaking` - [Basic/Premium] Upload audio buffer for Deepgram/Gemini evaluation.

---

### Swagger / OpenAPI Integration

Manually writing API docs is tedious. **Swagger (OpenAPI)** automatically generates a beautiful, interactive web UI where the frontend team can read and directly test APIs.

**Roman Urdu Note:** *Swagger integrate karne se aapke project mein ek `/api-docs` ka route ban jayega jahan ek khoobsurat UI mein saari APIs list ho jayengi. Frontend developers wahan se direct API test kar sakte hain bina Postman ke.*

#### How to integrate Swagger in your project:

**Step 1: Install Dependencies**
```bash
npm install swagger-ui-express swagger-jsdoc
```

**Step 2: Setup Configuration (`src/config/swagger.js`)**
Create a new file to hold your Swagger configuration:
```javascript
import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Testiva Backend API',
      version: '1.0.0',
      description: 'API documentation for the Testiva IELTS/PTE App',
    },
    servers: [
      { url: 'http://localhost:3000', description: 'Local Server' }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        }
      }
    },
    security: [{ bearerAuth: [] }]
  },
  apis: ['./src/modules/**/*.routes.js'], // Scans all your route files
};

export const swaggerSpec = swaggerJsdoc(options);
```

**Step 3: Update Routes with JSDoc Comments**
Inside your route files (e.g., `auth.routes.js`), add comments above the routes:

```javascript
/**
 * @swagger
 * /api/v1/auth/login:
 *   post:
 *     summary: Login a user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 */
Router.post('/login', rateLimiter.authLimiter, authController.loginUser);
```

**Step 4: Mount Swagger in `index.js`**
```javascript
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './src/config/swagger.js';

// Add this below your regular middlewares
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
```

Now, navigating to `http://localhost:3000/api-docs` will display your fully interactive, production-ready API documentation!
