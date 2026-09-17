package com.examsystem.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Utility class providing centralized JDBC Connection management and security utilities.
 * Advance Java Lab (5CAI4-24)
 */
public class DBConnection {
    // Database configuration
    private static final String DB_URL = "jdbc:mysql://localhost:3306/exam_system?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=UTF-8";
    private static final String DB_USER = "exam_user";
    private static final String DB_PASSWORD = "exam_pass_2024";

    static {
        try {
            // Load MySQL JDBC Driver
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            try {
                // Fallback for older MySQL connector versions
                Class.forName("com.mysql.jdbc.Driver");
            } catch (ClassNotFoundException ex) {
                System.err.println("CRITICAL: MySQL JDBC Driver not found in classpath!");
                ex.printStackTrace();
            }
        }
    }

    /**
     * Obtains a new database Connection.
     * Always use try-with-resources when calling this method.
     *
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    /**
     * Hashes a plain-text password using SHA-256 algorithm.
     *
     * @param password Plain-text password
     * @return 64-character lowercase hexadecimal hash string
     */
    public static String hashPassword(String password) {
        if (password == null) {
            return null;
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(password.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error: SHA-256 algorithm not available in this JVM environment", e);
        }
    }

    /**
     * Test utility method to verify database connectivity from console.
     */
    public static void main(String[] args) {
        System.out.println("Testing DB Connection...");
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("SUCCESS: Connected to MySQL database [exam_system] successfully!");
            }
        } catch (SQLException e) {
            System.err.println("FAILURE: Unable to connect to MySQL database: " + e.getMessage());
        }

        // Test hash utility
        System.out.println("Sample SHA-256 hash for 'admin123': " + hashPassword("admin123"));
    }
}
