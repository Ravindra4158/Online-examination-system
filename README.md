# TestVerse

A web-based examination platform built with Java Servlets, JSP, and JDBC, allowing admins to create tests and students to attempt them with automatic evaluation.

> Built for **Advance Java Lab (5CAI4-24)** â€” B.Tech CSE (AI), 3rd Year, Rajasthan Technical University, Kota.

---

## ðŸ“‹ Project Documentation

This project is documented across several files â€” read them in this order:

| File | Purpose |
|---|---|
| [`PRD.md`](./docs/TestVerse_PRD.md) | What the system does â€” requirements, user roles, features |
| [`architecture.md`](./architecture.md) | How it's built â€” layers, package structure, request flow, DB schema |
| [`design.md`](./design.md) | How it looks â€” colors, layout, page-by-page UI notes |
| [`rules.md`](./rules.md) | Coding conventions and constraints to follow while building |
| [`phases.md`](./phases.md) | Step-by-step build plan with checkboxes |
| [`memory.md`](./memory.md) | Running log of decisions, status, and session notes |

---

## âš™ï¸ Tech Stack

- **Backend:** Java Servlets
- **Frontend:** JSP, HTML, CSS, JavaScript
- **Database:** MySQL (via JDBC)
- **Server:** Apache Tomcat
- **Session Handling:** HttpSession

### Splash Screen

On the first visit in each browser session, TestVerse displays a centered academic splash screen for 3 seconds, fades it out over 300 ms, and redirects to the login page. `sessionStorage` prevents it from appearing again during route changes in the same session.

---

## âœ¨ Features

- Role-based login for **Admin** and **Student**
- Admin can create a question bank and assemble timed tests
- Student can attempt a test with a live countdown timer and auto-submit
- Automatic score evaluation on submission
- Admin report view of all student results

---

## ðŸ—‚ï¸ Project Structure

```
TestVerse/
â”œâ”€â”€ src/com/examsystem/
â”‚   â”œâ”€â”€ controller/   â†’ Servlets
â”‚   â”œâ”€â”€ dao/          â†’ Database access classes
â”‚   â”œâ”€â”€ model/         â†’ Entity classes (User, Question, Test, Result)
â”‚   â”œâ”€â”€ util/          â†’ DBConnection and helpers
â”‚   â””â”€â”€ filter/         â†’ AuthFilter (login protection)
â”œâ”€â”€ WebContent/
â”‚   â”œâ”€â”€ *.jsp          â†’ All pages (login, dashboards, test, results)
â”‚   â”œâ”€â”€ css/style.css
â”‚   â”œâ”€â”€ js/timer.js
â”‚   â””â”€â”€ WEB-INF/web.xml
â””â”€â”€ lib/                â†’ Compile-time libraries (Tomcat Servlet API and MySQL JDBC connector)
```

Full structure and reasoning in [`architecture.md`](./architecture.md).

---

## ðŸš€ Setup & Run

### Automated Setup (Recommended)

Run the PowerShell setup script from the project root (**as Administrator**):

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

This script will automatically:
1. âœ… Verify JDK and add MySQL to PATH
2. âœ… Reuse an existing Apache Tomcat 10, or download it when none is installed
3. âœ… Create the `exam_system` database and import `schema.sql`
4. âœ… Create a dedicated MySQL user (`exam_user`)
5. âœ… Compile all Java sources and build the WAR file
6. âœ… Deploy to Tomcat and start the server
7. âœ… Open the app in your browser

### Manual Setup (Fallback)

1. **Prerequisites:** JDK 11+, Apache Tomcat 10, MySQL 8.0
   Set `CATALINA_HOME` to the Tomcat installation that will run the application. The project includes `lib\servlet-api.jar`, copied from Tomcat's `lib` directory for compilation. Keep it matched to the runtime Tomcat; do not download a different Servlet API jar.
2. Create the database and run the schema:
   ```sql
   CREATE DATABASE exam_system;
   -- then run schema.sql
   ```
3. Update DB credentials in `src/com/examsystem/util/DBConnection.java`
4. Compile using `lib\servlet-api.jar` and the MySQL connector in `lib\`
5. Package the classes and web files as a WAR, then deploy it to Tomcat's `webapps/` directory
6. Start Tomcat and open the login page:
   ```
   http://localhost:8080/testverse/
   ```

### Current Local Deployment

The project is currently deployed with Apache Tomcat 10.1.60:

```text
C:\Users\Admin\Tomcat\apache-tomcat-10.1.60
```

The local login page is:

```text
http://localhost:8080/testverse/
```

To start or stop this Tomcat instance manually:

```powershell
$env:CATALINA_HOME = "C:\Users\Admin\Tomcat\apache-tomcat-10.1.60"
& "$env:CATALINA_HOME\bin\startup.bat"
& "$env:CATALINA_HOME\bin\shutdown.bat"
```

### Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@exam.com` | `admin123` |
| Student | `rahul@student.com` | `student123` |

### Reset Test Attempts

To clear submitted attempts while preserving users, questions, and exams, run:

```sql
USE exam_system;
DELETE FROM student_answers;
DELETE FROM results;
```

Do not run `schema.sql` when only resetting attempts. The schema script recreates the application tables and seed data.

---

## ðŸ§­ Build Order

Follow the phases in [`phases.md`](./phases.md):

```
Setup â†’ Auth â†’ Admin (Questions/Tests) â†’ Student (Take Test) â†’ Results â†’ Security Pass â†’ UI Polish â†’ Docs
```

---

## ðŸ§ª Syllabus Coverage

| Experiment | Covered By |
|---|---|
| JDBC, `java.sql` Package | DAO layer, all DB operations |
| J2EE Architecture, n-tier concepts | Overall 3-tier structure |
| Servlets, Session Handling, Filters | Login, session management, `AuthFilter` |
| JSP, JSTL, Tag Libraries | Dynamic question rendering, results display |

---

## ðŸ“Œ Status

See [`memory.md`](./memory.md) for current build status and session notes.

---

## ðŸ‘¤ Author

Aaditya joshi

