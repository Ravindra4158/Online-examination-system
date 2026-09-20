TestVerse

TestVerse is a web-based examination platform built using Java Servlets, JSP, JDBC, and MySQL. It allows administrators to create and manage examinations while students can securely attempt timed tests with automatic evaluation and result generation.

«Built for Advanced Java Lab (5CAI4-24) — B.Tech CSE (AI), 3rd Year, Rajasthan Technical University, Kota.»

---

📚 Project Documentation

The project documentation is organized into the following files:

File| Description
""docs/TestVerse_PRD.md"" (./docs/TestVerse_PRD.md)| Product requirements, user roles, and system features
""architecture.md"" (./architecture.md)| System architecture, package structure, request flow, and database design
""design.md"" (./design.md)| UI/UX guidelines, colors, layouts, and page specifications
""rules.md"" (./rules.md)| Coding conventions and development constraints
""phases.md"" (./phases.md)| Step-by-step implementation plan
""memory.md"" (./memory.md)| Development status, decisions, and session notes

---

⚙️ Tech Stack

Layer| Technology
Backend| Java Servlets
Frontend| JSP, HTML, CSS, JavaScript
Database| MySQL
Database Connectivity| JDBC
Application Server| Apache Tomcat 10
Session Management| "HttpSession"

---

✨ Features

🔐 Authentication & Authorization

- Role-based login for Admin and Student
- Session-based authentication using "HttpSession"
- Protected routes using "AuthFilter"

👨‍💼 Admin Features

- Create and manage questions
- Maintain a question bank
- Create and configure tests
- Assemble questions into tests
- Set test duration
- View student results and performance reports

👨‍🎓 Student Features

- Secure student login
- View available tests
- Attempt timed examinations
- Live countdown timer
- Automatic submission when the timer expires
- Automatic evaluation after submission
- View examination results

⏱️ Exam Timer

Students receive a live countdown timer while attempting an examination. The test is automatically submitted when the allotted time expires.

🖥️ Splash Screen

On the first visit during a browser session, TestVerse displays a centered academic splash screen for 3 seconds, followed by a 300 ms fade-out animation before redirecting to the login page.

"sessionStorage" is used to prevent the splash screen from appearing again during route changes within the same browser session.

---

🗂️ Project Structure

TestVerse/
├── src/
│   └── com/
│       └── examsystem/
│           ├── controller/       # Servlets
│           ├── dao/              # Database access objects
│           ├── model/            # Entity classes
│           ├── util/             # DBConnection and utilities
│           └── filter/           # Authentication filters
│
├── WebContent/
│   ├── *.jsp                     # Application pages
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── timer.js
│   └── WEB-INF/
│       └── web.xml
│
├── lib/
│   ├── servlet-api.jar
│   └── mysql-connector-j.jar
│
├── docs/
│   └── TestVerse_PRD.md
│
├── schema.sql
├── setup.ps1
├── architecture.md
├── design.md
├── rules.md
├── phases.md
├── memory.md
└── README.md

For detailed architectural decisions, see ""architecture.md"" (./architecture.md).

---

🚀 Setup & Installation

Automated Setup — Recommended

The project includes a PowerShell setup script that automates most of the installation and deployment process.

Run the following command from the project root as Administrator:

powershell -ExecutionPolicy Bypass -File .\setup.ps1

The script performs the following steps:

1. Verifies the installed JDK
2. Adds MySQL to the system "PATH" when required
3. Detects an existing Apache Tomcat installation
4. Downloads Tomcat if a suitable installation is not available
5. Creates the "exam_system" database
6. Imports "schema.sql"
7. Creates the dedicated MySQL user "exam_user"
8. Compiles the Java source files
9. Builds the application WAR file
10. Deploys the WAR to Tomcat
11. Starts the Tomcat server
12. Opens the application in the browser

---

🛠️ Manual Setup

1. Prerequisites

Install the following:

- JDK 11 or later
- Apache Tomcat 10
- MySQL 8.0 or later

Set the "CATALINA_HOME" environment variable to the Tomcat installation that will run the application.

The project includes "lib\servlet-api.jar" for compilation. Keep this JAR compatible with the Tomcat runtime version.

---

2. Create the Database

Create the database:

CREATE DATABASE exam_system;

Then execute:

schema.sql

to create the required tables and seed data.

---

3. Configure Database Credentials

Update the database configuration in:

src/com/examsystem/util/DBConnection.java

Example:

String URL = "jdbc:mysql://localhost:3306/exam_system";
String USER = "exam_user";
String PASSWORD = "your_password";

---

4. Compile the Application

Compile the Java source files using:

lib\servlet-api.jar

and the MySQL JDBC connector available in:

lib\

---

5. Build and Deploy

Package the compiled classes and "WebContent" directory into a WAR file.

Copy the generated WAR file into:

<TOMCAT_HOME>\webapps\

Start Tomcat and open:

http://localhost:8080/testverse/

---

🖥️ Current Local Deployment

The project is currently configured to run with:

Apache Tomcat 10.1.60

Tomcat installation:

C:\Users\Admin\Tomcat\apache-tomcat-10.1.60

Application URL:

http://localhost:8080/testverse/

Start Tomcat

$env:CATALINA_HOME = "C:\Users\Admin\Tomcat\apache-tomcat-10.1.60"
& "$env:CATALINA_HOME\bin\startup.bat"

Stop Tomcat

$env:CATALINA_HOME = "C:\Users\Admin\Tomcat\apache-tomcat-10.1.60"
& "$env:CATALINA_HOME\bin\shutdown.bat"

---

🔑 Default Login Credentials

Role| Email| Password
Admin| "admin@exam.com"| "admin123"
Student| "rahul@student.com"| "student123"

«Security note: These credentials are intended for local development/testing only. Change them before deploying the application to a public or production environment.»

---

🧹 Reset Test Attempts

To remove submitted examination attempts while preserving users, questions, and tests:

USE exam_system;

DELETE FROM student_answers;
DELETE FROM results;

⚠️ Important

Do not run "schema.sql" when you only want to reset test attempts.

The schema script recreates application tables and seed data.

---

🧭 Development Roadmap

Development follows the phases defined in ""phases.md"" (./phases.md):

Setup
  ↓
Authentication
  ↓
Admin — Questions & Tests
  ↓
Student — Take Test
  ↓
Results & Reports
  ↓
Security Pass
  ↓
UI Polish
  ↓
Documentation

---

🧪 RTU Advanced Java Lab Coverage

Experiment / Topic| TestVerse Implementation
JDBC & "java.sql" Package| DAO layer and database operations
J2EE Architecture| Three-tier application architecture
N-Tier Architecture| Controller, DAO, Model, and Database layers
Java Servlets| Authentication, test management, and exam submission
Session Handling| "HttpSession" based authentication
Servlet Filters| "AuthFilter" for protected routes
JSP| Dynamic application pages and question rendering
JSTL / Tag Libraries| Dynamic content and result rendering

---

🔒 Security

TestVerse uses several basic web application security mechanisms:

- Role-based access control
- Session-based authentication
- Servlet authentication filters
- Protected admin and student routes
- Server-side test evaluation
- Database abstraction through DAO classes
- Dedicated database user for application access

Additional security improvements are tracked in ""phases.md"" (./phases.md).

---

📊 Application Flow

                    ┌──────────────┐
                    │    Client    │
                    │ Browser/JSP  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Servlet    │
                    │  Controller  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │     DAO      │
                    │ Data Access  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    MySQL     │
                    │   Database   │
                    └──────────────┘

---

📌 Project Status

The current implementation and development progress are tracked in:

""memory.md"" (./memory.md)

The complete implementation plan is available in:

""phases.md"" (./phases.md)

---

👤 Author

Aaditya Joshi

B.Tech CSE (AI), 3rd Year
Rajasthan Technical University, Kota

---

📄 License

This project is developed for academic and educational purposes as part of the Advanced Java Lab (5CAI4-24).