package com.examsystem.controller;

import com.examsystem.dao.ResultDAO;
import com.examsystem.dao.TestDAO;
import com.examsystem.model.Question;
import com.examsystem.model.Test;
import com.examsystem.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Controller Servlet to initialize and start an exam attempt for a student.
 * Maps to /startTest
 */
public class StartTestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TestDAO testDAO;
    private ResultDAO resultDAO;

    @Override
    public void init() {
        testDAO = new TestDAO();
        resultDAO = new ResultDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+log+in");
            return;
        }

        User user = (User) session.getAttribute("user");
        String testIdParam = request.getParameter("testId");

        if (testIdParam == null || testIdParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=No+test+specified");
            return;
        }

        try {
            int testId = Integer.parseInt(testIdParam);
            Test test = testDAO.getTestById(testId);

            if (test == null) {
                response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=Test+not+found");
                return;
            }

            // Verify one attempt rule: check if student has already attempted this test
            if (resultDAO.hasStudentAttempted(user.getUserId(), testId)) {
                response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=You+have+already+attempted+this+test");
                return;
            }

            // CRITICAL: Fetch questions with hideCorrectOption = true to guarantee zero answer leakage
            List<Question> questions = testDAO.getQuestionsForTest(testId, true);

            if (questions.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=This+test+has+no+questions+configured");
                return;
            }

            // Set session attributes for timer tracking and submission validation
            session.setAttribute("currentTestId", testId);
            session.setAttribute("startTime", System.currentTimeMillis());

            request.setAttribute("test", test);
            request.setAttribute("questions", questions);

            request.getRequestDispatcher("takeTest.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=Invalid+test+ID");
        } catch (SQLException e) {
            log("Database error in StartTestServlet", e);
            response.sendRedirect(request.getContextPath() + "/studentDashboard.jsp?error=Database+error+starting+test");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
