package com.examsystem.dao;

import com.examsystem.model.Question;
import com.examsystem.model.Test;
import com.examsystem.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Test entities and Test-Question mappings.
 */
public class TestDAO {

    /**
     * Creates a new test and links the selected question IDs within a single database transaction.
     *
     * @param test Test details (subject, duration, total marks)
     * @param questionIds List of selected question primary keys
     * @return Generated testId on success, or -1 on failure
     * @throws SQLException if a database error occurs
     */
    public int createTest(Test test, List<Integer> questionIds) throws SQLException {
        String testSql = "INSERT INTO tests (subject, duration_minutes, total_marks) VALUES (?, ?, ?)";
        String linkSql = "INSERT INTO test_questions (test_id, q_id) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Begin transaction

            int generatedTestId = -1;
            try (PreparedStatement psTest = conn.prepareStatement(testSql, Statement.RETURN_GENERATED_KEYS)) {
                psTest.setString(1, test.getSubject().trim());
                psTest.setInt(2, test.getDurationMinutes());
                psTest.setInt(3, test.getTotalMarks());
                psTest.executeUpdate();

                try (ResultSet rs = psTest.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedTestId = rs.getInt(1);
                    }
                }
            }

            if (generatedTestId <= 0) {
                conn.rollback();
                return -1;
            }

            // Link questions
            if (questionIds != null && !questionIds.isEmpty()) {
                try (PreparedStatement psLink = conn.prepareStatement(linkSql)) {
                    for (int qId : questionIds) {
                        psLink.setInt(1, generatedTestId);
                        psLink.setInt(2, qId);
                        psLink.addBatch();
                    }
                    psLink.executeBatch();
                }
            }

            conn.commit(); // Commit transaction
            return generatedTestId;
        } catch (SQLException e) {
            throw e;
        }
    }

    /**
     * Retrieves all tests with their total assigned question count.
     *
     * @return List of tests
     * @throws SQLException if a database error occurs
     */
    public List<Test> getAllTests() throws SQLException {
        List<Test> list = new ArrayList<>();
        String sql = "SELECT t.test_id, t.subject, t.duration_minutes, t.total_marks, "
                   + "COUNT(tq.q_id) AS question_count "
                   + "FROM tests t "
                   + "LEFT JOIN test_questions tq ON t.test_id = tq.test_id "
                   + "GROUP BY t.test_id, t.subject, t.duration_minutes, t.total_marks "
                   + "ORDER BY t.test_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Test t = new Test();
                t.setTestId(rs.getInt("test_id"));
                t.setSubject(rs.getString("subject"));
                t.setDurationMinutes(rs.getInt("duration_minutes"));
                t.setTotalMarks(rs.getInt("total_marks"));
                t.setQuestionCount(rs.getInt("question_count"));
                list.add(t);
            }
        }
        return list;
    }

    /**
     * Retrieves a test by its ID.
     *
     * @param testId Test primary key
     * @return Test object or null
     * @throws SQLException if a database error occurs
     */
    public Test getTestById(int testId) throws SQLException {
        String sql = "SELECT t.test_id, t.subject, t.duration_minutes, t.total_marks, "
                   + "COUNT(tq.q_id) AS question_count "
                   + "FROM tests t "
                   + "LEFT JOIN test_questions tq ON t.test_id = tq.test_id "
                   + "WHERE t.test_id = ? "
                   + "GROUP BY t.test_id, t.subject, t.duration_minutes, t.total_marks";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, testId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Test t = new Test();
                    t.setTestId(rs.getInt("test_id"));
                    t.setSubject(rs.getString("subject"));
                    t.setDurationMinutes(rs.getInt("duration_minutes"));
                    t.setTotalMarks(rs.getInt("total_marks"));
                    t.setQuestionCount(rs.getInt("question_count"));
                    return t;
                }
            }
        }
        return null;
    }

    /**
     * Loads all questions linked to a specific test.
     * CRITICAL SECURITY RULE: If hideCorrectOption is true (when student attempts the exam),
     * the correct_option field is cleared (null) to prevent any answer leakage.
     *
     * @param testId Test primary key
     * @param hideCorrectOption If true, blanks out the correct answer
     * @return List of questions for the test
     * @throws SQLException if a database error occurs
     */
    public List<Question> getQuestionsForTest(int testId, boolean hideCorrectOption) throws SQLException {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q.q_id, q.subject, q.question_text, q.option_a, q.option_b, q.option_c, q.option_d, "
                   + (hideCorrectOption ? "NULL as correct_option " : "q.correct_option ")
                   + "FROM questions q "
                   + "INNER JOIN test_questions tq ON q.q_id = tq.q_id "
                   + "WHERE tq.test_id = ? "
                   + "ORDER BY q.q_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, testId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Question q = new Question();
                    q.setQId(rs.getInt("q_id"));
                    q.setSubject(rs.getString("subject"));
                    q.setQuestionText(rs.getString("question_text"));
                    q.setOptionA(rs.getString("option_a"));
                    q.setOptionB(rs.getString("option_b"));
                    q.setOptionC(rs.getString("option_c"));
                    q.setOptionD(rs.getString("option_d"));
                    q.setCorrectOption(rs.getString("correct_option")); // Null if hidden
                    list.add(q);
                }
            }
        }
        return list;
    }

    /**
     * Deletes a test and its mappings.
     *
     * @param testId Test primary key
     * @return true if deleted
     * @throws SQLException if a database error occurs
     */
    public boolean deleteTest(int testId) throws SQLException {
        String sql = "DELETE FROM tests WHERE test_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, testId);
            return ps.executeUpdate() > 0;
        }
    }
}
