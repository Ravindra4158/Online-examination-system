package com.examsystem.controller;

import com.examsystem.dao.QuestionDAO;
import com.examsystem.dao.TestDAO;
import com.examsystem.model.Question;
import com.examsystem.model.Test;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Controller Servlet for Admin Test Creation and Question Linking.
 * Maps to /createTest
 */
public class CreateTestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TestDAO testDAO;
    private QuestionDAO questionDAO;

    @Override
    public void init() {
        testDAO = new TestDAO();
        questionDAO = new QuestionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Load available questions so admin can select which questions belong in the test
            List<Question> questions = questionDAO.getAllQuestions();
            request.setAttribute("questions", questions);
            request.getRequestDispatcher("createTest.jsp").forward(request, response);
        } catch (SQLException e) {
            log("Error loading questions for test creation", e);
            request.setAttribute("error", "Database error loading question bank.");
            request.getRequestDispatcher("createTest.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String subject = request.getParameter("subject");
        String durationParam = request.getParameter("durationMinutes");
        String marksParam = request.getParameter("totalMarks");
        String[] selectedQIds = request.getParameterValues("questionIds");

        // Server-side validation
        if (subject == null || subject.trim().isEmpty() ||
            durationParam == null || durationParam.trim().isEmpty() ||
            marksParam == null || marksParam.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/createTest?error=All+fields+are+required");
            return;
        }

        if (selectedQIds == null || selectedQIds.length == 0) {
            response.sendRedirect(request.getContextPath() + "/createTest?error=A+test+must+have+at+least+1+selected+question");
            return;
        }

        try {
            int duration = Integer.parseInt(durationParam);
            int totalMarks = Integer.parseInt(marksParam);

            if (duration <= 0 || totalMarks <= 0) {
                response.sendRedirect(request.getContextPath() + "/createTest?error=Duration+and+marks+must+be+greater+than+zero");
                return;
            }

            List<Integer> questionIds = new ArrayList<>();
            for (String qIdStr : selectedQIds) {
                questionIds.add(Integer.parseInt(qIdStr));
            }

            Test test = new Test(subject.trim(), duration, totalMarks);
            int testId = testDAO.createTest(test, questionIds);

            if (testId > 0) {
                response.sendRedirect(request.getContextPath() + "/adminDashboard.jsp?msg=Test+created+successfully+with+" + questionIds.size() + "+questions");
            } else {
                response.sendRedirect(request.getContextPath() + "/createTest?error=Failed+to+create+test");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/createTest?error=Invalid+numeric+input+for+duration+or+marks");
        } catch (SQLException e) {
            log("Error creating test in CreateTestServlet", e);
            response.sendRedirect(request.getContextPath() + "/createTest?error=Database+error+creating+test");
        }
    }
}
