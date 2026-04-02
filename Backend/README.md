🎯 PROJECT MASTER PROMPT (FYP – TESTIVA)
🧾 SUMMARY
We are developing a Final Year Project named “Testiva – AI-Powered IELTS & PTE Test Preparation Mobile Application”.
The system is designed as a B2C platform targeting Pakistani students who cannot afford expensive coaching academies.
The application provides structured preparation modules, realistic mock tests, and AI-powered feedback for Writing and Speaking sections. The backend is built using Node.js (Express) and PostgreSQL, with AI integrations (OpenAI/Gemini + Deepgram).
📖 DESCRIPTION
Testiva solves two major problems:

High cost of IELTS/PTE preparation (Rs. 25,000–60,000)
Lack of personalized feedback in self-study
The system includes:

Reading, Writing, Listening, Speaking modules
AI-powered Writing evaluation (grammar, coherence, band score)
AI-powered Speaking evaluation (speech-to-text + fluency analysis)
Mock test engine with scoring
Offline mode with sync capability
Role-based system (Admin, Premium User, Free User)
Freemium subscription model
🎯 PRIMARY GOALS
Develop a mobile application for IELTS & PTE preparation
Integrate AI for Writing and Speaking evaluation
Implement intelligent scoring and feedback system
Build mock test system with performance tracking
Provide offline access with synchronization
Implement role-based access control (Admin / Premium / Free)
Create admin panel for content and user management
🏗️ BACKEND TECHNOLOGY STACK
Node.js with Express.js
PostgreSQL (pgAdmin4)
Redis (caching)
Deepgram (Speech-to-Text)
OpenAI / Gemini (AI evaluation)
Cloudinary (media storage)
📁 FULL FEATURE-BASED FOLDER STRUCTURE (BACKEND)
src/
├── config/
├── database/
├── middleware/
├── modules/
│ ├── auth/
│ ├── user/
│ ├── admin/
│ ├── content/
│ ├── test/
│ ├── ai/
│ ├── progress/
│ ├── subscription/
│ ├── payment/
│ ├── offline/
│ ├── community/
├── utils/
├── validators/
├── uploads/
Each module follows:

controller → handles request/response
service → business logic
model → database queries
routes → API endpoints
validator → request validation
🚀 SELECTED MVP MODULES (DEADLINE: 26 MAY – 60% COMPLETION)
⚠️ IMPORTANT:
Follow STRICT ORDER. Each module depends on the previous one.
After completing each module:
👉 Test APIs in Postman before moving forward.
1️⃣ AUTH MODULE (START HERE)
Includes:
Register (email/password)
Login (JWT)
Google OAuth login
Password hashing
Role assignment (default: free)
Dependency:
None (base module)

After Completion:
✅ Test login/register via Postman
✅ Verify JWT token generation
2️⃣ USER MODULE
Includes:
Get user profile
Update profile
Role handling (admin/premium/free)
Dependency:
Auth module

After Completion:
✅ Fetch logged-in user
✅ Verify role-based access
3️⃣ ADMIN MODULE (CRITICAL FOR VIVA)
Includes:
Admin login
Dashboard APIs
Manage users (change roles)
Manage content (basic control)
Dependency:
Auth + User module

After Completion:
✅ Change user role (free → premium → admin)
✅ Verify access control working
4️⃣ CONTENT MODULE (READING SYSTEM BASE)
Includes:
CRUD Lessons
CRUD Questions (Reading)
Dependency:
Admin module (content created by admin)

After Completion:
✅ Admin creates questions
✅ API returns questions correctly
5️⃣ TEST MODULE (CORE ENGINE)
Includes:
Create mock tests
Start test session
Submit answers
Store attempts
Sections Covered:
Reading (basic MCQs)
Writing (text input)
Speaking (audio upload)
Dependency:
Content module

After Completion:
✅ User attempts test
✅ Answers stored in DB
6️⃣ AI MODULE (MAIN FEATURE 🚀)
Includes:
Writing evaluation (real AI)
Speaking evaluation (real/semi-dummy)
Band score calculation
Feedback generation
Flow:
Writing → AI → Feedback
Speaking → Audio → STT → AI → Feedback
Dependency:
Test module

After Completion:
✅ Writing response → AI feedback
✅ Speaking audio → text → feedback
7️⃣ PROGRESS MODULE
Includes:
Track user performance
Store band scores
Analytics (basic)
Dependency:
Test + AI modules

After Completion:
✅ Show user progress
✅ Band score history
8️⃣ SUBSCRIPTION MODULE (DUMMY)
Includes:
Free vs Premium access
Upgrade logic (no real payment needed)
Dependency:
User module

After Completion:
✅ Restrict premium content
✅ Upgrade user manually
9️⃣ OFFLINE SYNC MODULE (INNOVATION FEATURE ⭐)
Includes:
Store test attempts locally
Sync when internet is available
Queue system
Dependency:
Test + Progress modules

After Completion:
✅ Simulate offline test
✅ Sync data to server
🧠 FINAL MVP FEATURES
✅ SECTIONS:
Writing (AI-based evaluation)
Speaking (AI-based evaluation)
Reading (basic MCQs)
✅ AI FEATURES:
Writing → real AI evaluation
Speaking → real or semi-dummy AI evaluation
✅ CORE MODULES:
Auth + Google Login
Admin Panel (must for viva)
Mock Test System
Progress Tracking
Subscription (dummy)
Offline Sync (preferred)
🎯 FINAL NOTE FOR AI ASSISTANT
Act as a Senior Backend Architect and guide step-by-step development.
Ensure:
Clean scalable architecture
Proper API design
Dependency-based development
Postman testing after each module
Production-level coding practices
Provide:

API endpoints
Request/Response structure
Database queries
Best practices
