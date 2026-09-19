-- ==========================================================
-- TestVerse Database Schema
-- Advance Java Lab (5CAI4-24), B.Tech CSE-AI, 3rd Year
-- Database: exam_system
-- ==========================================================

CREATE DATABASE IF NOT EXISTS exam_system;
USE exam_system;

-- 1. Users Table (Admin & Student)
DROP TABLE IF EXISTS student_answers;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS test_questions;
DROP TABLE IF EXISTS tests;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL -- 'admin' or 'student'
);

-- 2. Questions Bank Table
CREATE TABLE questions (
    q_id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(50) NOT NULL,
    question_text TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_option CHAR(1) NOT NULL -- 'A', 'B', 'C', or 'D'
);

-- 3. Tests Configuration Table
CREATE TABLE tests (
    test_id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL,
    total_marks INT NOT NULL
);

-- 4. Test-Question Mapping Table
CREATE TABLE test_questions (
    test_id INT NOT NULL,
    q_id INT NOT NULL,
    PRIMARY KEY (test_id, q_id),
    FOREIGN KEY (test_id) REFERENCES tests(test_id) ON DELETE CASCADE,
    FOREIGN KEY (q_id) REFERENCES questions(q_id) ON DELETE CASCADE
);

-- 5. Results Table
CREATE TABLE results (
    result_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    test_id INT NOT NULL,
    score INT NOT NULL,
    date_attempted DATETIME NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (test_id) REFERENCES tests(test_id) ON DELETE CASCADE
);

-- 6. Student Answers Table
CREATE TABLE student_answers (
    result_id INT NOT NULL,
    q_id INT NOT NULL,
    selected_option CHAR(1),
    PRIMARY KEY (result_id, q_id),
    FOREIGN KEY (result_id) REFERENCES results(result_id) ON DELETE CASCADE,
    FOREIGN KEY (q_id) REFERENCES questions(q_id) ON DELETE CASCADE
);

-- ==========================================================
-- SEED DATA
-- ==========================================================

-- Admin user (password is 'admin123' hashed with SHA-256)
INSERT INTO users (name, email, password, role)
VALUES ('Admin', 'admin@exam.com', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'admin');

-- Sample Student user (password is 'student123' hashed with SHA-256)
-- 'student123' -> 703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b
INSERT INTO users (name, email, password, role)
VALUES ('Rahul Sharma', 'rahul@student.com', '703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b', 'student');

-- Seed Sample Questions for Java & DBMS
INSERT INTO questions (subject, question_text, option_a, option_b, option_c, option_d, correct_option) VALUES
('Java', 'Which of these is not a Java primitive type?', 'int', 'float', 'String', 'boolean', 'C'),
('Java', 'What is the default value of an uninitialized boolean variable in Java?', 'true', 'false', '0', 'null', 'B'),
('Java', 'Which interface is used to define a class that can be executed by a thread?', 'Runnable', 'Callable', 'Threadable', 'Executable', 'A'),
('Java', 'Which keyword is used to prevent method overriding in Java?', 'static', 'final', 'const', 'protected', 'B'),
('Java', 'Which package contains the JDBC classes and interfaces like Connection and PreparedStatement?', 'java.io', 'java.util', 'java.sql', 'java.net', 'C'),
('DBMS', 'Which normal form deals with removing transitive functional dependencies?', '1NF', '2NF', '3NF', 'BCNF', 'C'),
('DBMS', 'In ACID properties, what does "I" stand for?', 'Integrity', 'Isolation', 'Inheritance', 'Idempotence', 'B'),
('DBMS', 'Which command is used to remove all rows from a table while keeping its structure?', 'DROP', 'DELETE', 'TRUNCATE', 'REMOVE', 'C');

-- Seed a Sample Test
INSERT INTO tests (subject, duration_minutes, total_marks) VALUES
('Core Java Basics', 10, 5);

-- Link first 5 Java questions to the sample test
INSERT INTO test_questions (test_id, q_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5);
