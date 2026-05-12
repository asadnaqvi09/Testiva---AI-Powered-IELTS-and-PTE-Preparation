# Testiva Postman Guide: M1_Identity Module

This document is an exhaustive guide covering **every single API endpoint** inside the `M1_Identity` module. It is divided into three sections: **Auth (11 APIs)**, **User (5 APIs)**, and **Admin (3 APIs)**.

> [!IMPORTANT]
> **Base URL**: `http://localhost:3000/api`
> **Protected Routes**: Any route marked with 🔒 requires the `Authorization: Bearer <token>` header.
> **Admin Routes**: Any route marked with 👑 requires an admin token.

---

## 🔑 Section 1: Authentication APIs (11 Endpoints)

### 1. Register User
*   **Endpoint**: `POST /auth/register`
*   **Body** (JSON):
```json
{
  "full_name": "Test User",
  "email": "testuser@testiva.com",
  "password": "Password123!"
}
```
*   **Best Case (201 Created)**: Temp user saved, 6-digit OTP sent to email.
*   **Worst Case (400 Bad Request)**: Email already exists, or password validation fails.

### 2. Login User
*   **Endpoint**: `POST /auth/login`
*   **Body** (JSON):
```json
{
  "email": "testuser@testiva.com",
  "password": "Password123!"
}
```
*   **Best Case (200 OK)**: Returns `{ success: true, accessToken, refreshToken, user }`.
*   **Worst Case (400 Bad Request)**: Invalid credentials or account locked.

### 3. Verify OTP
*   **Endpoint**: `POST /auth/verify-otp`
*   **Body** (JSON):
```json
{
  "email": "testuser@testiva.com",
  "otp": "123456",
  "type": "register"
}
```
*   **Best Case (201 Created)**: Email verified, temp user moved to main `users` table, triggers Admin Firebase notification, returns Auth tokens.
*   **Worst Case (400 Bad Request)**: Invalid or Expired OTP.

### 4. Resend OTP
*   **Endpoint**: `POST /auth/resend-otp`
*   **Body** (JSON):
```json
{
  "email": "testuser@testiva.com",
  "type": "register" 
}
```
*   **Best Case (200 OK)**: New OTP generated and emailed.
*   **Worst Case (429 Too Many Requests)**: Rate limiter hits if clicked too fast.

### 5. Forgot Password
*   **Endpoint**: `POST /auth/forgot-password`
*   **Body** (JSON):
```json
{
  "email": "testuser@testiva.com"
}
```
*   **Best Case (200 OK)**: Sends password reset OTP to email.
*   **Worst Case (404 Not Found)**: User with this email does not exist.

### 6. Reset Password
*   **Endpoint**: `POST /auth/reset-password`
*   **Body** (JSON):
```json
{
  "email": "testuser@testiva.com",
  "otp": "654321",
  "new_password": "NewPassword123!"
}
```
*   **Best Case (200 OK)**: Password updated successfully.
*   **Worst Case (400 Bad Request)**: Invalid OTP or new password doesn't meet constraints.

### 7. Google OAuth Login/Register
*   **Endpoint**: `POST /auth/google`
*   **Body** (JSON):
```json
{
  "idToken": "google_generated_id_token_eyJhb..."
}
```
*   **Best Case (200 OK)**: Verifies Google token, creates/logs in user, triggers Firebase Admin notification, returns Auth tokens.
*   **Worst Case (400 Bad Request)**: Invalid Google ID token.

### 8. Refresh Access Token
*   **Endpoint**: `POST /auth/refresh-token`
*   **Body** (JSON):
```json
{
  "refreshToken": "your_saved_refresh_token_string"
}
```
*   **Best Case (200 OK)**: Returns a new `accessToken`.
*   **Worst Case (401 Unauthorized)**: Refresh token expired or revoked.

### 9. Logout Single Device 🔒
*   **Endpoint**: `POST /auth/logout`
*   **Body** (JSON):
```json
{
  "refreshToken": "token_to_delete"
}
```
*   **Best Case (200 OK)**: Deletes the specific refresh token from DB.
*   **Worst Case (400 Bad Request)**: Missing refresh token in payload.

### 10. Logout All Devices 🔒
*   **Endpoint**: `POST /auth/logout-all`
*   **Body**: Empty
*   **Best Case (200 OK)**: Increments `token_version` in DB and deletes ALL refresh tokens (Global Session Invalidation).
*   **Worst Case (401 Unauthorized)**: Invalid access token in header.

### 11. Set User Preferences 🔒
*   **Endpoint**: `POST /auth/user/preferences`
*   **Body** (JSON):
```json
{
  "preference": "IELTS" 
}
```
*(Options: "IELTS", "PTE", "ALL")*
*   **Best Case (200 OK)**: Preference saved, returns updated user object.
*   **Worst Case (400 Bad Request)**: Invalid preference string.

---

## 👤 Section 2: User Profile APIs (5 Endpoints)

### 1. Get Profile 🔒
*   **Endpoint**: `GET /users/profile`
*   **Best Case (200 OK)**: Returns full user profile object from DB.
*   **Worst Case (404 Not Found)**: User ID from token no longer exists in DB.

### 2. Update Profile 🔒
*   **Endpoint**: `PUT /users/profile`
*   **Body** (JSON):
```json
{
  "full_name": "Updated Name",
  "bio": "I am preparing for IELTS band 8!"
}
```
*   **Best Case (200 OK)**: Profile updated successfully.
*   **Worst Case (400 Bad Request)**: Bio length exceeds limit or full_name is empty.

### 3. Change Password 🔒
*   **Endpoint**: `PUT /users/password`
*   **Body** (JSON):
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewStrongPassword123!"
}
```
*   **Best Case (200 OK)**: Validates old password, hashes new one, and logs out other devices.
*   **Worst Case (400 Bad Request)**: Current password incorrect.

### 4. Upload Avatar 🔒
*   **Endpoint**: `POST /users/avatar`
*   **Body** (form-data):
   *   Key: `avatar` (File)
   *   Value: `image.jpg`
*   **Best Case (200 OK)**: Uploads to Cloudinary, returns new `avatar_url`.
*   **Worst Case (400 Bad Request)**: No file provided or file type not supported.

### 5. Update Push Notification Token 🔒
*   **Endpoint**: `PUT /users/fcm-token`
*   **Body** (JSON):
```json
{
  "fcm_token": "firebase_device_token_123"
}
```
*   **Best Case (200 OK)**: Saves the FCM token to DB for background Push Notifications.
*   **Worst Case (400 Bad Request)**: Token missing in payload.

---

## 👑 Section 3: Admin APIs (3 Endpoints)

### 1. Get Dashboard Statistics 👑
*   **Endpoint**: `GET /admin/stats`
*   **Best Case (200 OK)**: Returns aggregations (`total_users`, `free_users`, `premium_users`, `active_users`).
*   **Worst Case (403 Forbidden)**: Caller does not have 'admin' role.

### 2. Fetch All Users (Paginated) 👑
*   **Endpoint**: `GET /admin/users?page=1&limit=10&search=Ali&subscription=free`
*   **Best Case (200 OK)**: Returns paginated array of users matching search filters.
*   **Worst Case (401/403)**: Unauthorized or Forbidden.

### 3. Update User Subscription (Manual Override) 👑
*   **Endpoint**: `PUT /admin/users/subscription`
*   **Body** (JSON):
```json
{
  "userId": "uuid-of-the-user",
  "subscription": "premium"
}
```
*   **Best Case (200 OK)**: Upgrades user. *(Note: Our PostgreSQL trigger will catch this and instantly fire a Socket.io Admin notification!)*
*   **Worst Case (400 Bad Request)**: Invalid subscription tier or missing User ID.
