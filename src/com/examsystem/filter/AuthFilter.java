package com.examsystem.filter;

import com.examsystem.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication and Role-based Authorization Filter.
 * Intercepts requests to enforce session presence and role boundaries.
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization if needed
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Prevent browser caching on authenticated pages
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // Public resources (allow unrestricted access)
        boolean isPublic = path.equals("/") ||
                           path.equals("/TestVerseSplash.jsp") ||
                           path.equals("/login.jsp") ||
                           path.equals("/register.jsp") ||
                           path.equals("/login") ||
                           path.equals("/register") ||
                           path.equals("/logout") ||
                           path.startsWith("/css/") ||
                           path.startsWith("/js/") ||
                           path.startsWith("/images/");

        if (isPublic) {
            chain.doFilter(req, res);
            return;
        }

        // Verify active session
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        if (user == null || role == null) {
            // Unauthenticated user attempting to access protected resource
            response.sendRedirect(contextPath + "/login.jsp?error=Please+log+in+first");
            return;
        }

        // Role-based Access Control
        boolean isAdminPath = path.contains("adminDashboard.jsp") ||
                              path.contains("addQuestion.jsp") ||
                              path.contains("createTest.jsp") ||
                              path.contains("viewReport.jsp") ||
                              path.equals("/addQuestion") ||
                              path.equals("/createTest");

        boolean isStudentPath = path.contains("studentDashboard.jsp") ||
                                path.contains("takeTest.jsp") ||
                                path.contains("result.jsp") ||
                                path.equals("/startTest") ||
                                path.equals("/submitTest");

        if (isAdminPath && !"admin".equalsIgnoreCase(role)) {
            // Student attempting to access Admin area
            response.sendRedirect(contextPath + "/studentDashboard.jsp?error=Unauthorized+access");
            return;
        }

        if (isStudentPath && "admin".equalsIgnoreCase(role)) {
            // Admin attempting to access Student test taking flow
            response.sendRedirect(contextPath + "/adminDashboard.jsp?error=Admins+cannot+take+exams");
            return;
        }

        // Seamlessly populate available tests and attempt records for studentDashboard.jsp without scriptlets
        if (path.contains("studentDashboard.jsp") && "student".equalsIgnoreCase(role)) {
            try {
                com.examsystem.dao.TestDAO testDAO = new com.examsystem.dao.TestDAO();
                com.examsystem.dao.ResultDAO resultDAO = new com.examsystem.dao.ResultDAO();
                java.util.List<com.examsystem.model.Test> tests = testDAO.getAllTests();
                for (com.examsystem.model.Test t : tests) {
                    com.examsystem.model.Result r = resultDAO.getStudentResultForTest(user.getUserId(), t.getTestId());
                    if (r != null) {
                        t.setAttempted(true);
                        t.setStudentScore(r.getScore());
                    }
                }
                request.setAttribute("tests", tests);
            } catch (Exception e) {
                request.setAttribute("error", "Error loading available tests.");
            }
        }

        // User is authenticated and authorized for this route
        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // Cleanup if needed
    }
}
