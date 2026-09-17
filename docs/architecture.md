# System Architecture Document
## Online Examination System

**Related Document:** Online_Examination_System_PRD.md
**Version:** 1.0

---

## 1. Architecture Style

The system follows a **3-tier (n-tier) J2EE web architecture**, separating presentation, business logic, and data layers. This mirrors the MVC-influenced pattern typically used with Servlets and JSP.

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT TIER                            │
│                    (Browser - HTML/CSS/JS)                    │
└───────────────────────────┬────────────────────────────────┘
                             │ HTTP Request / Response
┌───────────────────────────▼────────────────────────────────┐
│                     PRESENTATION TIER                         │
│              JSP Pages (View) + Servlets (Controller)         │
│   login.jsp, takeTest.jsp, adminDashboard.jsp, etc.            │
│   LoginServlet, SubmitTestServlet, CreateTestServlet, etc.     │
└───────────────────────────┬────────────────────────────────┘
                             │ Java Method Calls
┌───────────────────────────▼────────────────────────────────┐
│                      BUSINESS LOGIC TIER                      │
│        DAO classes (UserDAO, QuestionDAO, TestDAO,            │
│        ResultDAO) + Helper/Utility classes                    │
│        Score evaluation logic, session/timer logic            │
└───────────────────────────┬────────────────────────────────┘
                             │ JDBC
┌───────────────────────────▼────────────────────────────────┐
│                         DATA TIER                              │
│                     MySQL Database                            │
│   users | questions | tests | test_questions | results        │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Layer Responsibilities

### 2.1 Client Tier
- Renders HTML/CSS pages served by JSP
- Runs JavaScript for the countdown timer and auto-submit trigger
- Sends form submissions (login, test answers) via HTTP GET/POST

### 2.2 Presentation Tier (JSP + Servlets)
- **JSP pages** — pure display logic; use JSTL/EL to loop over data passed via `request`/`session` attributes (no embedded business logic or JDBC calls in JSP)
- **Servlets** — act as controllers; receive requests, invoke DAO layer, set attributes, forward to appropriate JSP
- **Filters** — (optional, per syllabus Exp 5) used for authentication checks, e.g. blocking access to `adminDashboard.jsp` unless `session.getAttribute("role")` equals `"admin"`

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
OnlineExamSystem/
│
├── src/
│   └── com/
│       └── examsystem/
│           ├── controller/          → All Servlets
│           │   ├── LoginServlet.java
│           │   ├── RegisterServlet.java
│           │   ├── LogoutServlet.java
│           │   ├── AddQuestionServlet.java
│           │   ├── CreateTestServlet.java
│           │   ├── StartTestServlet.java
│           │   ├── SubmitTestServlet.java
│           │   └── ViewResultsServlet.java
│           │
│           ├── dao/                 → Data Access Objects
│           │   ├── UserDAO.java
│           │   ├── QuestionDAO.java
│           │   ├── TestDAO.java
│           │   └── ResultDAO.java
│           │
│           ├── model/               → POJOs / entity classes
│           │   ├── User.java
│           │   ├── Question.java
│           │   ├── Test.java
│           │   └── Result.java
│           │
│           ├── util/                → Utility/helper classes
│           │   └── DBConnection.java
│           │
│           └── filter/              → Servlet filters
│               └── AuthFilter.java
│
├── WebContent/ (or webapp/)
│   ├── login.jsp
│   ├── register.jsp
│   ├── adminDashboard.jsp
│   ├── addQuestion.jsp
│   ├── createTest.jsp
│   ├── studentDashboard.jsp
│   ├── takeTest.jsp
│   ├── result.jsp
│   ├── viewReport.jsp
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── timer.js
│   └── WEB-INF/
│       └── web.xml
│
└── lib/
    └── mysql-connector-j-x.x.x.jar
```

---

## 4. Request Flow Examples

### 4.1 Login Flow
```
Browser (login.jsp form POST)
   → LoginServlet
       → UserDAO.validateUser(email, password)
           → JDBC query on `users` table
       → if valid: session.setAttribute("user", user); redirect by role
       → if invalid: forward back to login.jsp with error message
```

### 4.2 Take Test Flow
```
Browser (clicks "Start Test" on studentDashboard.jsp)
   → StartTestServlet
       → TestDAO.getQuestionsForTest(testId)
       → session.setAttribute("startTime", System.currentTimeMillis())
       → forward to takeTest.jsp (renders questions + starts JS timer)

Browser (submits answers, or JS auto-submits at time limit)
   → SubmitTestServlet
       → Read selected options from request
       → ResultDAO.evaluateAndSave(userId, testId, answers)
           → Compare answers against `correct_option` in `questions`
           → Insert into `results` and `student_answers`
       → forward to result.jsp with score
```

### 4.3 Admin Creates Test Flow
```
Browser (createTest.jsp form POST)
   → CreateTestServlet
       → TestDAO.createTest(subject, duration, marks)
       → TestDAO.linkQuestions(testId, selectedQuestionIds)
       → redirect to adminDashboard.jsp with success message
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
- Passwords should at minimum be hashed (e.g., using `MessageDigest` for SHA-256) rather than stored in plain text — acceptable simplification for a lab project, but worth mentioning as a design decision.
- Use `PreparedStatement` (not raw `Statement`) everywhere to prevent SQL injection.
- Validate that a student cannot access `SubmitTestServlet` directly without first going through `StartTestServlet` (check `session.getAttribute("currentTestId")` is not null).

---

## 7. Deployment View

```
Developer Machine
   ├── Eclipse/IntelliJ (project source)
   ├── Apache Tomcat 9/10 (local server, port 8080)
   └── MySQL Server (local instance, port 3306)

Runtime:
Browser → http://localhost:8080/OnlineExamSystem/login.jsp
             → Tomcat servlet container
                 → JDBC connection → MySQL (exam_system database)
```

---

## 8. Technology-to-Syllabus Mapping

| Architecture Component | Syllabus Experiment |
|---|---|
| DAO Layer + JDBC | Exp 2 — Java database programming, JDBC |
| n-tier structure, Web container | Exp 4 — J2EE architecture, enterprise application concepts |
| Servlets, AuthFilter, Session | Exp 5 — Server-side programming, session/event handling, filters |
| JSP pages, JSTL | Exp 6 — JSP architecture, tag libraries |
