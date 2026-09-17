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
import java.util.List;

/**
 * Controller Servlet for Viewing Test Results and Generating Reports.
 * Admin view: comprehensive student attempt records per test.
 * Student view: past exam performance history.
 * Maps to /viewResults
 */
public class ViewResultsServlet extends HttpServlet {
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

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=Please+log+in");
            return;
        }

        User user = (User) session.getAttribute("user");

        try {
            if (user.isAdmin()) {
                // Admin Report View
                String testIdParam = request.getParameter("testId");
                int testId = -1;
                if (testIdParam != null && !testIdParam.trim().isEmpty()) {
                    try {
                        testId = Integer.parseInt(testIdParam);
                    } catch (NumberFormatException ignored) {
                    }
                }

                List<Test> allTests = testDAO.getAllTests();
                List<Result> results = resultDAO.getResultsByTest(testId);

                request.setAttribute("tests", allTests);
                request.setAttribute("selectedTestId", testId);
                request.setAttribute("results", results);

                request.getRequestDispatcher("viewReport.jsp").forward(request, response);
            } else {
                // Student View: My Results
                List<Result> results = resultDAO.getResultsByStudent(user.getUserId());
                request.setAttribute("results", results);
                request.getRequestDispatcher("viewReport.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            log("Database error loading results report", e);
            request.setAttribute("error", "Database error loading report data.");
            request.getRequestDispatcher("viewReport.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
