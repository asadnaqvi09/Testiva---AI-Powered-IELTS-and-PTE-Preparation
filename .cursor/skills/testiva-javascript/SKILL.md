---
name: testiva-javascript
description: >-
  Writes JavaScript and TypeScript for Testiva-FYP following backend module
  patterns (Node ESM, Joi, PostgreSQL) and Admin-Prototype conventions (React,
  TypeScript, api.ts). Use when editing Backend/src/**/*.js, Admin-Prototype
  frontend code, API endpoints, controllers, validators, services, or React pages.
---

# Testiva JavaScript

## Scope

This repo has two JS/TS surfaces:

| Area | Path | Language |
|------|------|----------|
| Backend API | `Backend/src/` | JavaScript (ESM) |
| Admin UI | `Admin-Prototype/src/` | TypeScript + React |

Match existing patterns in the file you are editing. Do not convert backend `.js` to TypeScript unless explicitly requested.

---

## Backend (Node ESM)

### Module layout

Modules live under `Backend/src/modules/` (e.g. `M1_Identity`, `M3_Preparation`). Each module typically has:

- `controller/` — HTTP handlers (`export const handler = async (req, res) => { ... }`)
- `validator/` — Joi schemas
- `services/` — business logic
- `models/` or `*.model.js` — database access
- `routes/` — Express route definitions

Shared code: `Backend/src/utils/`, `Backend/src/middleware/`, `Backend/src/config/`.

### Imports

- ESM only: `import` / `export`
- Always include `.js` extension on relative imports
- Prefer named exports

### API prefix

All routes mount under `/api/v1` in `Backend/index.js`. New route modules must be registered there.

### Controller pattern

```javascript
export const handlerName = async (req, res) => {
  try {
    const { error, value } = schema.validate(req.body);
    if (error)
      return res.status(400).json({ success: false, message: error.details[0].message });

    // delegate to model/service

    return res.status(200).json({ success: true, data: result });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: "Internal server error" });
  }
};
```

### Response shape

Use consistent JSON:

```json
{ "success": true, "data": { ... } }
{ "success": false, "message": "Human-readable error" }
```

### Validation

- Joi schemas in `validator/` files
- Validate in the controller before calling models/services
- Return the first Joi error message to the client

### Database

- Import `pool` from `config/db.js`
- Parameterize all queries (`$1`, `$2`, …) — never interpolate user input
- Use snake_case column names to match PostgreSQL schema

### Auth

- `authenticate` middleware in `middleware/auth.middleware.js` sets `req.user` (`id`, `role`, `subscription`, `tokenVersion`, `preference`)
- JWT helpers: `utils/jwt.js`
- Password/OTP hashing: `utils/helpers.js`, `bcrypt`

---

## Frontend (Admin-Prototype)

### Stack

- React 18 + TypeScript
- Vite (`@` alias → `src/`)
- Tailwind CSS
- Radix/shadcn UI primitives in `src/app/components/ui/`
- Icons: `lucide-react`
- Toasts: `sonner` (`toast.success`, `toast.error`)

### Structure

- `src/app/pages/` — route-level page components
- `src/app/components/` — shared and layout components
- `src/app/context/` — React context (e.g. `AuthContext`)
- `src/app/services/api.ts` — **all** backend HTTP calls
- `src/app/routes` — React Router setup

### API calls

- Never call `fetch` directly from pages — add or reuse functions in `services/api.ts`
- Base path: `/api/v1` (proxied to `localhost:5000` in dev via `vite.config.ts`)
- `apiFetch` handles auth headers, token refresh on 401, and JSON parsing
- For file uploads, pass `FormData` as body (do not set `Content-Type` manually)

### Page component pattern

```tsx
import React, { useState, useEffect, useCallback } from 'react';
import { SomeIcon, Loader2 } from 'lucide-react';
import { someApiFn } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';

export default function SomePage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // load data via api.ts helpers
  }, []);

  if (loading) return <Loader2 className="animate-spin" />;
  return (/* JSX */);
}
```

### UI conventions

- Reuse `components/ui/*` primitives before creating new base components
- Use Tailwind utility classes; inline styles only for dynamic badge colors (see `Preparation.tsx`)
- Show loading states (`Loader2`) and surface API errors via `toast.error`

### TypeScript

- Prefer explicit types for API payloads and component props
- Use `.tsx` for components, `.ts` for services and utilities
- Avoid `any` unless matching existing `api.ts` patterns

---

## Cross-cutting rules

1. **Minimize scope** — change only what the task requires
2. **Reuse before adding** — check `utils/`, existing validators, and `api.ts` first
3. **No new dependencies** unless necessary and consistent with the stack
4. **Security** — parameterized SQL, validate all inputs, never log secrets or tokens
