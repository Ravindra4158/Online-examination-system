package com.examsystem.dao;

import com.examsystem.model.Question;
import com.examsystem.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Question entities.
 * Handles CRUD operations for the question bank.
 */
public class QuestionDAO {

    /**
     * Adds a new question to the question bank.
     *
     * @param q Question object containing all options and correct answer
     * @return true if added successfully, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean addQuestion(Question q) throws SQLException {
        String sql = "INSERT INTO questions (subject, question_text, option_a, option_b, option_c, option_d, correct_option) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, q.getSubject().trim());
            ps.setString(2, q.getQuestionText().trim());
            ps.setString(3, q.getOptionA().trim());
            ps.setString(4, q.getOptionB().trim());
            ps.setString(5, q.getOptionC().trim());
            ps.setString(6, q.getOptionD().trim());
            ps.setString(7, q.getCorrectOption().trim().toUpperCase());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Retrieves all questions from the question bank.
     *
     * @return List of all questions
     * @throws SQLException if a database error occurs
     */
    public List<Question> getAllQuestions() throws SQLException {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT q_id, subject, question_text, option_a, option_b, option_c, option_d, correct_option "
                   + "FROM questions ORDER BY q_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Question q = new Question();
                q.setQId(rs.getInt("q_id"));
                q.setSubject(rs.getString("subject"));
                q.setQuestionText(rs.getString("question_text"));
                q.setOptionA(rs.getString("option_a"));
                q.setOptionB(rs.getString("option_b"));
                q.setOptionC(rs.getString("option_c"));
                q.setOptionD(rs.getString("option_d"));
                q.setCorrectOption(rs.getString("correct_option"));
                list.add(q);
            }
        }
        return list;
    }

    /**
     * Retrieves a single question by its ID.
     *
     * @param qId Question primary key
     * @return Question object or null
     * @throws SQLException if a database error occurs
     */
    public Question getQuestionById(int qId) throws SQLException {
        String sql = "SELECT q_id, subject, question_text, option_a, option_b, option_c, option_d, correct_option "
                   + "FROM questions WHERE q_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, qId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Question q = new Question();
                    q.setQId(rs.getInt("q_id"));
                    q.setSubject(rs.getString("subject"));
                    q.setQuestionText(rs.getString("question_text"));
                    q.setOptionA(rs.getString("option_a"));
                    q.setOptionB(rs.getString("option_b"));
                    q.setOptionC(rs.getString("option_c"));
                    q.setOptionD(rs.getString("option_d"));
                    q.setCorrectOption(rs.getString("correct_option"));
                    return q;
                }
            }
        }
        return null;
    }

    /**
     * Updates an existing question.
     *
     * @param q Question object with updated fields
     * @return true if updated successfully, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean updateQuestion(Question q) throws SQLException {
        String sql = "UPDATE questions SET subject = ?, question_text = ?, option_a = ?, option_b = ?, "
                   + "option_c = ?, option_d = ?, correct_option = ? WHERE q_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, q.getSubject().trim());
            ps.setString(2, q.getQuestionText().trim());
            ps.setString(3, q.getOptionA().trim());
            ps.setString(4, q.getOptionB().trim());
            ps.setString(5, q.getOptionC().trim());
            ps.setString(6, q.getOptionD().trim());
            ps.setString(7, q.getCorrectOption().trim().toUpperCase());
            ps.setInt(8, q.getQId());

            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Deletes a question from the question bank.
     *
     * @param qId Question primary key
     * @return true if deleted, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean deleteQuestion(int qId) throws SQLException {
        String sql = "DELETE FROM questions WHERE q_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, qId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Retrieves unique subjects from the question bank.
     *
     * @return List of subjects
     * @throws SQLException if a database error occurs
     */
    public List<String> getAllSubjects() throws SQLException {
        List<String> subjects = new ArrayList<>();
        String sql = "SELECT DISTINCT subject FROM questions ORDER BY subject";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                subjects.add(rs.getString("subject"));
            }
        }
        return subjects;
    }
}
