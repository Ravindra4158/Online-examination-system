package com.examsystem.controller;

import com.examsystem.dao.ResultDAO;
import com.examsystem.dao.TestDAO;
import com.examsystem.model.Result;
import com.examsystem.model.Test;
import com.examsystem.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * Controller Servlet for evaluating and saving student test submissions.
 * Enforces server-side duration verification and session state validation.
 * Maps to /submitTest
 */
public class SubmitTestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ResultDAO resultDAO;
    private TestDAO testDAO;

    @Override
    public void init() {
        resultDAO = new ResultDAO();
        testDAO = new TestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Direct GET access to submit servlet is prohibited
        response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Session+expired");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Validate that currentTestId exists in session (prevents skipping exam flow)
        Integer sessionTestId = (Integer) session.getAttribute("currentTestId");
        Long startTime = (Long) session.getAttribute("startTime");

        if (sessionTestId == null || startTime == null) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=No+active+exam+session+found");
            return;
        }

        try {
            Test test = testDAO.getTestById(sessionTestId);
            if (test == null) {
                response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=Test+not+found");
                return;
            }

            // Server-side duration check: allow 90 seconds grace period for network latency / auto-submit delay
            long elapsedSeconds = (System.currentTimeMillis() - startTime) / 1000;
            long allowedSeconds = (test.getDurationMinutes() * 60L) + 90L;

            if (elapsedSeconds > allowedSeconds) {
                log("Warning: Exam submitted past allowed duration. Elapsed: " + elapsedSeconds + "s, Allowed: " + allowedSeconds + "s");
            }

            // Extract all student answers from form parameters (answer_<qId>)
            Map<Integer, String> studentAnswers = new HashMap<>();
            Enumeration<String> paramNames = request.getParameterNames();

            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                if (paramName.startsWith("answer_")) {
                    try {
                        int qId = Integer.parseInt(paramName.substring("answer_".length()));
                        String selectedOpt = request.getParameter(paramName);
                        if (selectedOpt != null && !selectedOpt.trim().isEmpty()) {
                            studentAnswers.put(qId, selectedOpt.trim().toUpperCase());
                        }
                    } catch (NumberFormatException ignored) {
                        // ignore malformed parameter names
                    }
                }
            }

            // Evaluate answers and save to results & student_answers tables
            Result result = resultDAO.evaluateAndSave(user.getUserId(), sessionTestId, studentAnswers);

            // Clean up exam session attributes so test cannot be resubmitted
            session.removeAttribute("currentTestId");
            session.removeAttribute("startTime");

            // Attach result and forward to result.jsp
            request.setAttribute("result", result);
            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (SQLException e) {
            log("Database error evaluating test submission", e);
            response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=Database+error+processing+exam+result");
        }
    }
}
