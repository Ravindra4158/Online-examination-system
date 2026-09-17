package com.examsystem.dao;

import com.examsystem.model.User;
import com.examsystem.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Data Access Object for User entities.
 * Handles registration, credential validation, and user lookups.
 */
public class UserDAO {

    /**
     * Registers a new student user.
     * Enforces that self-registered users are strictly 'student'.
     *
     * @param user User object containing name, email, and plain-text password
     * @return true if successfully inserted, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean registerUser(User user) throws SQLException {
        String sql = "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)";
        String hashedPassword = DBConnection.hashPassword(user.getPassword());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, hashedPassword);
            // Self-registration is strictly student
            ps.setString(4, "student");

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        }
    }

    /**
     * Validates user login credentials.
     *
     * @param email User email address
     * @param rawPassword Plain-text password entered at login
     * @return Populated User object if credentials are valid, null otherwise
     * @throws SQLException if a database error occurs
     */
    public User validateUser(String email, String rawPassword) throws SQLException {
        String sql = "SELECT user_id, name, email, role FROM users WHERE email = ? AND password = ?";
        String hashedPassword = DBConnection.hashPassword(rawPassword);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());
            ps.setString(2, hashedPassword);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }

    /**
     * Checks if an email is already registered in the system.
     *
     * @param email Email address to check
     * @return true if email exists, false otherwise
     * @throws SQLException if a database error occurs
     */
    public boolean emailExists(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Retrieves user by ID.
     *
     * @param userId User primary key
     * @return User object or null
     * @throws SQLException if a database error occurs
     */
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT user_id, name, email, role FROM users WHERE user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }
}
