package com.examsystem.controller;

import com.examsystem.dao.QuestionDAO;
import com.examsystem.model.Question;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Controller Servlet for Admin Question Management (CRUD).
 * Maps to /addQuestion
 */
public class AddQuestionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private QuestionDAO questionDAO;

    @Override
    public void init() {
        questionDAO = new QuestionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String qIdParam = request.getParameter("qId");

        try {
            // Edit question view pre-population
            if ("edit".equalsIgnoreCase(action) && qIdParam != null) {
                int qId = Integer.parseInt(qIdParam);
                Question questionToEdit = questionDAO.getQuestionById(qId);
                request.setAttribute("questionToEdit", questionToEdit);
            }

            // Load all questions for the management table
            List<Question> questions = questionDAO.getAllQuestions();
            request.setAttribute("questions", questions);

            request.getRequestDispatcher("addQuestion.jsp").forward(request, response);
        } catch (SQLException e) {
            log("Error fetching questions in AddQuestionServlet", e);
            request.setAttribute("error", "Database error loading questions.");
            request.getRequestDispatcher("addQuestion.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if ("delete".equalsIgnoreCase(action)) {
                String qIdParam = request.getParameter("qId");
                if (qIdParam != null) {
                    int qId = Integer.parseInt(qIdParam);
                    questionDAO.deleteQuestion(qId);
                    response.sendRedirect(request.getContextPath() + "/addQuestion?msg=Question+deleted+successfully");
                    return;
                }
            } else if ("update".equalsIgnoreCase(action)) {
                int qId = Integer.parseInt(request.getParameter("qId"));
                String subject = request.getParameter("subject");
                String questionText = request.getParameter("questionText");
                String optionA = request.getParameter("optionA");
                String optionB = request.getParameter("optionB");
                String optionC = request.getParameter("optionC");
                String optionD = request.getParameter("optionD");
                String correctOption = request.getParameter("correctOption");

                if (isInvalid(subject, questionText, optionA, optionB, optionC, optionD, correctOption)) {
                    response.sendRedirect(request.getContextPath() + "/addQuestion?error=All+fields+are+required&action=edit&qId=" + qId);
                    return;
                }

                Question q = new Question(qId, subject, questionText, optionA, optionB, optionC, optionD, correctOption);
                questionDAO.updateQuestion(q);
                response.sendRedirect(request.getContextPath() + "/addQuestion?msg=Question+updated+successfully");
                return;
            } else {
                // Add new question
                String subject = request.getParameter("subject");
                String questionText = request.getParameter("questionText");
                String optionA = request.getParameter("optionA");
                String optionB = request.getParameter("optionB");
                String optionC = request.getParameter("optionC");
                String optionD = request.getParameter("optionD");
                String correctOption = request.getParameter("correctOption");

                if (isInvalid(subject, questionText, optionA, optionB, optionC, optionD, correctOption)) {
                    response.sendRedirect(request.getContextPath() + "/addQuestion?error=All+fields+including+correct+option+are+required");
                    return;
                }

                Question q = new Question(subject, questionText, optionA, optionB, optionC, optionD, correctOption);
                questionDAO.addQuestion(q);
                response.sendRedirect(request.getContextPath() + "/addQuestion?msg=Question+added+successfully");
                return;
            }
        } catch (SQLException | NumberFormatException e) {
            log("Error processing question in AddQuestionServlet", e);
            response.sendRedirect(request.getContextPath() + "/addQuestion?error=Database+error+processing+question");
        }
    }

    private boolean isInvalid(String subject, String text, String a, String b, String c, String d, String correct) {
        return subject == null || subject.trim().isEmpty() ||
               text == null || text.trim().isEmpty() ||
               a == null || a.trim().isEmpty() ||
               b == null || b.trim().isEmpty() ||
               c == null || c.trim().isEmpty() ||
               d == null || d.trim().isEmpty() ||
               correct == null || correct.trim().isEmpty();
    }
}
