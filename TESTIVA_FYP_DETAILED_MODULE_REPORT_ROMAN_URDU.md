# Testiva FYP — Complete Module Report (Roman Urdu)

**Project:** Testiva — AI-Powered IELTS & PTE Preparation  
**Type:** Final Year Project (EdTech Application)  
**Folders:** `Backend/` · `frontend/` (Flutter Student App) · `Admin-Prototype/` (React Admin Panel)  
**Report Date:** 30 October 2026  
**Last Status Refresh:** 30 October 2026 (session — H/M/L backlog complete)

---

## 0. Project Overview (Mukhtasir)

Testiva aik EdTech platform hai jo students ko **IELTS** aur **PTE** ke liye AI-powered prep, mock tests, progress tracking, community, aur payments deta hai.

| Layer | Tech | Role |
|-------|------|------|
| **Backend** | Node.js + Express (ESM), PostgreSQL (raw SQL), Redis, Socket.io, Gemini AI, Stripe, Cloudinary, FCM | API + AI evaluation + realtime |
| **frontend** | Flutter (Dart), `http`, Provider, SQLite (`sqflite`) | Student mobile / multi-platform app |
| **Admin-Prototype** | React + TypeScript (Vite), native `fetch` | Content, users, moderation, analytics |

**Backend modules (M1–M9):**

1. M1_Identity — Auth, User, Admin  
2. M2_Test — Mock tests  
3. M3_Preparation — Prep lessons  
4. M4_Progress — Submit / results / stats  
5. M5_Offline — Bull queue (offline + async AI)  
6. M6_AI — Gemini evaluation & insights  
7. M7_Community — Posts / comments / likes  
8. M8_Payment — Stripe plans  
9. M9_Notification — REST + Socket + FCM  

**API base:** `/api/v1`  
**Standard response (ideal):** `{ success: true, data: ... }` / `{ success: false, message: "..." }`

---

## Status Update (H / M / L — is session ke baad)

**High Priority H1–H8:** ✅ **DONE** (demo-critical fixes shipped).  
**Medium Priority M1–M9:** ✅ **DONE** (API polish, Admin UX, prep cache, community drafts, payment service, docs).  
**Low Priority L1–L10:** ✅ **DONE** (OpenAPI stub, cleanup notes, theme persist, ops endpoints, community images, payment ledger, quiet hours, e2e smoke, yeh report refresh, dead-code comments).

| ID | Summary | Status |
|----|---------|--------|
| H1 | Admin Prep PDF `data.file_url` + endpoint labels | ✅ |
| H2 | Flutter in-app PDF viewer + close | ✅ |
| H3 | AuthGate token refresh → Home/Preference | ✅ |
| H4 | Admin Users pagination, Add/Delete, preference approve queue | ✅ |
| H5 | M9 `{ data: { items, unread_count } }` + clients | ✅ |
| H6 | Redis unified helper; 202 submit `job_id` / poll hints | ✅ |
| H7 | Progress UX, stats cache, speaking blocks submit | ✅ |
| H8 | PTE `singular_module` allowed (section practice) | ✅ |
| M1–M9 | Identity API, Test Builder sidebar, prep cache/AI cards, Attempts inspector, sync UX, AI shapes, community drafts/TOEFL remove, payment.service, NOTIFICATION_TYPES.md | ✅ |
| L1 | `GET /api/v1/openapi.json` + `/api/docs` Swagger UI stub | ✅ |
| L2 | Admin `dummyData` / unused shadcn ui kit — note (`components/ui/README.md` + dummyData header) | ✅ |
| L3 | `ThemeProvider` SharedPreferences persist (Flutter restart) | ✅ |
| L4 | `GET /admin/queues/sync-tests` (Bull depth + recent failed) | ✅ |
| L5 | `posts.image_url` + `POST /community/upload-image` + create-post `image_url` | ✅ |
| L6 | `GET /payments/invoices` + `GET /admin/payment-events` + Admin Subscriptions ledger | ✅ |
| L7 | Quiet hours in `notif_prefs` + FCM gate; `digestEnabled` (digest job optional/stub) | ✅ |
| L8 | `scripts/e2e-smoke.js` | ✅ |
| L9 | Yeh report refresh | ✅ |
| L10 | Comments on `utils/otp.js` + unused `passwordResetLimiter` | ✅ |

**Ab bhi intentionally open (non-goals):** Admin AI moderate preview **wired nahi** (Gemini quota); **TOEFL** product mein nahi; preference change sirf **student request → admin approve** (self-serve toggle nahi).

**Optional polish (backlog):** TestBuilder file split; M6 `processors` folder rename; dedicated Community **Drafts** Admin UI; TopBar `deleteNotificationAPI` wire.

---

## Modules List According to 3 Folders

Neeche har module ke liye: **Flow**, **Files (Backend / Frontend / Admin)**, **Linking**, **Functionalities**, **Improvements**, **API Response Enhancement**, aur **Gaps / Bugs**.

---

# Module 1 — Identity (Auth + User Profile + Admin Users)

## 1.1 Flow (kaise kaam karta hai)

```
Student App / Admin Panel
    → POST /auth/register | login | google | OTP | forgot/reset
    → JWT access + refresh tokens
    → Preference select (IELTS / PTE)
    → GET/PUT /user/profile, avatar, password, settings, FCM
Admin
    → GET /admin/users, PUT subscription/unlock
    → Dashboard stats / search (M1 admin APIs)
```

**Student journey:** Onboarding → AuthScreen → OTP (agar register) → Preference → Dashboard.  
**Admin journey:** Login (sirf `role === admin`) → DashboardLayout → Users / Settings.

## 1.2 Files

### Backend (`Backend/src/modules/M1_Identity/`)
- `user.model.js`
- **Auth:** `auth/controller/auth.controller.js`, `auth/routes/auth.routes.js`, `auth/validator/auth.validator.js`, `auth/services/google.service.js`
- **User:** `user/controller/user.controller.js`, `user/routes/user.routes.js`, `user/routes/feedback.routes.js`, `user/validator/user.validator.js`, `user/services/image.service.js`
- **Admin:** `admin/controller/admin.controller.js`, `admin/routes/admin.routes.js`
- Shared: `middleware/auth.middleware.js`, `utils/jwt.js`, `email_templates/*`

### Frontend (`frontend/lib/`)
- `src/onboarding/onboarding_screen.dart` + widgets  
- `src/auth/auth_screen.dart`, login/signup/forgot_password widgets  
- `src/auth/signup/otp_screen.dart`, `preference_selection_screen.dart`, `email_verified_screen.dart`  
- `src/profile/profile_screen.dart`, `edit_profile_modal.dart`, …  
- `core/services/api_service.dart`, `auth_gate.dart`, `google_auth_service.dart`, `logout_helper.dart`, `user_notifier.dart`

### Admin (`Admin-Prototype/src/app/`)
- `pages/Login.tsx`, `pages/Users.tsx`, `pages/Settings.tsx`, `pages/Dashboard.tsx` (stats)
- `context/AuthContext.tsx`
- `services/api.ts` (login, logout, profile, admin users APIs)
- `components/layout/DashboardLayout.tsx`, `Sidebar.tsx`, `TopBar.tsx` (search)

## 1.3 Teeno layers kaise link hain

| Action | Frontend | Admin | Backend |
|--------|----------|-------|---------|
| Login | `POST /auth/login` | same | M1 auth |
| OTP | verify/resend | forgot-password OTP | `temp_users` + email |
| Preference | `POST /auth/user/preferences` | admin override + `targetUserId` | auth routes |
| Profile | GET/PUT `/user/profile`, avatar | Settings same user APIs | user routes |
| Users mgmt | — | GET/PUT admin users | admin routes |
| Feedback | `POST /feedback` | — | feedback routes |

## 1.4 Functionalities

- Email/password + Google Sign-In  
- OTP register / password reset (Nodemailer)  
- JWT + Redis blacklist logout  
- Exam preference (IELTS/PTE)  
- Profile, avatar (Cloudinary), theme, notif prefs, FCM token  
- Admin: user list, subscription + `unlocked_exam`, dashboard stats, global search  
- App store-style feedback (`user_app_feedback`)

## 1.5 Suggestions for Best Result

1. ~~**AuthGate** cold start pe token validate / refresh~~ → **✅ H3:** refresh + profile → Home/Preference.  
2. ~~Student passwords SharedPreferences~~ → **✅ M1:** save/read paths commented (`// This is a comment`).  
3. ~~Admin hardcoded quick-fill~~ → **✅ M1:** DEV-only via `VITE_DEV_ADMIN_*`.  
4. ~~`requireSubscription` / `onboardingMiddleware`~~ → **✅ M1:** stubbed + commented (delete nahi).  
5. ~~Admin Users pagination + Add/Delete~~ → **✅ H4:** wired.  
6. Preference-change: **✅ H4** approve queue; student direct toggle **band** — change sirf request → admin approve (by design).

## 1.6 API Response Enhancement

- **✅ M1:** Auth login `{ data: { user, accessToken, refreshToken } }` + legacy top-level (Flutter compat).  
- **✅ M1:** Error `code`: `EMAIL_EXISTS`, `OTP_EXPIRED`, `INVALID_CREDENTIALS`.  
- Profile: `subscription`, `unlocked_exam`, `preference`, `notif_prefs` (incl. **L7** quiet hours / digest flags) — document in OpenAPI stub.  
- **✅ H4/M1:** Admin users `{ data: { users, page, totalPages, total } }`.

## 1.7 Gaps / Bugs to Fix

- **✅ L10:** `passwordResetLimiter` unused — commented note in `rateLimiter.middleware.js`; forgot/reset `authLimiter` use karta hai.  
- **✅ L10:** `utils/otp.js` unused — file header comment; live OTP `temp_users` + `hashOTP`.  
- Admin `mapApiUser` role hamesha `'admin'` map karta hai — **open** (cosmetic).  
- ~~AuthGate vs journey doc~~ → **✅ H3** + journey doc sync.  
- ~~Admin Users pagination / add-delete stubs~~ → **✅ H4**.  
- ~~Hardcoded admin credentials~~ → **✅ M1** DEV guard.

---

# Module 2 — Mock Tests (Content / Test Builder)

## 2.1 Flow

```
Admin Test Builder → create/upsert nested test + assets (Cloudinary)
    → Publish
Student Mocks tab → GET mobile/dashboard → overview → GET runtime
    → DynamicTestScreen (questions) → submit (Module 4)
```

## 2.2 Files

### Backend — `M2_Test/`
- `controller/test.controller.js`, `routes/test.routes.js`, `models/test.model.js`, `validator/test.validator.js`  
- Mount: `/api/v1/content/test`

### Frontend
- `src/mocks/mocks_screen.dart`, `test_overview_screen.dart`, `dynamic_test_screen.dart`, `test_results_screen.dart`  
- Widgets: `input_engine.dart`, `matching_engine.dart`, `selection_engine.dart`, `speaking_recorder.dart`, `mock_test_card.dart`  
- Models: `runtime_question.dart`, `data/models/mock_test_model.dart`  
- Demo offline: `data/demo/demo_mock_catalog.dart`, `demo_mock_runtime.dart`  
- SQLite: `core/database/local_db.dart`

### Admin
- `pages/Mocks.tsx`, `pages/TestBuilder.tsx`  
- `context/MocksContext.tsx`  
- `services/mockTestMapper.ts`, `mockTestAssets.ts`

## 2.3 Linking

| Step | Admin | Backend | Student |
|------|-------|---------|---------|
| Create/edit | TestBuilder → create-full-test / nested | M2 | — |
| Assets | uploadTestAsset | POST mocks/assets | — |
| List | GET admin/mocks | M2 | GET mobile/dashboard |
| Take test | — | GET :id/runtime (answers stripped) | DynamicTestScreen |
| Preview | getTestById | GET :id | — |

Exam access: `subscription` + `unlocked_exam` + preference controllers mein check.

## 2.4 Functionalities

- Full nested mock (sections + questions) IELTS/PTE  
- Listening audio / Writing chart assets  
- Redis cache mobile dashboard  
- Runtime sanitization (writing/speaking correct answers hide)  
- Student entitlement gating + offline cache / demo mocks

## 2.5 Suggestions

1. ~~Test Builder Sidebar~~ → **✅ M2** link added.  
2. TestBuilder (~1600 lines) split — **optional polish** (abhi monolith).  
3. ~~Dead `fetchTests`~~ → **✅ M2** export commented + note.  
4. ~~`reading_test_model.dart`~~ → **✅ M2** legacy marked / isolated.  
5. Admin granular question APIs — use **or** comment “legacy unused” (**partial M2**).  
6. **✅ M2/H8:** Dashboard `meta.total`; error codes `EXAM_LOCKED` / `TEST_NOT_PUBLISHED` / `PREFERENCE_MISMATCH`.

## 2.6 API Response Enhancement

- Dashboard: `{ success, data: { tests: [], meta: { total, page, filters } } }`  
- Runtime: version field + `client_schema_version` for offline compatibility  
- Create/update: return full nested resource id tree for admin refresh  
- Errors: `EXAM_LOCKED`, `TEST_NOT_PUBLISHED`, `PREFERENCE_MISMATCH`

## 2.7 Gaps / Bugs

- ~~`fetchTests` routed nahi~~ → **✅ M2** commented (dead export).  
- ~~Named route `/mocks` no-op~~ → **✅ M2** opens Dashboard Mocks tab.  
- **✅ H8 — PTE `singular_module`:** section practice allowed (`reading` | `listening` | `writing` | `speaking`); uniqueness per exam+section; `full_mock` = exam simulation.  
- Demo mocks jab DB empty — FYP OK, production flag se band karo (**open**).

---

# Module 3 — Preparation (Study Content)

## 3.1 Flow

```
Admin Preparation CRUD + PDF upload
    → preparations / prep_parts / prep_media
Student Prep tab → list by exam/section → lesson detail → media/PDF open
```

## 3.2 Files

### Backend — `M3_Preparation/preparation/`
- `controller/preparation.controller.js`, `routes/preparation.routes.js`, `model/preparation.model.js`, `validator/preparation.validator.js`, `services/file.service.js`  
- Mount: `/api/v1/content/preparations`

### Frontend
- `src/prep/prep_screen.dart` + section screens (`reading/`, `writing/`, `listening/`, `speaking/`)  
- Widgets: `module_card.dart`, `media_tab_content.dart`, …

### Admin
- `pages/Preparation.tsx`

## 3.3 Linking

Admin create/update/delete/upload-pdf → same content APIs → Student GET list/lesson.  
AI tip prep hub pe `GET /ai/recommendation` (Module 6) — **✅ M3:** reading/writing AI cards API se load (static SAMPLE hata diya).

## 3.4 Functionalities

- Exam-type + section filtered lessons  
- Multi-part content + media URLs  
- PDF upload for prep materials  
- Student collapsible lesson UI

## 3.5 Suggestions

1. ~~Prep SQLite cache~~ → **✅ M3** list + lesson detail cached.  
2. ~~AI cards static~~ → **✅ M3** `/ai/recommendation`.  
3. ~~Admin endpoint labels~~ → **✅ H1** `/content/preparations/...`.  
4. Optional: short practice quizzes (Prep **Practice** tab) — abhi scope cut / plan only.

## 3.6 API Response Enhancement

- List: `{ data: { lessons, meta } }` with `section`, `test_type`, `has_pdf`  
- Lesson detail: ordered `parts[]` + `media[]` typed (`type`, `url`, `file_name`)  
- Upload PDF: **sirf** `{ success, data: { file_url, file_name } }` — Admin parser isi shape pe fix

## 3.7 Gaps / Bugs

- ~~**CRITICAL Admin PDF upload**~~ → **✅ H1** `data.file_url` + labels; **✅ H2** Flutter in-app PDF + X close.  
- `instituteOnly` form pe expose nahi — **open**.  
- ~~Prep offline cache / hardcoded fallback~~ → **✅ M3** cache + fallback commented.  
- ~~Prep AI cards SAMPLE~~ → **✅ M3** live recommendation.

---

# Module 4 — Progress (Submit Test + Results + Stats)

## 4.1 Flow

```
Student finishes DynamicTestScreen
    → (optional) POST speaking-audio
    → POST /progress/submit-test
         → objective R/L grade inline
         → writing/speaking → pending + Bull (M5)
    → GET /progress/result/:attempt_id (poll / FCM)
    → Home/Profile: GET /progress/my-stats, GET /user/results
```

## 4.2 Files

### Backend — `M4_Progress/`
- `controller/progress.controller.js`, `routes/progress.routes.js`, `models/progress.model.js`, `validator/progress.validator.js`  
- Helpers: `utils/bandScore.js`  
- Mount: `/api/v1/progress`

### Frontend
- `dynamic_test_screen.dart` (submit), `speaking_recorder.dart`  
- `test_results_screen.dart` (poll + AI display)  
- `home/widgets/progress_card.dart`, `stats_row.dart`, `skill_scores_row.dart`  
- `profile/all_tests_screen.dart`, `progress_graph.dart`  
- `core/services/offline_sync_service.dart`, `offline_audio_cache.dart`

### Admin
- **✅ M4:** `pages/Attempts.tsx` — attempt inspector (`GET /progress/result/:attempt_id` as admin).  
- Analytics/Dashboard aggregates bhi (`/admin/analytics`, `/admin/stats`).

## 4.3 Linking

Student submit → M4 DB (`test_attempts`, `user_responses`) → agar subjective → M5 worker → M6 evaluators → `ai_feedback` → M9 notify → Student results screen / All Tests.  
Admin Analytics sirf SQL aggregates dekhta hai.

## 4.4 Functionalities

- Online + offline submit (`is_offline`, 202 Accepted)  
- Speaking multipart → Cloudinary URL  
- Band / module stats / per-question review  
- `user_progress_stats` update  
- Pending AI polling (~6 min) + notification deep link

## 4.5 Suggestions

1. ~~“AI evaluating…” UX~~ → **✅ H7** copy + poll hints.  
2. ~~Home stats offline cache~~ → **✅ H7** last-known cache.  
3. ~~Attempt inspector~~ → **✅ M4** Admin `/attempts`.  
4. Idempotency keys client pe document (`client_started_at`) — **open**.

## 4.6 API Response Enhancement

- Submit: `{ success, data: { attempt_id, status: completed|pending|queued, next_poll_after_ms } }`  
- Result: stable schema `{ scores, module_stats, ai_analysis, review[] }` versioned  
- my-stats: named skills `listening|reading|writing|speaking` always present (null if none)

## 4.7 Gaps / Bugs

- ~~Progress widgets offline silently zero~~ → **✅ H7** cached stats where available.  
- ~~Speaking missing audio submit allow~~ → **✅ H7** submit **block** until record/upload.  
- ~~Admin no attempt drill-down~~ → **✅ M4** Attempts page.

---

# Module 5 — Offline Sync (Bull Queue Worker)

## 5.1 Flow

```
Student offline → SQLite offline_attempts / drafts / cached_tests
    → online → OfflineSyncService POST submit (is_offline) OR speaking upload first
Backend M5 worker (boot pe start)
    → grade + AI evaluators
    → finalize attempt
    → socket/FCM notification
    → cache bust
```

**Note:** Is module ke **HTTP routes nahi** — sirf queue + worker.

## 5.2 Files

### Backend — `M5_Offline/`
- `sync.queue.js`, `sync.worker.js`  
- Boot: `Backend/index.js` side-effect import

### Frontend
- `core/database/local_db.dart`  
- `core/services/offline_sync_service.dart`, `connectivity_service.dart`, `offline_audio_cache.dart`  
- Demo payloads for empty cache

### Admin
- Direct UI nahi (sync student-side)

## 5.3 Linking

M4 submit offline branch → enqueue M5 → M6 AI → M9 notify → Frontend sync status in All Tests (`pending/failed/synced` + retry).

## 5.4 Functionalities

- Offline mock taking + draft autosave  
- Audio prefetch for listening  
- Idempotent sync  
- Async AI hook for online subjective submits bhi isi queue se

## 5.5 Suggestions

1. ~~Redis config unify~~ → **✅ H6** shared helper (`config/redis.js`).  
2. ~~Admin queue depth~~ → **✅ L4** `GET /admin/queues/sync-tests`.  
3. ~~Student sync indicator~~ → **✅ M5** pending snackbar + Retry.  
4. Community offline drafts → **✅ M7** (SQLite + sync); prep offline alag (**M3**).

## 5.6 API Response Enhancement

- Sync/submit 202 body mein `job_id` / `queue_position` (agar possible)  
- Failed sync: structured `{ code, retryable, message }` for `retryFailedAttempts`

## 5.7 Gaps / Bugs

- ~~Redis env split~~ → **✅ H6** unified connection options.  
- `package.json` mein `redis` + `ioredis` dono — simplify note (**open**, low risk).  
- ~~Community offline~~ → **✅ M7** drafts; prep **✅ M3** cache.

---

# Module 6 — AI Evaluation & Insights (Gemini)

## 6.1 Flow

```
Writing/Speaking response
    → processors (clean) → evaluators + rubrics/prompts → Gemini JSON
    → ai_feedback / per-question fields
Also: GET recommendation, feedback-suggestion
Community create/update → moderation.service (auto flag)
Admin: POST /ai/moderate/preview (available, Admin UI unused)
```

## 6.2 Files

### Backend — `M6_AI/` (~23 files)
- Routes/controller: `ai.routes.js`, `ai.controller.js`  
- Services: `ai.service.js`, `moderation.service.js`, `performanceInsight.service.js`, `presence.service.js`  
- Evaluators: writing, speaking, reading, listening, `objective.grade.js`  
- Prompts / rubrics / processors / `utils/gemini.helper.js`  
- Config: `config/gemini.js`  
- Mount: `/api/v1/ai`

### Frontend
- Results: `test_results_screen.dart` (displays AI)  
- `home/widgets/ai_recommendation_card.dart`  
- Prep tip call + Feedback `GET /ai/feedback-suggestion`  
- Settings feedback AI suggestion box  
- **Direct** `/ai/evaluate/*` student app se zyada tar M4/M5 pipeline se hota hai

### Admin
- Community moderation **human** only  
- `POST /ai/moderate/preview` **wired nahi**

## 6.3 Linking

M4/M5 → M6 evaluators → DB → Student results.  
Home/Prep → recommendation API.  
M7 post create → M6 moderation.  
Weakness: `utils/weaknessAnalyzer.js` + performance insight.

## 6.4 Functionalities

- Writing/Speaking Gemini rubrics (JSON)  
- Reading/Listening rule-based grading  
- Study recommendations  
- App feedback text suggestions  
- Community AI moderation + admin preview endpoint  
- Redis presence (online users count)

## 6.5 Suggestions

1. Admin “AI Preview” → **intentionally NOT wired** (Gemini free quota — **✅ M6/M7** docs).  
2. Prep practice mode `/ai/evaluate/*` — **future** (Prep Practice tab plan).  
3. Folder `processors (Input Cleaning)` rename — **optional polish** (**✅ M6** README note).  
4. Rate limit + cost logging — **partial**; document in viva.  
5. **✅ M6:** Recommendation `{ data: { tip, source… } }`; fallback documented.

## 6.6 API Response Enhancement

- Evaluate endpoints: `{ success, data: { scores, criteria[], feedback, cefr, model, latency_ms } }`  
- Recommendation: `{ tip, focus_module, confidence, source: gemini|fallback }`  
- Moderation: `{ action: allow|flag|block, reasons[], scores }`

## 6.7 Gaps / Bugs

- Admin AI moderate preview unused — **by design** (cost).  
- ~~Prep AI cards static~~ → **✅ M3**.  
- ~~`FeedbackProvider.generateAISuggestion()` dead~~ → **✅ M6** commented.  
- **✅ M6:** `recommendation.prompt.js` missing — documented; uses `performanceInsight.prompt.js`.

---

# Module 7 — Community

## 7.1 Flow

```
Student Community tab
    → GET posts / create / like / comment / share
    → AI moderate on create/update
    → Socket.io /community realtime updates
Admin Community page
    → admin posts, flag/unflag, delete
```

## 7.2 Files

### Backend — `M7_Community/`
- `controller/community.controller.js`, `routes/community.routes.js`, `validator/community.validator.js`  
- Models: `post`, `comment`, `like`, `share`, `flag` — **✅ L5:** `posts.image_url`, `POST /community/upload-image`, create-post accepts `image_url`  
- Events via M9 `event.engine.js`  
- Mount: `/api/v1/community` (sab authenticated)

### Frontend
- `src/features/community/presentation/community_screen.dart` + widgets  
- Models: `community_post_model.dart`, `comment_model.dart`  
- `core/services/socket_service.dart`

### Admin
- `pages/Community.tsx`

## 7.3 Linking

Student REST + socket ↔ M7 ↔ M6 moderation ↔ M9 sockets/notifications ↔ Admin moderation + email `postFlagged`.

## 7.4 Functionalities

- Feed, topic filters, nested comments, likes, shares  
- Soft delete, flag with reason + email  
- Online users meta (Redis presence)  
- Realtime post/like/comment/removal events

## 7.5 Suggestions

1. ~~Offline draft posts~~ → **✅ M7** SQLite + sync on reconnect.  
2. Admin AI preview — **non-goal** (same as M6).  
3. ~~Bulk delete partial report~~ → **✅ M7** toast summary.  
4. ~~Image attach~~ → **✅ L5** `image_url` + `POST /community/upload-image`.  
5. Report-from-student flow — **open** (admin flag primary).

## 7.6 API Response Enhancement

- Feed: `{ data: { posts, meta: { page, totalPages, online_users } } }`  
- Create moderated: `{ status: published|under_review, moderation }`  
- Consistent like response `{ liked, like_count }`

## 7.7 Gaps / Bugs

- ~~No offline community~~ → **✅ M7** drafts.  
- ~~TOEFL filter~~ → **✅ M7** stripped — **IELTS + PTE only** (product rule).  
- Admin AI moderate unused — **by design**.  
- Dedicated Admin “Drafts inbox” UI — **optional polish** (sync backend ready).

---

# Module 8 — Payments (Stripe)

## 8.1 Flow

```
Student PremiumModal
    → GET /payments/plans
    → POST /checkout → Stripe URL (browser)
    → GET /confirm?session_id=
Webhook POST /payments/webhook (raw body, index.js)
    → update users.subscription + unlocked_exam + payment_events
Admin Subscriptions page: plans + stats (read-only)
```

## 8.2 Files

### Backend — `M8_Payment/`
- `controller/payment.controller.js`, `routes/payment.routes.js`, `models/payment.model.js`  
- `services/stripe.service.js`, `services/payment.service.js` (**✅ M8** business logic; **✅ L6** invoices + admin events)  
- Validator; webhook in `Backend/index.js`  
- Mount: `/api/v1/payments` — **L6:** `GET /payments/invoices`; admin `GET /admin/payment-events`

### Frontend
- `home/widgets/premium_modal.dart`  
- Entitlements refresh: `auth_navigation_helper.dart` → `/payments/me`

### Admin
- `pages/Subscriptions.tsx` — **✅ L6** payment-events ledger table  
- Actual grant/edit: `Users.tsx` subscription API (M1)

## 8.3 Linking

Student Stripe → M8 → users entitlements → M2/M3 access checks.  
Admin manually override subscription (M1).  
PG notify `subscription_changes` → M9 admin alerts.

## 8.4 Functionalities

- Plans: `basic_ielts`, `basic_pte`, `premium`  
- Checkout + confirm + webhook  
- `stripe_configured` flag  
- Unlock exam field for content gating

## 8.5 Suggestions

1. ~~Empty `payment.service.js`~~ → **✅ M8** extracted.  
2. `requireSubscription` — **✅ M1** commented stub (entitlements via controllers).  
3. ~~Invoice history~~ → **✅ L6** `GET /payments/invoices` + admin events.  
4. Local currency / test mode banner — **open** UX polish.

## 8.6 API Response Enhancement

- `/me`: `{ plan, unlocked_exam, renews_at, status }`  
- Checkout: `{ checkout_url, session_id }` under `data`  
- Webhook internal logging structured events for Admin “Payments log” page (future)

## 8.7 Gaps / Bugs

- ~~Empty `payment.service.js`~~ → **✅ M8**.  
- ~~Admin no payment event history~~ → **✅ L6** Subscriptions ledger.  
- Subscription middleware unused on routes — **✅ M1** intentional comment-out.

---

# Module 9 — Notifications (REST + Socket + FCM)

## 9.1 Flow

```
Events (test synced, moderation, subscription, …)
    → notification.engine → DB + Socket notification:new + FCM
Student/Admin
    → GET /notifications, unread-count, mark read, delete
Socket namespace: /community (JWT handshake)
```

## 9.2 Files

### Backend — `M9_Notification/`
- REST: routes, controller, model, `notification.service.js`  
- `engine/notification.engine.js`  
- SocketIO: `index.js`, `connection.socket.js`, `community.socket.js`, `event.engine.js`  
- `pgListener.service.js`, `socketRoom.service.js`  
- Mount: `/api/v1/notifications`  
- Firebase: `config/firebase.js`

### Frontend
- `features/notifications/presentation/notifications_screen.dart`  
- `providers/notification_provider.dart`  
- `core/services/notification_service.dart`, `fcm_token_service.dart`, `socket_service.dart`

### Admin
- `hooks/useNotifications.ts`  
- `services/socket.service.ts`, `notification.api.ts`  
- TopBar bell UI

## 9.3 Linking

M4/M5/M7/M8 events → M9 → Flutter + Admin realtime.  
FCM token via `/user/fcm-token` (M1).

## 9.4 Functionalities

- In-app inbox, unread badge, mark all read  
- Realtime socket + push  
- Prefs filter (theme/settings notif_prefs)  
- Deep links (community / all-tests)

## 9.5 Suggestions

1. ~~Response shape unify~~ → **✅ H5** `{ data: { items, unread_count } }`.  
2. Admin TopBar `deleteNotificationAPI` — **optional polish** (mark-read wired; delete abhi unused).  
3. ~~Notification types enum~~ → **✅ M9** `NOTIFICATION_TYPES.md`.  
4. ~~Quiet hours / digest~~ → **✅ L7** `notif_prefs` + FCM gate; `digestEnabled` (digest job stub/optional).

## 9.6 API Response Enhancement (IMPORTANT)

**✅ H5 shipped:** `{ success, data: { items, unread_count, meta } }` (+ legacy keys short-term).  

Har notification: `{ id, type, title, body, payload, read_at, created_at }`.

## 9.7 Gaps / Bugs

- ~~Mixed JSON keys~~ → **✅ H5** unified shape.  
- Admin delete notification unused — **optional polish** (H5 optional item).  
- Badge vs `notif_prefs` filtering — **✅ M9** documented; edge cases **open**.

---

# Cross-Cutting Module A — Shared Infrastructure

Yeh “module” folders mein M-number nahi, lekin FYP architecture ka hissa hai.

## Backend shared
- `index.js`, `config/*` (db, redis, gemini, cloudinary, firebase, socket, env)  
- **✅ L1:** `src/docs/openapi.stub.js` + routes `/api/v1/openapi.json`, `/api/docs`  
- `middleware/*` (auth, roles, rate limit, upload, errors)  
- `database/*` schema + migrations  
- `utils/*`, `email_templates/*`, mDNS advertise for LAN  
- **✅ L8:** repo root `scripts/e2e-smoke.js`

## Frontend shared
- `ApiService` (`package:http`, **no Dio**), origin resolver + mDNS  
- Provider: Theme (**✅ L3** SharedPreferences persist), Feedback, Notifications  
- Widgets chrome / drawer

## Admin shared
- `api.ts` central fetch + 401 refresh  
- Vite proxy `/api` + `/socket.io` → `:5000`  
- Layout + Sonner toasts  
- **✅ L2:** `dummyData.ts` + shadcn `components/ui/*` unused — documented in `Admin-Prototype/README.md` (design-system future)

## Suggestions
1. ~~OpenAPI / Swagger~~ → **✅ L1** `GET /api/v1/openapi.json` + `/api/docs` stub.  
2. ~~E2E smoke~~ → **✅ L8** `scripts/e2e-smoke.js`.  
3. Env example files sync (REDIS_URL vs HOST) — **partial** post-H6.  
4. Unused npm packages cleanup — **open** low priority.

---

# End-to-End Student Flow (3 folders ka milna)

```
1. Onboarding (Frontend only)
2. Auth OTP/Google (Frontend ↔ M1 ↔ Email)
3. Preference IELTS/PTE (Frontend ↔ M1)
4. Home stats + AI tip (Frontend ↔ M4 + M6)
5. Prep lessons (Admin M3 content ↔ Student)
6. Mock list/runtime (Admin M2 ↔ Student; offline M5/SQLite)
7. Submit + AI bands (M4 → M5 → M6 → M9 → Results UI)
8. Community (M7 + M6 mod + M9 socket)
9. Premium unlock (M8 Stripe ↔ entitlements ↔ M2/M3 gates)
10. Profile / All Tests / Feedback (M1 + M4 + M6 tip)
```

# End-to-End Admin Flow

```
Login (M1) → Dashboard stats (M1)
→ Users subscription unlock (M1)
→ Mocks + Test Builder (M2)
→ Preparation CRUD + PDF (M3)  [✅ H1/H2 PDF pipeline]
→ Analytics charts (M1 admin analytics)
→ Community flag/delete (M7)
→ Subscriptions overview (M8 plans + M1 stats)
→ Settings profile/theme (M1 user)
→ TopBar search + notifications (M1 search + M9)
```

---

# Priority Bugs / Gaps (FYP Demo se pehle)

**Historical P0–P3 backlog:** ✅ **Resolved** via H1–H8 + M1–M9 + L1–L10 (30 Oct 2026 session). Neeche sirf **remaining** items:

| Priority | Issue | Where | Status |
|----------|--------|--------|--------|
| — | Admin AI moderate preview | Admin Community | **Non-goal** (cost) |
| — | Preference self-serve change | M1 / Flutter | **By design** → admin approve only |
| — | TOEFL | All clients | **Removed** (M7) |
| P3 | TestBuilder monolith split | Admin | Optional polish |
| P3 | M6 processors folder rename | Backend M6 | Optional polish |
| P3 | Community Drafts dedicated Admin UI | Admin M7 | Optional polish |
| P3 | TopBar delete notification | Admin M9 | Optional polish |
| P3 | `mapApiUser` role mapping | Admin Users | Minor open |
| P3 | Prep Practice tab (AI drills) | Flutter M3/M6 | Future scope |

---

# API Response Global Enhancement Checklist

1. Har endpoint: `{ success: boolean, data?: T, message?: string, error?: { code, details } }`  
2. Lists: hamesha `meta: { page, limit, total, totalPages }`  
3. 202 async: `status` + `poll_url` / `attempt_id`  
4. Validation errors: Joi details array optional under `error.details`  
5. ~~M9 notifications `data` wrapper~~ → **✅ H5**  
6. ~~Auth tokens `data` ke andar~~ → **✅ M1** (+ legacy)  
7. Rate limit body same shape + `retry_after` — **open**

---

# Folder-wise Module Mapping Table

| # | Module | Backend | Frontend | Admin |
|---|--------|---------|----------|-------|
| 1 | Identity | M1_Identity | auth, onboarding, profile | Login, Users, Settings, Dashboard stats |
| 2 | Mock Tests | M2_Test | mocks/*, dynamic test | Mocks, TestBuilder |
| 3 | Preparation | M3_Preparation | prep/* | Preparation |
| 4 | Progress | M4_Progress | results, stats, submit | Attempts inspector + Analytics |
| 5 | Offline Sync | M5_Offline | LocalDb + OfflineSync | — |
| 6 | AI | M6_AI | results AI, tips, feedback suggestion | (moderate preview unused) |
| 7 | Community | M7_Community | community feature | Community |
| 8 | Payment | M8_Payment | PremiumModal, invoices | Subscriptions ledger (+ Users unlock) |
| 9 | Notifications | M9_Notification | notifications + FCM + socket | TopBar + useNotifications |

---

# FYP Presentation Tips (short)

- **Problem:** IELTS/PTE prep fragmented + no AI writing/speaking feedback.  
- **Solution:** Testiva = content admin + offline-capable student app + Gemini evaluation.  
- **Architecture highlight:** M1–M9 modular backend, Flutter offline-first mocks, Admin content pipeline.  
- **Demo script:** Admin create mock → Student take (airplane mode optional) → sync → AI result → Community post moderated.  
- **Honest limitations:** Admin AI preview intentionally off; Prep **Practice** drills not built; optional polish (TestBuilder split, TopBar delete notif); Gemini cost/rate limits — viva mein “non-goals + optional backlog” clear rakho.

---

**File location:** project root  
`TESTIVA_FYP_DETAILED_MODULE_REPORT_ROMAN_URDU.md`

*Yeh report codebase explore (Backend M1–M9, Flutter `lib/`, Admin-Prototype `src/app`) par based hai — **✅ L9:** last refreshed 30 Oct 2026 after H/M/L backlog.*
