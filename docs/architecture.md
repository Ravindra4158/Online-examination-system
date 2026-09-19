# System Architecture Document
## TestVerse

**Related Document:** TestVerse_PRD.md
**Version:** 1.0

---

## 1. Architecture Style

The system follows a **3-tier (n-tier) J2EE web architecture**, separating presentation, business logic, and data layers. This mirrors the MVC-influenced pattern typically used with Servlets and JSP.

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                        CLIENT TIER                            â”‚
â”‚                    (Browser - HTML/CSS/JS)                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                             â”‚ HTTP Request / Response
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                     PRESENTATION TIER                         â”‚
â”‚              JSP Pages (View) + Servlets (Controller)         â”‚
â”‚   login.jsp, takeTest.jsp, adminDashboard.jsp, etc.            â”‚
â”‚   LoginServlet, SubmitTestServlet, CreateTestServlet, etc.     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                             â”‚ Java Method Calls
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                      BUSINESS LOGIC TIER                      â”‚
â”‚        DAO classes (UserDAO, QuestionDAO, TestDAO,            â”‚
â”‚        ResultDAO) + Helper/Utility classes                    â”‚
â”‚        Score evaluation logic, session/timer logic            â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                             â”‚ JDBC
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â–¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                         DATA TIER                              â”‚
â”‚                     MySQL Database                            â”‚
â”‚   users | questions | tests | test_questions | results        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## 2. Layer Responsibilities

### 2.1 Client Tier
- Renders HTML/CSS pages served by JSP
- Runs JavaScript for the countdown timer and auto-submit trigger
- Sends form submissions (login, test answers) via HTTP GET/POST

### 2.2 Presentation Tier (JSP + Servlets)
- **JSP pages** â€” pure display logic; use JSTL/EL to loop over data passed via `request`/`session` attributes (no embedded business logic or JDBC calls in JSP)
- **Servlets** â€” act as controllers; receive requests, invoke DAO layer, set attributes, forward to appropriate JSP
- **Filters** â€” (optional, per syllabus Exp 5) used for authentication checks, e.g. blocking access to `adminDashboard.jsp` unless `session.getAttribute("role")` equals `"admin"`

### 2.3 Business Logic Tier (DAO Layer)
- Encapsulates all database access behind Data Access Objects, keeping Servlets free of raw SQL
- Contains score evaluation logic (compare `selected_option` vs `correct_option`)
- Contains reusable helper classes (e.g., `DBConnection.java` for connection pooling/singleton connection)

### 2.4 Data Tier
- MySQL database, accessed exclusively through the DAO layer via JDBC
- Schema as defined in the PRD (`users`, `questions`, `tests`, `test_questions`, `results`, `student_answers`)

---

## 3. Package Structure (Suggested)

```
TestVerse/
â”‚
â”œâ”€â”€ src/
â”‚   â””â”€â”€ com/
â”‚       â””â”€â”€ examsystem/
â”‚           â”œâ”€â”€ controller/          â†’ All Servlets
â”‚           â”‚   â”œâ”€â”€ LoginServlet.java
â”‚           â”‚   â”œâ”€â”€ RegisterServlet.java
â”‚           â”‚   â”œâ”€â”€ LogoutServlet.java
â”‚           â”‚   â”œâ”€â”€ AddQuestionServlet.java
â”‚           â”‚   â”œâ”€â”€ CreateTestServlet.java
â”‚           â”‚   â”œâ”€â”€ StartTestServlet.java
â”‚           â”‚   â”œâ”€â”€ SubmitTestServlet.java
â”‚           â”‚   â””â”€â”€ ViewResultsServlet.java
â”‚           â”‚
â”‚           â”œâ”€â”€ dao/                 â†’ Data Access Objects
â”‚           â”‚   â”œâ”€â”€ UserDAO.java
â”‚           â”‚   â”œâ”€â”€ QuestionDAO.java
â”‚           â”‚   â”œâ”€â”€ TestDAO.java
â”‚           â”‚   â””â”€â”€ ResultDAO.java
â”‚           â”‚
â”‚           â”œâ”€â”€ model/               â†’ POJOs / entity classes
â”‚           â”‚   â”œâ”€â”€ User.java
â”‚           â”‚   â”œâ”€â”€ Question.java
â”‚           â”‚   â”œâ”€â”€ Test.java
â”‚           â”‚   â””â”€â”€ Result.java
â”‚           â”‚
â”‚           â”œâ”€â”€ util/                â†’ Utility/helper classes
â”‚           â”‚   â””â”€â”€ DBConnection.java
â”‚           â”‚
â”‚           â””â”€â”€ filter/              â†’ Servlet filters
â”‚               â””â”€â”€ AuthFilter.java
â”‚
â”œâ”€â”€ WebContent/ (or webapp/)
â”‚   â”œâ”€â”€ login.jsp
â”‚   â”œâ”€â”€ register.jsp
â”‚   â”œâ”€â”€ adminDashboard.jsp
â”‚   â”œâ”€â”€ addQuestion.jsp
â”‚   â”œâ”€â”€ createTest.jsp
â”‚   â”œâ”€â”€ studentDashboard.jsp
â”‚   â”œâ”€â”€ takeTest.jsp
â”‚   â”œâ”€â”€ result.jsp
â”‚   â”œâ”€â”€ viewReport.jsp
â”‚   â”œâ”€â”€ css/
â”‚   â”‚   â””â”€â”€ style.css
â”‚   â”œâ”€â”€ js/
â”‚   â”‚   â””â”€â”€ timer.js
â”‚   â””â”€â”€ WEB-INF/
â”‚       â””â”€â”€ web.xml
â”‚
â””â”€â”€ lib/
    â””â”€â”€ mysql-connector-j-x.x.x.jar
```

---

## 4. Request Flow Examples

### 4.1 Login Flow
```
Browser (login.jsp form POST)
   â†’ LoginServlet
       â†’ UserDAO.validateUser(email, password)
           â†’ JDBC query on `users` table
       â†’ if valid: session.setAttribute("user", user); redirect by role
       â†’ if invalid: forward back to login.jsp with error message
```

### 4.2 Take Test Flow
```
Browser (clicks "Start Test" on studentDashboard.jsp)
   â†’ StartTestServlet
       â†’ TestDAO.getQuestionsForTest(testId)
       â†’ session.setAttribute("startTime", System.currentTimeMillis())
       â†’ forward to takeTest.jsp (renders questions + starts JS timer)

Browser (submits answers, or JS auto-submits at time limit)
   â†’ SubmitTestServlet
       â†’ Read selected options from request
       â†’ ResultDAO.evaluateAndSave(userId, testId, answers)
           â†’ Compare answers against `correct_option` in `questions`
           â†’ Insert into `results` and `student_answers`
       â†’ forward to result.jsp with score
```

### 4.3 Admin Creates Test Flow
```
Browser (createTest.jsp form POST)
   â†’ CreateTestServlet
       â†’ TestDAO.createTest(subject, duration, marks)
       â†’ TestDAO.linkQuestions(testId, selectedQuestionIds)
       â†’ redirect to adminDashboard.jsp with success message
```

---

## 5. Session Management Design

| Session Attribute | Set By | Used By | Purpose |
|---|---|---|---|
| `user` | LoginServlet | All pages | Identify logged-in user, display name |
| `role` | LoginServlet | AuthFilter, dashboards | Route to admin vs student views |
| `currentTestId` | StartTestServlet | SubmitTestServlet | Know which test is being attempted |
| `startTime` | StartTestServlet | SubmitTestServlet | Validate/calculate time taken, enforce duration |

- Session timeout should be set in `web.xml` (e.g., 30 minutes) to auto-expire inactive sessions.
- `LogoutServlet` calls `session.invalidate()`.

---

## 6. Security Considerations

- **AuthFilter** intercepts requests to admin/student protected pages and redirects unauthenticated users to `login.jsp`.
- Passwords should at minimum be hashed (e.g., using `MessageDigest` for SHA-256) rather than stored in plain text â€” acceptable simplification for a lab project, but worth mentioning as a design decision.
- Use `PreparedStatement` (not raw `Statement`) everywhere to prevent SQL injection.
- Validate that a student cannot access `SubmitTestServlet` directly without first going through `StartTestServlet` (check `session.getAttribute("currentTestId")` is not null).

---

## 7. Deployment View

```
Developer Machine
   â”œâ”€â”€ Eclipse/IntelliJ (project source)
   â”œâ”€â”€ Apache Tomcat 9/10 (local server, port 8080)
   â””â”€â”€ MySQL Server (local instance, port 3306)

Runtime:
Browser â†’ http://localhost:8080/TestVerse/login.jsp
             â†’ Tomcat servlet container
                 â†’ JDBC connection â†’ MySQL (exam_system database)
```

---

## 8. Technology-to-Syllabus Mapping

| Architecture Component | Syllabus Experiment |
|---|---|
| DAO Layer + JDBC | Exp 2 â€” Java database programming, JDBC |
| n-tier structure, Web container | Exp 4 â€” J2EE architecture, enterprise application concepts |
| Servlets, AuthFilter, Session | Exp 5 â€” Server-side programming, session/event handling, filters |
| JSP pages, JSTL | Exp 6 â€” JSP architecture, tag libraries |
