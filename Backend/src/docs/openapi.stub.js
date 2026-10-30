/**
 * L1 — Minimal OpenAPI 3 stub for /api/v1 (not exhaustive; expand as needed).
 */
export const openApiStub = {
  openapi: "3.0.3",
  info: {
    title: "Testiva API",
    version: "1.0.0",
    description:
      "AI-Powered IELTS & PTE Preparation — stub OpenAPI for FYP demos. Full coverage TBD.",
  },
  servers: [{ url: "/api/v1", description: "API v1" }],
  tags: [
    { name: "Health" },
    { name: "Auth" },
    { name: "User" },
    { name: "Admin" },
    { name: "Tests" },
    { name: "Preparations" },
    { name: "Progress" },
    { name: "AI" },
    { name: "Community" },
    { name: "Notifications" },
    { name: "Payments" },
  ],
  paths: {
    "/health": {
      get: {
        tags: ["Health"],
        summary: "Health check",
        responses: {
          200: {
            description: "OK",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    success: { type: "boolean" },
                    data: { type: "object" },
                  },
                },
              },
            },
          },
        },
      },
    },
    "/auth/login": {
      post: {
        tags: ["Auth"],
        summary: "Email/password login",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["email", "password"],
                properties: {
                  email: { type: "string", format: "email" },
                  password: { type: "string" },
                },
              },
            },
          },
        },
        responses: {
          200: { description: "{ data: { user, accessToken, refreshToken } }" },
          401: { description: "INVALID_CREDENTIALS" },
        },
      },
    },
    "/auth/register": {
      post: {
        tags: ["Auth"],
        summary: "Register (OTP flow)",
        responses: { 200: { description: "OTP sent / pending verify" } },
      },
    },
    "/user/profile": {
      get: {
        tags: ["User"],
        summary: "Get profile",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "User profile" } },
      },
      put: {
        tags: ["User"],
        summary: "Update profile",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Updated" } },
      },
    },
    "/user/settings": {
      put: {
        tags: ["User"],
        summary: "Theme + notif_prefs (incl. quiet hours)",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Settings saved" } },
      },
    },
    "/admin/users": {
      get: {
        tags: ["Admin"],
        summary: "List users (paginated)",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Users page" } },
      },
      post: {
        tags: ["Admin"],
        summary: "Create user",
        security: [{ bearerAuth: [] }],
        responses: { 201: { description: "Created" } },
      },
    },
    "/admin/queues/sync-tests": {
      get: {
        tags: ["Admin"],
        summary: "Bull sync-tests queue depth + recent failed jobs",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Queue counts + failed sample" } },
      },
    },
    "/admin/payment-events": {
      get: {
        tags: ["Admin"],
        summary: "Payment event ledger",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Paginated payment_events" } },
      },
    },
    "/content/test": {
      get: {
        tags: ["Tests"],
        summary: "List published tests for student preference",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Tests" } },
      },
    },
    "/content/preparations": {
      get: {
        tags: ["Preparations"],
        summary: "List prep lessons",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Prep list" } },
      },
    },
    "/progress/submit": {
      post: {
        tags: ["Progress"],
        summary: "Submit attempt (may return 202 + job_id)",
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: "Result ready" },
          202: { description: "Queued for AI / offline sync" },
        },
      },
    },
    "/ai/recommendation": {
      get: {
        tags: ["AI"],
        summary: "Performance tip",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "{ tip, focus_module, source }" } },
      },
    },
    "/community/create-post": {
      post: {
        tags: ["Community"],
        summary: "Create post (optional multipart image)",
        security: [{ bearerAuth: [] }],
        responses: { 201: { description: "Post created" } },
      },
    },
    "/community/upload-image": {
      post: {
        tags: ["Community"],
        summary: "Upload post image to Cloudinary",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "{ image_url }" } },
      },
    },
    "/notifications": {
      get: {
        tags: ["Notifications"],
        summary: "List notifications + unread_count",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "{ items, unread_count }" } },
      },
    },
    "/payments/plans": {
      get: {
        tags: ["Payments"],
        summary: "Stripe plan catalog",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Plans" } },
      },
    },
    "/payments/checkout": {
      post: {
        tags: ["Payments"],
        summary: "Create Stripe Checkout session",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "{ checkout_url, session_id }" } },
      },
    },
    "/payments/me": {
      get: {
        tags: ["Payments"],
        summary: "Current entitlements",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "{ plan, status, unlocked_exam }" } },
      },
    },
    "/payments/invoices": {
      get: {
        tags: ["Payments"],
        summary: "Current user payment history",
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: "Invoice/event list" } },
      },
    },
  },
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
      },
    },
  },
};
