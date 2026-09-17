# Online Examination System

A web-based examination platform built with Java Servlets, JSP, and JDBC, allowing admins to create tests and students to attempt them with automatic evaluation.

> Built for **Advance Java Lab (5CAI4-24)** — B.Tech CSE (AI), 3rd Year, Rajasthan Technical University, Kota.

---

## 📋 Project Documentation

This project is documented across several files — read them in this order:

| File | Purpose |
|---|---|
| [`PRD.md`](./Online_Examination_System_PRD.md) | What the system does — requirements, user roles, features |
| [`architecture.md`](./architecture.md) | How it's built — layers, package structure, request flow, DB schema |
| [`design.md`](./design.md) | How it looks — colors, layout, page-by-page UI notes |
| [`rules.md`](./rules.md) | Coding conventions and constraints to follow while building |
| [`phases.md`](./phases.md) | Step-by-step build plan with checkboxes |
| [`memory.md`](./memory.md) | Running log of decisions, status, and session notes |

---

## ⚙️ Tech Stack

- **Backend:** Java Servlets
- **Frontend:** JSP, HTML, CSS, JavaScript
- **Database:** MySQL (via JDBC)
- **Server:** Apache Tomcat
- **Session Handling:** HttpSession

---

## ✨ Features

- Role-based login for **Admin** and **Student**
- Admin can create a question bank and assemble timed tests
- Student can attempt a test with a live countdown timer and auto-submit
- Automatic score evaluation on submission
- Admin report view of all student results

---

## 🗂️ Project Structure

```
OnlineExamSystem/
├── src/com/examsystem/
│   ├── controller/   → Servlets
│   ├── dao/          → Database access classes
│   ├── model/         → Entity classes (User, Question, Test, Result)
│   ├── util/          → DBConnection and helpers
│   └── filter/         → AuthFilter (login protection)
├── WebContent/
│   ├── *.jsp          → All pages (login, dashboards, test, results)
│   ├── css/style.css
│   ├── js/timer.js
│   └── WEB-INF/web.xml
└── lib/                → Compile-time libraries (Tomcat Servlet API and MySQL JDBC connector)
```

Full structure and reasoning in [`architecture.md`](./architecture.md).

---

## 🚀 Setup & Run

### Automated Setup (Recommended)

Run the PowerShell setup script from the project root (**as Administrator**):

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

This script will automatically:
1. ✅ Verify JDK and add MySQL to PATH
2. ✅ Reuse an existing Apache Tomcat 10, or download it when none is installed
3. ✅ Create the `exam_system` database and import `schema.sql`
4. ✅ Create a dedicated MySQL user (`exam_user`)
5. ✅ Compile all Java sources and build the WAR file
6. ✅ Deploy to Tomcat and start the server
7. ✅ Open the app in your browser

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
6. Start Tomcat and open:
   ```
   http://localhost:8080/online_exam/
   ```

### Default Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@exam.com` | `admin123` |
| Student | `rahul@student.com` | `student123` |

---

## 🧭 Build Order

Follow the phases in [`phases.md`](./phases.md):

```
Setup → Auth → Admin (Questions/Tests) → Student (Take Test) → Results → Security Pass → UI Polish → Docs
```

---

## 🧪 Syllabus Coverage

| Experiment | Covered By |
|---|---|
| JDBC, `java.sql` Package | DAO layer, all DB operations |
| J2EE Architecture, n-tier concepts | Overall 3-tier structure |
| Servlets, Session Handling, Filters | Login, session management, `AuthFilter` |
| JSP, JSTL, Tag Libraries | Dynamic question rendering, results display |

---

## 📌 Status

See [`memory.md`](./memory.md) for current build status and session notes.

---

## 👤 Author

[Your Name]
B.Tech CSE (AI), 3rd Year
