# Project Memory
## TestVerse

A living log of decisions, current status, and context â€” updated as the project progresses.

---

## Project Snapshot

| Field | Value |
|---|---|
| Project Name | TestVerse |
| Course | Advance Java Lab (5CAI4-24), B.Tech CSE (AI), 3rd Year |
| Stack | Java Servlets, JSP, JDBC, MySQL, Apache Tomcat |
| Related Docs | `PRD.md`, `architecture.md`, `rules.md`, `phases.md`, `design.md` |
| Current Phase | Phase 7 â€” Build Completed & Ready for Deployment |
| Last Updated | September 2026 |

---

## Decisions Log

| Date | Decision | Reason |
|---|---|---|
| 2026-09-16 | Used SHA-256 (`MessageDigest`) for password hashing | Standard JRE library requiring no external dependencies; robust and fulfills lab security specifications. |
| 2026-09-16 | Stripped `correctOption` in `TestDAO.getQuestionsForTest(testId, true)` | Security guarantee: correct answers are never transmitted to browser DOM, hidden inputs, or client network packets during exams. |
| 2026-09-16 | Server-side duration validation with 90s grace period in `SubmitTestServlet` | Hard enforcement of test time limits preventing client-side timer manipulation while accounting for network latency. |
| 2026-09-16 | Dynamic tests loader in `AuthFilter` for `studentDashboard.jsp` | Enforces zero JDBC/SQL in JSP views while keeping the pure 8-servlet architecture clean. |

---

## Current Status

**What's working:**
- Database schema (`schema.sql`) with tables (`users`, `questions`, `tests`, `test_questions`, `results`, `student_answers`) and seed data.
- Full backend architecture:
  - 4 Entities: `User.java`, `Question.java`, `Test.java`, `Result.java`
  - Centralized connection & security utility: `DBConnection.java`
  - 4 DAOs with `PreparedStatement` & `try-with-resources`: `UserDAO.java`, `QuestionDAO.java`, `TestDAO.java`, `ResultDAO.java`
  - Role-based security filter: `AuthFilter.java`
  - 8 Single-responsibility Servlets: `RegisterServlet`, `LoginServlet`, `LogoutServlet`, `AddQuestionServlet`, `CreateTestServlet`, `StartTestServlet`, `SubmitTestServlet`, `ViewResultsServlet`
- Full presentation tier (`WebContent/`):
  - 9 JSP views (`login.jsp`, `register.jsp`, `adminDashboard.jsp`, `addQuestion.jsp`, `createTest.jsp`, `studentDashboard.jsp`, `takeTest.jsp`, `result.jsp`, `viewReport.jsp`)
  - Complete Design System stylesheet (`css/style.css`)
  - Exam countdown timer and auto-submit handler (`js/timer.js`)
  - Deployment descriptor (`WEB-INF/web.xml`) with servlet mappings and 30-min session timeout.

**What's in progress:**
- Ready for local deployment on Apache Tomcat and MySQL execution.

---

## Seed Data Notes

- Seeded admin account in `schema.sql`:
  - **Email:** `admin@exam.com`
  - **Password:** `admin123`
  - **Hash:** `240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9`
- Seeded student account in `schema.sql`:
  - **Email:** `rahul@student.com`
  - **Password:** `student123`
  - **Hash:** `065538e12d4a5da539be276f1839e931b262d9804b9c1d00f7ea63ecb4efcfd5`
- Seeded initial test: "Core Java Basics" with 5 Java MCQ questions.
