package com.examsystem.controller;

import com.examsystem.dao.UserDAO;
import com.examsystem.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Controller Servlet for User Authentication (Admin and Student).
 * Maps to /login
 */
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // If user already logged in, redirect directly to their dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            String role = (String) session.getAttribute("role");
            if ("admin".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp");
                return;
            }
        }

        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.validateUser(email, password);

            if (user != null) {
                // Invalidate old session to prevent session fixation attacks
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                // Create fresh session
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                session.setAttribute("role", user.getRole());

                // Role-based Post-Redirect-Get
                if (user.isAdmin()) {
                    response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp");
                } else {
                    response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp");
                }
            } else {
                request.setAttribute("error", "Invalid email or password.");
                request.setAttribute("email", email);
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            log("Database error during login", e);
            request.setAttribute("error", "Database connection error. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
