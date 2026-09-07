# Testiva Student App — First-Time Journey (User Side)

> **Audience:** Student / learner opening the Flutter app for the first time.  
> **Scope:** What the user sees and gets, step by step, plus which files power each step.  
> **App package root:** `frontend/lib/`  
> **Last aligned with codebase:** 2026-09-06

---

## How to read this document

- Steps are ordered as a **brand-new user** experiences them (no saved tokens).
- Each section has:
  - **What the student gets** (bullets)
  - **What happens under the hood** (short)
  - **Files used** (Flutter paths; APIs where relevant)

---

## 0) App cold start (before any UI content)

When the student taps the Testiva icon, Flutter boots services **before** the first screen.

### What the student gets
- Brief loading spinner (white / themed scaffold)
- No login form yet — session check runs first

### Under the hood
1. Bind Flutter widgets
2. Start connectivity watcher
3. Open local SQLite DB (offline mocks / sync)
4. Init offline sync service
5. Clear any legacy remembered plaintext password
6. Mount providers: theme, feedback, notifications
7. Route `/` → `AuthGate`

### Files used
| Role | Path |
|------|------|
| Entry | `frontend/lib/main.dart` |
| API base URL | `frontend/lib/core/config/app_config.dart` |
| HTTP + tokens | `frontend/lib/core/services/api_service.dart` |
| Session gate | `frontend/lib/core/services/auth_gate.dart` |
| Local SQLite | `frontend/lib/core/database/local_db.dart` |
| Offline sync | `frontend/lib/core/services/offline_sync_service.dart` |
| Connectivity | `frontend/lib/core/services/connectivity_service.dart` |
| Theme provider | `frontend/lib/providers/theme_provider.dart` |
| Feedback provider | `frontend/lib/providers/feedback_provider.dart` |
| Notification provider | `frontend/lib/providers/notification_provider.dart` |
| Brand colors | `frontend/lib/core/constants/app_colors.dart` |

### First-time vs returning user at AuthGate
| Condition | Destination |
|-----------|-------------|
| No access token | **Onboarding** (this doc’s path) |
| Valid token + profile + preference | Dashboard |
| Valid token + no preference | Preference selection |
| Token invalid / refresh fails | Clear session → Onboarding |

**Files:** `auth_gate.dart`, `auth_navigation_helper.dart`, `user_notifier.dart`

---

## 1) Onboarding (first screen a new student sees)

**Route:** `/onboarding` (also shown directly from AuthGate)

### What the student gets
- Testiva branding header
- Auto-rotating value props (every ~3s):
  1. **Personalized Learning** — AI study focus from mock performance
  2. **AI-Powered Mocks** — IELTS & PTE mocks + instant AI feedback
  3. **Start Free Today** — social proof messaging
- Page dots for the 3 slides
- Stats strip (marketing numbers UI)
- Primary CTA: **Get Started** → Auth screen

### Under the hood
- Pure UI; no API call on this screen
- “Get Started” pushes `AuthScreen` (defaults to Login tab)

### Files used
| Role | Path |
|------|------|
| Screen | `frontend/lib/src/onboarding/onboarding_screen.dart` |
| Header | `frontend/lib/src/onboarding/widgets/onboarding_header.dart` |
| Stats | `frontend/lib/src/onboarding/widgets/onboarding_stats.dart` |
| Next screen | `frontend/lib/src/auth/auth_screen.dart` |

---

## 2) Auth hub (Login / Sign up)

**Widget:** `AuthScreen`

### What the student gets
- Back button → returns to onboarding
- Brand mark (logo + name)
- Header that switches copy for Login vs Sign up
- Toggle: **Login** | **Sign up**
- Form area for the selected mode
- Google sign-in entry on forms

### Files used
| Role | Path |
|------|------|
| Shell | `frontend/lib/src/auth/auth_screen.dart` |
| Header | `frontend/lib/src/auth/login/widgets/login_header.dart` |
| Toggle | `frontend/lib/src/auth/login/widgets/auth_toggle.dart` |
| Brand | `frontend/lib/widgets/brand_mark.dart` |
| Login form | `frontend/lib/src/auth/login/widgets/login_form.dart` |
| Signup form | `frontend/lib/src/auth/signup/widgets/signup_form.dart` |
| Google button | `frontend/lib/src/auth/login/widgets/google_button.dart` |
| Google service | `frontend/lib/core/services/google_auth_service.dart` |
| Shared fields / buttons | `frontend/lib/widgets/custom_textfield.dart`, `frontend/lib/widgets/app_button.dart` |
| Validators | `frontend/lib/core/utils/validators.dart` |

---

## 3) First-time registration path (Sign up)

Assume student chooses **Sign up**.

### What the student gets
- Fields: Full name, Email, Password, Confirm password
- Optional “remember email”
- Show/hide password
- Submit → success snackbar: OTP sent to email
- Navigates to **OTP screen**

### APIs
- `POST /auth/register`  
  body: `full_name`, `email`, `password`, `confirm_password`

### Files used
| Role | Path |
|------|------|
| Form + API | `frontend/lib/src/auth/signup/widgets/signup_form.dart` |
| OTP next | `frontend/lib/src/auth/signup/otp_screen.dart` |
| HTTP | `frontend/lib/core/services/api_service.dart` |

### Alternate: Login (returning / already registered)
- Email + password → `POST /auth/login`
- On success → tokens saved → `AuthNavigationHelper.navigateAfterAuth`
  - Has preference → Dashboard
  - No preference → Preference selection
- Forgot password flow available from login UI

| Role | Path |
|------|------|
| Login | `frontend/lib/src/auth/login/widgets/login_form.dart` |
| Forgot password | `frontend/lib/src/auth/forgot_password/forgot_password_screen.dart` |
| Forgot OTP | `frontend/lib/src/auth/forgot_password/otp_screen.dart` |
| Reset password | `frontend/lib/src/auth/forgot_password/reset_password_screen.dart` |
| Post-auth nav | `frontend/lib/core/services/auth_navigation_helper.dart` |

---

## 4) Email OTP verification

**Screen:** Signup `OtpScreen`

### What the student gets
- Masked email display
- 4-digit OTP boxes
- Countdown timer (~50s) then expire state
- **Resend OTP** when expired / allowed
- Verify → on success, auto-login with saved password (if present), then jump to **exam preference**

### APIs
- `POST /auth/verify-otp` — `{ email, otp, type: "register" }`
- `POST /auth/resend-otp` — `{ email, type: "register" }`
- `POST /auth/login` — silent login after verify (when password was carried from signup)
- Tokens persisted via `ApiService.persistAuthResponse`

### Files used
| Role | Path |
|------|------|
| OTP UI + logic | `frontend/lib/src/auth/signup/otp_screen.dart` |
| User memory | `frontend/lib/core/services/user_notifier.dart` |
| Token persist | `frontend/lib/core/services/api_service.dart` |

### Note on Email Verified screen
- Route `/email-verified` + `EmailVerifiedScreen` exist (celebration UI → preference).
- **Current signup success path** from OTP goes **directly** to `/select-preference` (skips celebration screen).
- File still part of product surface: `frontend/lib/src/auth/signup/email_verified_screen.dart`

---

## 5) Exam preference selection (IELTS vs PTE)

**Route:** `/select-preference`  
**Required once** before Home for new accounts.

### What the student gets
- Personalized greeting with their name
- Choice cards: **IELTS** or **PTE**
- Must pick one to continue
- Save → welcome snackbar → **Dashboard (Home)**

### APIs
- `POST /auth/user/preferences` — `{ preference: "IELTS" | "PTE" }`
- Response may refresh tokens/user; persisted locally

### Files used
| Role | Path |
|------|------|
| Screen | `frontend/lib/src/auth/signup/preference_selection_screen.dart` |
| Nav after save | `frontend/lib/core/services/auth_navigation_helper.dart` |
| User state | `frontend/lib/core/services/user_notifier.dart` |

### Why this matters later
- Home quick actions, Prep modules, Mocks filter, Community title, AI recommendation `exam_type` all follow this preference (and any later `unlocked_exam` / premium).

---

## 6) Dashboard shell (main app after first login)

**Route:** `/home` / `/dashboard`  
**Widget:** `DashboardScreen`

### What the student gets
- Bottom navigation with **5 tabs**:
  1. **Home**
  2. **Mocks**
  3. **Prep**
  4. **Community**
  5. **Profile**
- Side **drawer** (hamburger from headers)
- Background: profile refresh; if preference missing → force preference screen
- Notifications provider initializes
- Offline sync completion snackbar when queued tests upload

### Files used
| Role | Path |
|------|------|
| Shell + tabs | `frontend/lib/src/dashboard/dashboard_screen.dart` |
| Drawer | `frontend/lib/widgets/custom_drawer.dart` |
| Logout dialog | `frontend/lib/widgets/logout_dialog.dart` |
| Notifications init | `frontend/lib/providers/notification_provider.dart` |
| Offline callback | `frontend/lib/core/services/offline_sync_service.dart` |

---

## 7) Tab 1 — Home (first dashboard view)

**Widget:** `HomePage`

### What the student gets (top → bottom)
- **Header** — greeting, menu, notifications entry
- **Progress card** — overall progress from live stats (new user ≈ empty / 0)
- **Stats row** — band / activity summary chips
- **Quick Actions** — start mock, prep tracks, premium locks based on subscription / unlock
- **AI Recommendation card** — live tip from Gemini-backed API (or fallback sample)
- **Daily tips list** — static sample study tips (not API)

### APIs
- `GET /progress/my-stats` — progress card / stats
- `GET /ai/recommendation?exam_type=...` — AI focus card
- Profile already synced via dashboard / AuthGate

### Files used
| Role | Path |
|------|------|
| Home layout | `frontend/lib/src/dashboard/home/home_page.dart` |
| Header | `frontend/lib/src/dashboard/home/widgets/header_section.dart` |
| Progress | `frontend/lib/src/dashboard/home/widgets/progress_card.dart` |
| Stats | `frontend/lib/src/dashboard/home/widgets/stats_row.dart` |
| Quick actions | `frontend/lib/src/dashboard/home/widgets/quick_actions_grid.dart` |
| Premium unlock UI | `frontend/lib/src/dashboard/home/widgets/premium_modal.dart` |
| AI recommendation | `frontend/lib/src/dashboard/home/widgets/ai_recommendation_card.dart` |
| Daily tips (sample) | `frontend/lib/src/dashboard/home/widgets/daily_tips_list.dart` |
| App header shared | `frontend/lib/widgets/app_header.dart` |

### First-time Home reality check
- Progress ~ **0** (no completed mocks yet)
- AI recommendation may use **fallback** text until enough history exists
- Daily tips are **sample** marketing tips
- Free user may see **locks** on the other exam track → Premium modal / Stripe checkout

---

## 8) Tab 2 — Mocks

**Widget:** `MocksScreen`

### What the student gets
- List of available mock tests for their access level
- Filters (e.g. All / by type)
- Cards → overview → take test (dynamic runtime)
- Offline: cache dashboard / runtime when online; submit later when reconnected
- Access rules: preference track free; other exam / full suite needs unlock or premium

### Key flows from here
1. Tap mock → `TestOverviewScreen`
2. Start → `DynamicTestScreen` (questions runtime)
3. Submit → progress API (+ AI eval queue for writing/speaking)
4. Results → `TestResultsScreen`
5. History later → Profile → All Tests

### APIs (typical)
- `GET /content/test/mobile/dashboard` (and related available/runtime endpoints)
- `POST /progress/submit-test`
- Local cache: `LocalDb`

### Files used
| Role | Path |
|------|------|
| List | `frontend/lib/src/mocks/mocks_screen.dart` |
| Card | `frontend/lib/src/mocks/widgets/mock_test_card.dart` |
| Overview | `frontend/lib/src/mocks/test_overview_screen.dart` |
| Runtime test | `frontend/lib/src/mocks/dynamic_test_screen.dart` |
| Results | `frontend/lib/src/mocks/test_results_screen.dart` |
| Runtime models | `frontend/lib/src/mocks/models/runtime_question.dart` |
| Answer engines | `frontend/lib/src/mocks/widgets/input_engine.dart`, `selection_engine.dart`, `matching_engine.dart` |
| Model | `frontend/lib/data/models/mock_test_model.dart` |
| Offline DB | `frontend/lib/core/database/local_db.dart` |
| Sync | `frontend/lib/core/services/offline_sync_service.dart` |

### First-time note
- Speaking section may still be skipped in runtime UI (`_skipSections`); writing AI eval runs when essays are submitted.
- Backend Gemini STT is ready when audio URLs are sent later.

---

## 9) Tab 3 — Prep

**Widget:** `PrepScreen`

### What the student gets
- Track toggle follows preference (IELTS / PTE)
- Module cards: Reading / Writing / Listening / Speaking lessons from API
- AI tip strip (recommendation API + local tip pool)
- Open module → detail screens with tips / media / lesson content
- Some “AI tip” widgets inside reading/writing details are still **sample UI**

### APIs
- `GET /content/preparations?...`
- `GET /ai/recommendation?exam_type=...`

### Files used
| Role | Path |
|------|------|
| Prep hub | `frontend/lib/src/prep/prep_screen.dart` |
| Module card | `frontend/lib/src/prep/widgets/module_card.dart` |
| Prep header / segments | `frontend/lib/src/prep/widgets/prep_header.dart`, `prep_segmented_control.dart` |
| Reading detail | `frontend/lib/src/prep/reading/...` |
| Writing detail | `frontend/lib/src/prep/writing/...` |
| Listening detail | `frontend/lib/src/prep/listening/...` |
| Speaking detail | `frontend/lib/src/prep/speaking/...` |
| Model | `frontend/lib/data/models/prep_module_model.dart` |
| Premium gate | `frontend/lib/src/dashboard/home/widgets/premium_modal.dart` |

---

## 10) Tab 4 — Community

**Widget:** `CommunityScreen`

### What the student gets
- Title like “{IELTS|PTE} Community”
- Online users count (socket + API)
- Topic filter chips (All / IELTS / PTE / General)
- Feed of **clean** posts only (AI/admin shadow-flagged posts hidden)
- Create post FAB → title, content, topic
  - If Gemini moderation flags → orange snackbar “under review”; post **not** shown in feed
  - If clean → appears in feed (and via socket)
- Open comments → post comment (same shadow-flag rules)
- Like / share

### APIs / realtime
- `GET /community/get-posts`
- `POST /community/create-post`
- `GET|POST /community/:postId/comments`
- `POST /community/toggle-post-like/:postId`
- `GET /community/meta/online-users`
- Socket events: `post_created`, `post_like_updated`, `comment_created`, `post:removed`, `online_count`

### Files used
| Role | Path |
|------|------|
| Screen | `frontend/lib/src/features/community/presentation/community_screen.dart` |
| Post card | `.../widgets/community_post_card.dart` |
| Filters | `.../widgets/community_filter_chips.dart` |
| Comments sheet | `.../widgets/comments_bottom_sheet.dart` |
| Models | `frontend/lib/data/models/community_post_model.dart`, `comment_model.dart` |
| Socket | `frontend/lib/core/services/socket_service.dart` |

### Backend logic (for sync understanding)
- Shadow-flag moderation: `Backend/src/modules/M6_AI/services/moderation.service.js`
- Community controllers/models: `Backend/src/modules/M7_Community/...`
- Admin review UI: `Admin-Prototype/src/app/pages/Community.tsx`

---

## 11) Tab 5 — Profile

**Widget:** `ProfileScreen`

### What the student gets
- Avatar / name / email / Free vs Premium
- Stats + progress graph
- Preference display + request change (other exam)
- Edit profile modal
- Link to **All Tests** (attempt history + offline attempts)
- Support / feedback entry
- Logout

### APIs
- `GET /user/profile`
- `GET /user/results` (All Tests)
- Preference change request endpoint
- Avatar / password update endpoints as implemented in modals

### Files used
| Role | Path |
|------|------|
| Profile | `frontend/lib/src/profile/profile_screen.dart` |
| Header | `frontend/lib/src/profile/widgets/profile_header.dart` |
| Edit modal | `frontend/lib/src/profile/widgets/edit_profile_modal.dart` |
| Preference tiles | `frontend/lib/src/profile/widgets/preference_tiles.dart` |
| Progress graph | `frontend/lib/src/profile/widgets/progress_graph.dart` |
| Support | `frontend/lib/src/profile/widgets/support_section.dart` |
| All tests | `frontend/lib/src/profile/all_tests_screen.dart` |
| Logout | `frontend/lib/widgets/logout_dialog.dart`, `frontend/lib/core/services/logout_helper.dart` |

---

## 12) Drawer + secondary surfaces (reachable anytime after login)

### Drawer items the student sees
- Dashboard Home
- Exam Prep Track
- Mock Exams Engine
- My Profile Metrics
- Settings Options (currently routes to Profile)
- Feedback Support
- Notifications (with unread badge)
- Logout

### Files
- `frontend/lib/widgets/custom_drawer.dart`
- Notifications: `frontend/lib/src/features/notifications/presentation/notifications_screen.dart`
- Feedback: `frontend/lib/src/features/settings/presentation/feedback_screen.dart` (+ AI suggestion box)
- Theme toggle via `ThemeProvider` / settings-related UI

### Notifications
- In-app list + unread counts
- Socket / FCM plumbing via `notification_service.dart` + provider
- Can deep-link into All Tests after mock AI evaluation finishes

---

## 13) Payments / unlock (when student hits a lock)

### What the student gets
- Premium modal from Home quick actions / Prep gates
- Plans for IELTS / PTE / Premium
- Checkout via Stripe backend; confirm unlock → refresh user access

### Files / APIs
- UI: `frontend/lib/src/dashboard/home/widgets/premium_modal.dart`
- APIs: `GET /payments/plans`, `POST /payments/checkout`, `POST /payments/confirm`, `GET /payments/me`
- Backend: `Backend/src/modules/M8_Payment/...`

---

## End-to-end first-time happy path (checklist)

```text
Open app
  → AuthGate (no token)
  → Onboarding (3 slides) → Get Started
  → AuthScreen → Sign up
  → Register API → OTP screen
  → Verify OTP → (auto login) → Preference IELTS/PTE
  → Dashboard Home
       ├─ empty progress
       ├─ AI recommendation (live or fallback)
       ├─ Quick actions → Mocks / Prep
       ├─ Community (empty or existing clean posts)
       └─ Profile (Free Member)
```

---

## Master file map (first-time critical path only)

```text
main.dart
 └─ AuthGate
     └─ OnboardingScreen
         └─ AuthScreen
             ├─ SignupForm  → POST /auth/register
             └─ OtpScreen   → POST /auth/verify-otp (+ login)
                 └─ PreferenceSelectionScreen → POST /auth/user/preferences
                     └─ DashboardScreen
                         ├─ HomePage (+ AI / progress / premium)
                         ├─ MocksScreen
                         ├─ PrepScreen
                         ├─ CommunityScreen
                         └─ ProfileScreen
```

### Shared always-on services
- `api_service.dart` — all HTTP
- `user_notifier.dart` — in-memory user snapshot
- `auth_navigation_helper.dart` — post-login routing + notifier sync
- `local_db.dart` + `offline_sync_service.dart` — offline mocks
- `socket_service.dart` — community + realtime
- `app_theme.dart` / `theme_provider.dart` — light/dark

---

## What a brand-new student does *not* have yet

- No band history / weak-section data (AI tips may fall back)
- No completed mocks in All Tests
- Free tier: likely only preferred exam unlocked (unless admin granted unlock)
- Speaking recording UX may be limited even though backend Gemini STT exists
- Prep reading/writing “AI tip” cards may still show sample content
- Study-plan / practise modules were removed from backend product surface

---

## Related backend modules (student journey dependencies)

| Student need | Backend module |
|--------------|----------------|
| Register / OTP / login / preference | `M1_Identity` |
| Mocks content | `M2_Test` |
| Prep lessons | `M3_Preparation` |
| Submit + stats + results | `M4_Progress` |
| Offline job grading | `M5_Offline` |
| Writing/speaking AI, recommendation, community moderation | `M6_AI` |
| Community feed | `M7_Community` |
| Unlock / Stripe | `M8_Payment` |
| Notifications | `M9_Notification` |

---

*Document generated for Testiva FYP student-app walkthrough. Update this file when auth or dashboard flows change.*
