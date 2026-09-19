# Development Phases
## TestVerse

Phase-wise build checklist and completion status.

---

## Phase 0: Setup
**Goal:** Working empty project that connects to the database.

- [x] Install/verify JDK, Apache Tomcat, MySQL
- [x] Create dynamic web project directory structure
- [x] Create database schema script (`schema.sql`) with tables & sample seed data
- [x] Write `DBConnection.java` with centralized connection management and SHA-256 hashing
- [x] Deployment descriptor (`web.xml`) configured with 30-min session timeout

---

## Phase 1: Authentication
**Goal:** Users can register, log in, and log out with role-based redirect.

- [x] Create `users` table in `schema.sql`
- [x] Build `register.jsp` + `RegisterServlet` + `UserDAO.registerUser()`
- [x] Build `login.jsp` + `LoginServlet` + `UserDAO.validateUser()`
- [x] Implement session creation on login (`user`, `role` attributes)
- [x] Build `LogoutServlet` (`session.invalidate()`)
- [x] Build `AuthFilter` to protect dashboard URLs and prevent direct unauthenticated access
- [x] Redirect admin â†’ `adminDashboard.jsp`, student â†’ `studentDashboard.jsp`

---

## Phase 2: Admin â€” Question & Test Management
**Goal:** Admin can build a question bank and assemble tests from it.

- [x] Build `addQuestion.jsp` + `AddQuestionServlet` + `QuestionDAO`
- [x] Add list/edit/delete view for existing questions
- [x] Build `createTest.jsp` (select subject, duration, pick questions) + `CreateTestServlet` + `TestDAO`
- [x] Populate `test_questions` mapping table on test creation
- [x] Basic validation: test must have at least 1 question, duration > 0

---

## Phase 3: Student â€” Taking a Test
**Goal:** Student can view, start, and attempt a test end-to-end.

- [x] Build `studentDashboard.jsp` listing available tests (`TestDAO.getAllTests()`)
- [x] Build `StartTestServlet` â€” loads questions (sanitizing correct options), sets `currentTestId` and `startTime` in session
- [x] Build `takeTest.jsp` â€” renders questions with radio button options via JSTL loop
- [x] Add JS countdown timer (`timer.js`) with auto-submit trigger on expiry
- [x] Build `SubmitTestServlet` â€” reads answers, calls `ResultDAO.evaluateAndSave()`
- [x] Build `result.jsp` â€” shows score immediately after submission

---

## Phase 4: Results & Reporting
**Goal:** Admin can review how students performed.

- [x] Build `ResultDAO.getResultsByTest()` and `getResultsByStudent()`
- [x] Build `viewReport.jsp` + `ViewResultsServlet` for admin to see all attempts
- [x] Student-side "My Results" view showing their own past attempts

---

## Phase 5: Security & Validation Pass
**Goal:** Harden the app against common vulnerabilities.

- [x] Confirm all SQL uses `PreparedStatement` with `try-with-resources`
- [x] Confirm passwords are hashed with SHA-256 before storage and comparison
- [x] Confirm `SubmitTestServlet` cannot be hit without active `currentTestId` in session
- [x] Confirm server-side duration check (not just JS timer) in `SubmitTestServlet`
- [x] Confirm `AuthFilter` blocks direct URL access to protected JSPs when logged out
- [x] Confirm correct answers are NEVER transmitted to the browser during test attempt

---

## Phase 6: UI Polish
**Goal:** Coherent, professional interface adhering strictly to design guidelines.

- [x] Apply consistent `style.css` using curated palette (#1E3A8A, #475569, #16A34A, etc.)
- [x] Add error/success message banners on forms
- [x] Add empty states (e.g. "No tests available yet")
- [x] Tabular numbers (`font-variant-numeric: tabular-nums`) for countdown timer

---

## Phase 7: Documentation & Submission Prep
**Goal:** Package everything for lab file/viva submission.

- [x] Update `architecture.md`, `rules.md`, `design.md`, `README.md`, `PRD.md`
- [x] Generate complete `schema.sql` with admin & sample exam seed data
- [x] Map all syllabus experiments to code implementation
