# Testiva FYP — Cursor session handoff prompt

You are continuing work on **Testiva**, an AI-powered IELTS & PTE preparation FYP.

Workspace (absolute):

`d:\AndroidStudio\Projects\Testiva---AI-Powered-IELTS-and-PTE-Preparation`

Parent Cursor chat history (for context only; trust **current code** over plans):

- Parent transcript: `6f94ada3-6b22-4530-990f-26034cf6c6dc`
- Related work spans Aug–Sep 2026 (backend/frontend compare → Google auth → Figma UI → LAN/mDNS → OTP → Listening/Speaking Gemini → scoring modules → onboarding/home restore → Prep practice **plan only**).

**Do not invent features.** If something below is marked planned / not implemented, treat it as pending. Spot-check files before changing them. Do **not** edit `.cursor/plans` plan files unless the user explicitly asks. Do **not** commit unless the user explicitly asks.

---

## Product & constraints (user-insisted — never “fix” these)

| Rule | Detail |
|------|--------|
| Brand | Always **Testiva**. Figma may say “Test Prep Hub” — ignore that rename. |
| Exams | **IELTS + PTE only**. Do **not** add TOEFL (Figma has it; project does not). Filter TOEFL out of mock lists if it appears. |
| Social login | Google OK. **No Facebook login.** |
| Demo credentials | Stay **collapsed/hidden** by default on login (`DemoCredentials` expand toggle). Do not make them always-visible like Figma. |
| Drawer | Opens from the **RIGHT** (`endDrawer: CustomDrawer()`). Do not switch to left drawer to match Figma. |
| AI vendor | **Gemini Flash only** (default `gemini-2.0-flash` via `GEMINI_MODEL` / `Backend/src/config/gemini.js`). **No OpenAI, Whisper, Claude, or second AI vendor.** Speaking STT is Gemini multimodal, not Whisper. |
| Admin vs mobile | Flutter is the **student** app. Never auto-open or behave like the admin web dashboard on phone. Admins use Admin-Prototype in browser. |
| Response shape | Backend: `{ success: true, data: ... }` or `{ success: false, message: "..." }` (some older paths use `error` — prefer `message`). |

### User preferences (Roman Urdu / working style)

- User often writes in **Roman Urdu**; reply clearly (English OK; short Roman Urdu summaries help).
- Prefers **plan first, then implement** for larger Prep features.
- Cares about **Figma visual match** for onboarding/home, but product rules above beat Figma when they conflict.
- Local FYP demo: phone + PC same Wi‑Fi; backend on LAN port **5000**.

Figma Make reference (design source, not brand source of truth):

`https://www.figma.com/make/FA2eMfkUUZpW0070RHlQeo/AI-Powered-Multi-Test-Prep-Hub`  
File key: `FA2eMfkUUZpW0070RHlQeo`

---

## Stack

| Layer | Tech |
|-------|------|
| Backend | Node.js + Express (ESM), **raw SQL** via `pg` (no Prisma/Sequelize/Mongoose), Redis, Socket.io, Bull/sync workers, Cloudinary, Nodemailer, Firebase Admin (push), rate limiting |
| DB host | PostgreSQL (Supabase) |
| Admin | React + TypeScript (`.tsx`), Vite, native **`fetch`** only (no Axios) — `Admin-Prototype/` |
| Mobile | Flutter (Dart) — `frontend/`, offline-first SQLite + sync (`offline_sync_service`, local attempts `synced`/`pending`) |
| AI | `@google/generative-ai`, JSON responses preferred |

Repo skill for Backend/Admin JS/TS patterns:

`.cursor/skills/testiva-javascript/SKILL.md`

---

## Repo layout (important paths)

```
Backend/                          # Express API (port 5000)
  index.js
  src/config/gemini.js
  src/config/env.js               # loads Backend/.env by absolute path (not cwd)
  src/utils/mdnsAdvertise.js
  src/utils/bandScore.js
  src/modules/M1_Identity/        # auth, users
  src/modules/M2_Test/            # mocks / Test Builder runtime
  src/modules/M4_Progress/        # submit attempt, speaking audio upload
  src/modules/M5_Offline/         # sync worker
  src/modules/M6_AI/              # evaluators, processors, prompts, ai.service
Admin-Prototype/                  # React admin (Vite → often proxies localhost:5000)
frontend/                         # Flutter student app
```

API mount: `/api/v1`.

---

## What is already done (detailed — verified in code + Cursor sessions)

### 1) Auth & identity

- **AuthGate** (`frontend/lib/core/services/auth_gate.dart`): cold start / hot restart does **not** auto-login from saved tokens. Shows onboarding (first launch) or login until the user explicitly signs in.
- **Google Sign-In**: stuck loading overlay fixed (`google_auth_service.dart` — root navigator dialog + cleanup). Backend Google path can still fail if DB is down; errors should be clearer than bare “Google auth failed” when possible.
- **Student email/password prefill**: after student register/login/reset, credentials saved (with blocked demo/admin emails) and prefilled on login (`ApiService.saveStudentCredentials` / login form). Not “remember me auto-login”.
- **Android launcher name**: `Testiva` via `frontend/android/app/src/main/res/values/strings.xml` + manifest `@string/app_name` (was showing “frontend”).
- **OTP / email**:
  - Nodemailer + Gmail App Password (`EMAIL_USER` / `EMAIL_PASS` in `Backend/.env`).
  - `env.js` always loads `Backend/.env` by file path (fixes cwd = repo root miss).
  - Generic user message: “Could not send OTP. Please try again.”
  - On SMTP **535/EAUTH** in development (or `ALLOW_DEV_OTP=true`), can return / log **`devOtp`** so FYP is not blocked if Gmail still rejects.
  - Forgot-password `temp_users` unique-email race was addressed (delete-then-insert / normalize email).
  - **Operational note:** Gmail often returned 535 until a fresh App Password is set; code cannot invent a valid password — user must update `.env` and `cd Backend && npm run dev`.
- Preference selection (IELTS/PTE) remains part of post-auth student flow; mocks respect unlocked track.

### 2) API host discovery (LAN)

- Flutter config: `frontend/lib/core/config/app_config.dart`
  - `defaultLanApi = 'http://192.168.18.149:5000/api/v1'` (last-resort)
  - Resolution order conceptually: dart-define → last successful cache → **mDNS** → default LAN / emulator `10.0.2.2`
  - Override: `flutter run --dart-define=API_BASE=http://<LAN>:5000/api/v1`
- Backend: `Backend/src/utils/mdnsAdvertise.js` + advertise on listen in `Backend/index.js` (`bonjour-service`, `_testiva._tcp.local`, port 5000).
- Admin-Prototype still uses localhost/Vite proxy; mDNS is for the phone.

### 3) Mocks — live API (not hardcoded catalog as primary)

- Mobile dashboard loads from backend: `GET /content/test/mobile/dashboard` (and related test APIs).
- Demo/static catalog is **fallback** when API fails / empty — not the primary path when backend is healthy.
- Starting a mock hits **runtime** API (`getTestRuntime`).
- **Free-tier runtime no longer strips listening/speaking** — runtime returns published structure with listening audio inheritance (`inheritListeningAudio` copies first section `audio_url` onto questions missing one). Cache keys still mention free/basic/premium historically; do not re-introduce stripping without user ask.
- Listening: Admin uploads audio → Cloudinary HTTPS URL on questions → Flutter plays via audio players in dynamic test.
- Speaking: student records in-app (`speaking_recorder.dart`) → upload speaking audio (`progress` speaking upload → Cloudinary) → submit → Gemini **STT** (`speaking.processor.js`) + evaluation with **question text + cue card** in prompt (`speakingEvaluation.prompt.js` / `speaking.evaluator.js`).
- Flutter player: module hint banners per skill (`_buildModuleHint` in `dynamic_test_screen.dart`).
- Results UI: skill cards / `SkillScoresRow` on **test results** (`test_results_screen.dart`) — **not** on Home.

### 4) Scoring / AI evaluation architecture (M6 + band tables)

| Module | How scored | Key files |
|--------|------------|-----------|
| Reading | Objective mark vs answer key → Academic-style band table | `objective.grade.js`, `reading.evaluator.js`, `bandScore.js` |
| Listening | Same objective + Listening band table (no Gemini for marking) | `listening.evaluator.js`, `bandScore.js` |
| Writing | Gemini JSON → **post-process** rules (word-count caps, criteria avg) | `writing.evaluator.js`, `writing.logic.js` (`scoreWritingFromModel`) |
| Speaking | Gemini STT then Gemini band JSON vs question+cue | `speaking.processor.js`, `speaking.evaluator.js`, `ai.service.js` |

- Submit path: `M4_Progress` `submitTest` grades objective sections, may mark writing/speaking pending while AI/sync worker finishes; results payload includes `moduleStats` with pending flags.
- Gemini config: `Backend/src/config/gemini.js` — `GEMINI_MODEL` or default `gemini-2.0-flash`, JSON mime type.

### 5) Admin panel

- **TestBuilder**: listening requires real audio (pending file **or** HTTPS URL). Filename-only is invalid for publish. Audio **preview** player when blob or `https://` URL present (`TestBuilder.tsx`, assets helper `mockTestAssets.ts`).
- **Dashboard**: module explainer cards for Reading / Listening / Writing / Speaking (`Dashboard.tsx`).
- Auth/settings pages were touched in session (login/settings polish) — preserve Testiva branding.

### 6) Flutter UI (Figma-aligned where allowed)

- Inter fonts; onboarding logos/icons for Personalized Learning / AI-Powered Mocks / Start Free Today; stats copy corrected toward Figma (“5K+ students”, “7.5 avg band” style — verify `onboarding_stats.dart` if editing).
- Home Daily Tips icons matched to Figma (book, headphones, pencil, speaking).
- Home stat cards layout matched (icon left + value/labels).
- Drawer remains right-side.

### 7) Onboarding & Home — **current restored state** (important)

Briefly during “status UI” work, agents added:

- A 4th onboarding slide / **OnboardingDashboardPreview**
- **HomeSkillScores** / “Latest skill bands” on Home

User rejected that. **Restored** to:

- **Onboarding**: 3 slides + header + icon boxes + dots + `OnboardingStats` + Get Started + Continue as Guest → `AuthScreen` (Figma-style). Guest is **not** a full guest dashboard shortcut in the restored flow.
- **Home**: `HeaderSection` → `ProgressCard` → `StatsRow` → `QuickActionsGrid` → `AIRecommendationCard` → `DailyTipsList`. **No skill bands on Home.**
- Deleted unused `onboarding_dashboard_preview.dart` if present.
- Keep `skill_scores_row.dart` for **results** screen only.

### 8) Prep (Lessons + Media exist; Practice NOT built)

- Prep hub: Speaking / Listening / Reading / Writing module cards.
- Each details screen: **Lessons** + **Media** tabs fed by `/content/preparations` APIs (e.g. `speaking_details_screen.dart`).
- **Practice tab / “speak and show mistakes” AI drills: NOT implemented.** Only explained to the user (plan below). Wait for explicit approval before coding.

### 9) Offline

- SQLite local attempts + sync flags; profile “all tests” can show offline pending / synced. Sync worker exists under `M5_Offline`. Treat as partial but real — don’t rip out.

### 10) Early session context

- Initial backend↔Flutter compare (Aug): core auth/mocks/prep/community wired; some AI endpoints were underused then — **later sessions wired listening/speaking/scoring more fully**. Prefer current M6/progress code over that old gap report.

---

## What was intentionally reverted / out of scope

**Reverted / do not re-add without asking:**

- Onboarding “Your Home Dashboard” preview slide
- Home “Latest skill bands” / HomeSkillScores
- Left-side drawer
- Brand rename to Test Prep Hub
- TOEFL
- Facebook login
- Always-visible demo credentials
- OpenAI / Whisper / Claude

**Not done / incomplete (do not claim done):**

- **Prep Practice** (third tab: Speak/Listen/Read/Write drills + show mistakes) — plan only; user asked “pehle btao kesy hoga” then will approve Speaking first.
- Guest limited-mocks polish (guest flow still mostly AuthScreen-oriented after restore).
- Admin **Analytics** page exists but may still lean on dummy/incomplete live metrics.
- **Stripe** / subscriptions: partial (admin mentions Stripe Checkout in mobile; billing ledger/CSV called out as outside MVP).
- Perfect pixel-match of every Figma screen (home/login/onboarding got the most attention; others vary).
- Guaranteed Gmail OTP delivery without a valid App Password in `.env`.

---

## Current known gaps / next requested work

### Highest priority (user’s last product ask — pending approval)

Implement Prep **Practice** after user confirms the plan, starting with **Speaking**:

1. Prep → module → keep Lessons | Media  
2. Add **Practice** tab/CTA  
3. Short drills (not full mocks)  
4. Speaking: record → upload → Gemini STT + feedback/mistakes UI  
5. Then Writing (Gemini corrections)  
6. Then Reading/Listening (objective + light tips)

Reuse existing mock speaking upload + AI evaluate paths where possible; don’t duplicate a second AI stack.

### Other sensible follow-ups (only if asked)

- Harden OTP with a working Gmail App Password; document `ALLOW_DEV_OTP` for demos.
- Guest mock limits UX.
- Analytics live data.
- More Figma alignment on Prep / Mocks / Community.
- Ensure published admin mocks always have HTTPS listening audio before students attempt.

---

## How to run

```powershell
# Backend (from repo)
cd d:\AndroidStudio\Projects\Testiva---AI-Powered-IELTS-and-PTE-Preparation\Backend
npm run dev
# Expect: Testiva Engine Online, Port 5000, Redis + PostgreSQL connected, mDNS advertise

# Admin
cd d:\AndroidStudio\Projects\Testiva---AI-Powered-IELTS-and-PTE-Preparation\Admin-Prototype
npm run dev

# Flutter
cd d:\AndroidStudio\Projects\Testiva---AI-Powered-IELTS-and-PTE-Preparation\frontend
flutter run
# Optional: --dart-define=API_BASE=http://YOUR_LAN_IP:5000/api/v1
```

Env (Backend/.env — never commit secrets):

- `DB_*`, Redis, `JWT`/`secrets`, `GEMINI_API_KEY`, `GEMINI_MODEL` (optional)
- `EMAIL_USER`, `EMAIL_PASS` (Gmail App Password)
- Optional: `ALLOW_DEV_OTP=true` for FYP when SMTP fails
- Cloudinary credentials for audio/image uploads

Phone and PC must share Wi‑Fi; campus AP isolation can block LAN/mDNS — then use dart-define IP.

---

## Coding rules to follow

1. Follow stack rules above (raw SQL, fetch, Gemini Flash only).
2. Read `.cursor/skills/testiva-javascript/SKILL.md` before Backend/Admin JS/TS edits.
3. Preserve user product constraints (Testiva, no TOEFL, right drawer, hidden demo creds, no Facebook).
4. Prefer minimal diffs; don’t drive-by refactor.
5. Don’t reintroduce Home skill bands or onboarding dashboard preview.
6. Don’t implement Prep Practice until the user explicitly says to start (prefer Speaking first).
7. Don’t commit unless asked; don’t force-push; don’t edit plan markdown in `.cursor/plans`.
8. Uniform API responses; parameterized SQL; try/catch with clear messages.
9. For Figma → code, use Figma MCP skills (`figma-design-to-code` before `get_design_context`).

---

## Quick “where to look” map

| Concern | Start here |
|---------|------------|
| Gemini model | `Backend/src/config/gemini.js` |
| Submit + speaking upload | `Backend/src/modules/M4_Progress/controller/progress.controller.js` |
| AI orchestration | `Backend/src/modules/M6_AI/services/ai.service.js` |
| Runtime mocks | `Backend/src/modules/M2_Test/controller/test.controller.js` |
| Band tables | `Backend/src/utils/bandScore.js` |
| Admin audio | `Admin-Prototype/src/app/pages/TestBuilder.tsx` |
| Flutter test player | `frontend/lib/src/mocks/dynamic_test_screen.dart` |
| Speaking UI | `frontend/lib/src/mocks/widgets/speaking_recorder.dart` |
| Results skill cards | `frontend/lib/src/mocks/test_results_screen.dart` |
| Onboarding / Home | `frontend/lib/src/onboarding/onboarding_screen.dart`, `.../home/home_page.dart` |
| Prep modules | `frontend/lib/src/prep/` |
| API base / mDNS | `frontend/lib/core/config/app_config.dart`, `Backend/src/utils/mdnsAdvertise.js` |
| Auth gate | `frontend/lib/core/services/auth_gate.dart` |

---

## Suggested first message after pasting this prompt

Tell the new agent exactly what you want next, for example:

- “Implement Prep Speaking Practice (Lessons | Media | Practice) using existing Gemini STT + evaluate — do not touch Home/Onboarding.”  
- or “Fix OTP so Gmail actually sends — verify EMAIL_PASS / ALLOW_DEV_OTP.”  
- or “Polish guest mocks / Analytics / Stripe” as separate scoped tasks.

End of handoff.
