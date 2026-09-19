# Project Rules & Conventions
## TestVerse

Coding standards and conventions to follow consistently throughout development.

---

## 1. Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Package names | lowercase, dot-separated | `com.examsystem.controller` |
| Class names | PascalCase | `LoginServlet`, `QuestionDAO` |
| Method names | camelCase, verb-first | `validateUser()`, `getQuestionsForTest()` |
| Variables | camelCase | `testId`, `selectedOption` |
| Constants | UPPER_SNAKE_CASE | `MAX_DURATION_MINUTES` |
| JSP file names | camelCase | `takeTest.jsp`, `adminDashboard.jsp` |
| Database tables | lowercase, snake_case, plural | `users`, `test_questions` |
| Database columns | lowercase, snake_case | `q_id`, `correct_option` |
| JSP session attributes | camelCase, descriptive | `currentTestId`, `startTime` |

---

## 2. Layering Rules (Strict)

- **JSP files must never contain JDBC code or SQL.** Only display logic using JSTL/EL.
- **Servlets must never contain raw SQL.** They call DAO methods only.
- **All SQL lives inside DAO classes**, using `PreparedStatement` exclusively â€” never `Statement` (prevents SQL injection).
- **Business logic (e.g., score calculation) lives in the DAO or a dedicated service class**, not inside the Servlet's `doPost`/`doGet`.

---

## 3. Servlet Conventions

- Every Servlet maps to a single responsibility (one action per Servlet â€” don't combine login+register in one class).
- Use `doGet()` for displaying a page/form, `doPost()` for handling form submission.
- Always validate `session != null` before accessing session attributes; redirect to `login.jsp` if session is missing/expired.
- Forward (`RequestDispatcher`) for internal page transitions; use `sendRedirect()` after a successful POST that changes state (Post-Redirect-Get pattern) to avoid duplicate form resubmission.

---

## 4. Database Access Rules

- Always use `try-with-resources` for `Connection`, `PreparedStatement`, and `ResultSet` to guarantee they close.
- Never hardcode DB credentials in multiple files â€” keep them in one place (`DBConnection.java`, or externalize to a `.properties` file if time permits).
- Every table must have a primary key; every foreign key relationship must be explicitly declared in the schema.

---

## 5. Security Rules

- No plain-text passwords â€” hash with SHA-256 at minimum before storing/comparing.
- Every protected page (dashboards, test pages, results) must be checked by `AuthFilter` â€” no relying on JSP-level checks alone.
- Validate role on the server side for every admin action (`SubmitTestServlet`, `AddQuestionServlet`, etc.) â€” never trust a hidden form field for role.
- A student must not be able to directly hit `SubmitTestServlet` without an active `currentTestId` in session (prevents skipping the exam flow).

---

## 6. UI Rules

- Keep JSP pages free of inline styling â€” all CSS in `css/style.css`.
- Every form must have server-side validation in the Servlet, even if client-side (JS) validation also exists.
- Error messages should be shown back on the same form page (via `request.setAttribute("error", ...)`), not as raw exceptions.
- The exam timer (JS) is the *soft* limit for UX; the *actual* enforcement of duration should also be checked server-side in `SubmitTestServlet` using `startTime` from session, so a manipulated client-side timer can't extend the test.

---

## 7. Git / Version Control (if used)

- Commit after each working feature (e.g., "Add login servlet + DAO", not one giant commit at the end).
- Do not commit `target/`, `.class` files, or IDE-specific config folders.
- Keep the SQL schema script (`schema.sql`) checked in and updated whenever the schema changes.

---

## 8. Documentation Rules

- Any new table, Servlet, or major class added mid-project must be reflected back into `architecture.md` and `phases.md`.
- Keep `memory.md` updated with decisions made and current build status, so context isn't lost between work sessions.

---

## 9. Things to Avoid

- âŒ Business logic inside JSP scriptlets (`<% ... %>`) â€” use JSTL/EL only.
- âŒ Catching exceptions and doing nothing (`catch(Exception e){}`) â€” always log or show a meaningful message.
- âŒ One giant `Servlet` handling every action via a `type` parameter â€” keep Servlets single-purpose per the mapping in `architecture.md`.
- âŒ Storing the correct answer in a hidden form field sent to the browser (a student could read page source and cheat) â€” correct answers must stay server-side only.
