package com.examsystem.dao;

import com.examsystem.model.Result;
import com.examsystem.model.Test;
import com.examsystem.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for Test Results and Student Answers.
 * Encapsulates the business logic of evaluating student submissions.
 */
public class ResultDAO {

    /**
     * Evaluates student's answers against correct options stored in the database,
     * calculates the total score, and persists records in `results` and `student_answers`.
     * Executed within a single database transaction.
     *
     * @param userId Student user primary key
     * @param testId Test primary key
     * @param studentAnswers Map of question ID to student's chosen option ('A', 'B', 'C', 'D')
     * @return Result object containing calculated score and details
     * @throws SQLException if a database error occurs
     */
    public Result evaluateAndSave(int userId, int testId, Map<Integer, String> studentAnswers) throws SQLException {
        // Fetch test details for total marks
        TestDAO testDAO = new TestDAO();
        Test test = testDAO.getTestById(testId);
        if (test == null) {
            throw new IllegalArgumentException("Invalid test ID: " + testId);
        }

        // Fetch actual correct options from the database
        Map<Integer, String> correctAnswers = new HashMap<>();
        String fetchSql = "SELECT q.q_id, q.correct_option "
                        + "FROM questions q "
                        + "INNER JOIN test_questions tq ON q.q_id = tq.q_id "
                        + "WHERE tq.test_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement psFetch = conn.prepareStatement(fetchSql)) {
                psFetch.setInt(1, testId);
                try (ResultSet rs = psFetch.executeQuery()) {
                    while (rs.next()) {
                        correctAnswers.put(rs.getInt("q_id"), rs.getString("correct_option"));
                    }
                }
            }

            int totalQuestions = correctAnswers.size();
            int correctCount = 0;

            for (Map.Entry<Integer, String> entry : correctAnswers.entrySet()) {
                int qId = entry.getKey();
                String correctOpt = entry.getValue();
                String selectedOpt = studentAnswers != null ? studentAnswers.get(qId) : null;

                if (selectedOpt != null && selectedOpt.trim().equalsIgnoreCase(correctOpt.trim())) {
                    correctCount++;
                }
            }

            // Score calculation: proportional to total marks (e.g., 5 marks across 5 questions = 1 mark each)
            int finalScore;
            if (totalQuestions > 0) {
                double marksPerQuestion = (double) test.getTotalMarks() / totalQuestions;
                finalScore = (int) Math.round(correctCount * marksPerQuestion);
            } else {
                finalScore = 0;
            }

            // Begin atomic insertion
            conn.setAutoCommit(false);
            Timestamp now = new Timestamp(System.currentTimeMillis());
            int generatedResultId = -1;

            String resultSql = "INSERT INTO results (user_id, test_id, score, date_attempted) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psResult = conn.prepareStatement(resultSql, Statement.RETURN_GENERATED_KEYS)) {
                psResult.setInt(1, userId);
                psResult.setInt(2, testId);
                psResult.setInt(3, finalScore);
                psResult.setTimestamp(4, now);
                psResult.executeUpdate();

                try (ResultSet rs = psResult.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedResultId = rs.getInt(1);
                    }
                }
            }

            if (generatedResultId <= 0) {
                conn.rollback();
                throw new SQLException("Failed to create result record.");
            }

            // Record each student answer
            String answerSql = "INSERT INTO student_answers (result_id, q_id, selected_option) VALUES (?, ?, ?)";
            try (PreparedStatement psAnswer = conn.prepareStatement(answerSql)) {
                for (int qId : correctAnswers.keySet()) {
                    String selectedOpt = studentAnswers != null ? studentAnswers.get(qId) : null;
                    psAnswer.setInt(1, generatedResultId);
                    psAnswer.setInt(2, qId);
                    if (selectedOpt != null && !selectedOpt.trim().isEmpty()) {
                        psAnswer.setString(3, selectedOpt.trim().toUpperCase());
                    } else {
                        psAnswer.setNull(3, java.sql.Types.CHAR);
                    }
                    psAnswer.addBatch();
                }
                psAnswer.executeBatch();
            }

            conn.commit();

            // Assemble return object
            Result result = new Result();
            result.setResultId(generatedResultId);
            result.setUserId(userId);
            result.setTestId(testId);
            result.setScore(finalScore);
            result.setDateAttempted(now);
            result.setTestSubject(test.getSubject());
            result.setTotalMarks(test.getTotalMarks());

            return result;
        }
    }

    /**
     * Checks if a student has already attempted a specific test.
     *
     * @param userId Student user primary key
     * @param testId Test primary key
     * @return true if an attempt exists, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean hasStudentAttempted(int userId, int testId) throws SQLException {
        String sql = "SELECT 1 FROM results WHERE user_id = ? AND test_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, testId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Retrieves the latest result for a student on a specific test.
     *
     * @param userId Student ID
     * @param testId Test ID
     * @return Result or null
     * @throws SQLException if a database error occurs
     */
    public Result getStudentResultForTest(int userId, int testId) throws SQLException {
        String sql = "SELECT r.result_id, r.user_id, r.test_id, r.score, r.date_attempted, "
                   + "t.subject, t.total_marks "
                   + "FROM results r "
                   + "INNER JOIN tests t ON r.test_id = t.test_id "
                   + "WHERE r.user_id = ? AND r.test_id = ? "
                   + "ORDER BY r.result_id DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, testId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Result r = new Result();
                    r.setResultId(rs.getInt("result_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setTestId(rs.getInt("test_id"));
                    r.setScore(rs.getInt("score"));
                    r.setDateAttempted(rs.getTimestamp("date_attempted"));
                    r.setTestSubject(rs.getString("subject"));
                    r.setTotalMarks(rs.getInt("total_marks"));
                    return r;
                }
            }
        }
        return null;
    }

    /**
     * Retrieves all student attempts for a given test (Admin Report view).
     *
     * @param testId Test primary key (or -1 for all tests)
     * @return List of Result objects with student name and email
     * @throws SQLException if a database error occurs
     */
    public List<Result> getResultsByTest(int testId) throws SQLException {
        List<Result> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT r.result_id, r.user_id, r.test_id, r.score, r.date_attempted, ")
           .append("u.name AS student_name, u.email AS student_email, ")
           .append("t.subject AS test_subject, t.total_marks ")
           .append("FROM results r ")
           .append("INNER JOIN users u ON r.user_id = u.user_id ")
           .append("INNER JOIN tests t ON r.test_id = t.test_id ");

        if (testId > 0) {
            sql.append("WHERE r.test_id = ? ");
        }
        sql.append("ORDER BY r.date_attempted DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (testId > 0) {
                ps.setInt(1, testId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Result r = new Result();
                    r.setResultId(rs.getInt("result_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setTestId(rs.getInt("test_id"));
                    r.setScore(rs.getInt("score"));
                    r.setDateAttempted(rs.getTimestamp("date_attempted"));
                    r.setStudentName(rs.getString("student_name"));
                    r.setStudentEmail(rs.getString("student_email"));
                    r.setTestSubject(rs.getString("test_subject"));
                    r.setTotalMarks(rs.getInt("total_marks"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /**
     * Retrieves all attempts by a specific student.
     *
     * @param userId Student primary key
     * @return List of student's past exam results
     * @throws SQLException if a database error occurs
     */
    public List<Result> getResultsByStudent(int userId) throws SQLException {
        List<Result> list = new ArrayList<>();
        String sql = "SELECT r.result_id, r.user_id, r.test_id, r.score, r.date_attempted, "
                   + "t.subject AS test_subject, t.total_marks "
                   + "FROM results r "
                   + "INNER JOIN tests t ON r.test_id = t.test_id "
                   + "WHERE r.user_id = ? "
                   + "ORDER BY r.date_attempted DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Result r = new Result();
                    r.setResultId(rs.getInt("result_id"));
                    r.setUserId(rs.getInt("user_id"));
                    r.setTestId(rs.getInt("test_id"));
                    r.setScore(rs.getInt("score"));
                    r.setDateAttempted(rs.getTimestamp("date_attempted"));
                    r.setTestSubject(rs.getString("test_subject"));
                    r.setTotalMarks(rs.getInt("total_marks"));
                    list.add(r);
                }
            }
        }
        return list;
    }
}
