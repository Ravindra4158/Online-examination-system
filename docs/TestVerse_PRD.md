# Product Requirement Document (PRD)
## TestVerse

**Prepared for:** Advance Java Lab (5CAI4-24) â€” B.Tech CSE (AI), 3rd Year
**Prepared by:** [Your Name]
**Date:** [Insert Date]
**Version:** 1.0

---

## 1. Introduction

### 1.1 Purpose
This document defines the requirements for an **TestVerse**, a web-based platform that allows administrators to create and manage tests, and students to attempt and receive automatically evaluated results. The project is built using core Advance Java technologies: Servlets, JSP, JDBC, and Session Management.

### 1.2 Scope
The system will support two user roles â€” **Admin** and **Student**. Admins can create question banks and tests; students can log in, attempt tests within a time limit, and view their results instantly. The system automates evaluation, removing the need for manual grading of objective (MCQ) tests.

### 1.3 Intended Audience
This document is intended for academic evaluation purposes and serves as a reference for project development, implementation, and testing.

---

## 2. Objectives

- Provide a paperless, automated platform for conducting objective exams.
- Reduce manual effort in test creation and result evaluation.
- Demonstrate practical application of J2EE concepts: Servlets, JSP, JDBC, and Session Handling.
- Ensure secure login and role-based access control (Admin vs Student).

---

## 3. Technology Stack

| Layer | Technology |
|---|---|
| Frontend | JSP, HTML, CSS, JavaScript (Bootstrap optional) |
| Backend | Java Servlets |
| Database | MySQL |
| Connectivity | JDBC |
| Server | Apache Tomcat |
| Session Management | HttpSession |
| IDE | Eclipse / IntelliJ / NetBeans |

---

## 4. User Roles

### 4.1 Admin
- Manages question bank (add/edit/delete questions)
- Creates and configures tests (subject, duration, marks)
- Views all students' results and performance reports

### 4.2 Student
- Registers/logs into the system
- Views list of available tests
- Attempts a test within the given time limit
- Views score immediately after submission

---

## 5. Functional Requirements

### 5.1 Authentication Module
| ID | Requirement |
|---|---|
| FR-1 | System shall allow new students to register with name, email, and password |
| FR-2 | System shall allow login for both Admin and Student roles |
| FR-3 | System shall validate credentials against the database |
| FR-4 | System shall maintain login state using HttpSession |
| FR-5 | System shall allow logout, invalidating the session |

### 5.2 Admin Module
| ID | Requirement |
|---|---|
| FR-6 | Admin shall be able to add a new question with 4 options and mark the correct one |
| FR-7 | Admin shall be able to edit or delete existing questions |
| FR-8 | Admin shall be able to create a test by selecting subject, duration, and number of questions |
| FR-9 | Admin shall be able to view a list of all students who attempted a test along with scores |

### 5.3 Student Module
| ID | Requirement |
|---|---|
| FR-10 | Student shall be able to view a list of available tests |
| FR-11 | Student shall be able to start a test, which displays questions dynamically from the database |
| FR-12 | System shall display a countdown timer for the test duration |
| FR-13 | System shall auto-submit the test when time expires |
| FR-14 | Student shall be able to select one option per question using radio buttons |
| FR-15 | System shall evaluate answers automatically upon submission |
| FR-16 | Student shall be able to view score immediately after submission |

### 5.4 Result Module
| ID | Requirement |
|---|---|
| FR-17 | System shall calculate and store score based on correct answers |
| FR-18 | System shall store date and time of test attempt |
| FR-19 | Admin shall be able to generate a report of all results for a given test |

---

## 6. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Usability | Interface should be simple and intuitive for students with no technical background |
| Performance | Test pages should load within 2 seconds under normal load |
| Security | Passwords should be stored securely; session should expire after logout/timeout |
| Reliability | Auto-submit must trigger reliably when timer reaches zero |
| Scalability | Database design should support addition of more subjects/tests without structural changes |
| Portability | Application should run on any system with Java + Tomcat + MySQL installed |

---

## 7. System Architecture Overview

```
[Browser] <--HTTP--> [JSP Pages] <--> [Servlets] <--JDBC--> [MySQL Database]
                                          |
                                   [HttpSession]
```

- **Presentation Layer:** JSP pages render dynamic content (questions, results)
- **Control Layer:** Servlets handle requests, business logic, and session management
- **Data Layer:** MySQL database accessed via JDBC

---

## 8. Database Design

### 8.1 Entity Overview
- `users` â€” stores login credentials and role
- `questions` â€” stores question bank
- `tests` â€” stores test configuration
- `test_questions` â€” maps questions to a test
- `results` â€” stores student scores
- `student_answers` â€” stores selected answers per question (for review, optional)

### 8.2 Schema

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    role VARCHAR(20) -- 'admin' or 'student'
);

CREATE TABLE questions (
    q_id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(50),
    question_text TEXT,
    option_a VARCHAR(255),
    option_b VARCHAR(255),
    option_c VARCHAR(255),
    option_d VARCHAR(255),
    correct_option CHAR(1)
);

CREATE TABLE tests (
    test_id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(50),
    duration_minutes INT,
    total_marks INT
);

CREATE TABLE test_questions (
    test_id INT,
    q_id INT,
    FOREIGN KEY (test_id) REFERENCES tests(test_id),
    FOREIGN KEY (q_id) REFERENCES questions(q_id)
);

CREATE TABLE results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    test_id INT,
    score INT,
    date_attempted DATETIME,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (test_id) REFERENCES tests(test_id)
);

CREATE TABLE student_answers (
    result_id INT,
    q_id INT,
    selected_option CHAR(1),
    FOREIGN KEY (result_id) REFERENCES results(result_id),
    FOREIGN KEY (q_id) REFERENCES questions(q_id)
);
```

---

## 9. Module-to-Servlet Mapping

| Servlet | Responsibility |
|---|---|
| `RegisterServlet` | Insert new student record into `users` table |
| `LoginServlet` | Validate credentials, create session, redirect by role |
| `LogoutServlet` | Invalidate session |
| `AddQuestionServlet` | Insert new question into `questions` table |
| `CreateTestServlet` | Insert new test and link questions in `test_questions` |
| `StartTestServlet` | Fetch test questions, initialize session timer |
| `SubmitTestServlet` | Evaluate answers, calculate score, insert into `results` |
| `ViewResultsServlet` | Fetch and display results for admin/student |

---

## 10. Page (JSP) List

| Page | Purpose |
|---|---|
| `login.jsp` | Login form for admin/student |
| `register.jsp` | Student registration form |
| `adminDashboard.jsp` | Admin home â€” links to manage questions/tests/results |
| `addQuestion.jsp` | Form to add a question |
| `createTest.jsp` | Form to configure a new test |
| `studentDashboard.jsp` | List of available tests for student |
| `takeTest.jsp` | Displays questions with radio-button options and timer |
| `result.jsp` | Displays score after submission |
| `viewReport.jsp` | Admin view of all student results |

---

## 11. Assumptions and Constraints

- Only objective (MCQ) type questions are supported in this version.
- Each student can attempt a given test only once (can be relaxed if needed).
- The system assumes a stable internet/network connection during the exam (auto-submit handles disconnects only partially).
- No negative marking in the base version (can be added as an enhancement).

---

## 12. Future Enhancements

- Support for subjective/descriptive questions with manual grading
- Email notification of results
- Detailed analytics dashboard (subject-wise performance, graphs)
- Negative marking option
- Proctoring features (tab-switch detection, webcam monitoring)

---

## 13. Mapping to Lab Syllabus (Advance Java Lab â€” 5CAI4-24)

| Syllabus Experiment | Covered By |
|---|---|
| Exp 2: JDBC, java.sql Package | All database interactions (login, questions, results) |
| Exp 4: J2EE Architecture, n-tier concepts | Overall system architecture |
| Exp 5: Servlets, Session Handling, Filters | Login/session management, test submission, request-response handling |
| Exp 6: JSP, JSTL, Tag Libraries | Dynamic question rendering, result display |

---

## 14. Approval

| Role | Name | Signature | Date |
|---|---|---|---|
| Student | | | |
| Lab Instructor | | | |
