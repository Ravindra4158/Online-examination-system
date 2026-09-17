<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Online Examination System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <header class="app-header">
        <div class="header-container">
            <a href="${pageContext.request.contextPath}/studentDashboard.jsp" class="brand-link">
                <div class="brand-icon">OE</div>
                <span class="brand-title">ExamPortal</span>
            </a>
            <div class="user-nav">
                <div class="user-profile">
                    <span class="user-name"><c:out value="${sessionScope.user.name}"/></span>
                    <span class="role-badge student">Student</span>
                </div>
                <a href="${pageContext.request.contextPath}/viewResults" class="btn btn-secondary btn-sm">My Results</a>
                <form action="${pageContext.request.contextPath}/logout" method="POST" style="margin: 0;">
                    <button type="submit" class="btn btn-secondary btn-sm">Logout</button>
                </form>
            </div>
        </div>
    </header>

    <main class="main-content">
        <div class="content-card">
            <div class="card-header">
                <div>
                    <h1 class="page-title">Available Examinations</h1>
                    <p class="page-subtitle">Welcome, <c:out value="${sessionScope.user.name}"/>. Select an exam below to begin your timed attempt.</p>
                </div>
            </div>

            <!-- Feedback Messages -->
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" role="alert">
                    <span>${param.error}</span>
                </div>
            </c:if>
            <c:if test="${not empty param.msg}">
                <div class="alert alert-success" role="alert">
                    <span>${param.msg}</span>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty tests}">
                    <div class="empty-state">
                        <div style="font-size: 2.5rem; margin-bottom: 0.75rem;">📋</div>
                        <h3 style="color: var(--text-main); margin-bottom: 0.5rem;">No Tests Available Yet</h3>
                        <p>There are currently no active tests scheduled by the administrator. Please check back later.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="dashboard-grid">
                        <c:forEach var="test" items="${tests}">
                            <div class="dash-card">
                                <div>
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                                        <span class="role-badge admin"><c:out value="${test.subject}"/></span>
                                        <span style="font-size: 0.85rem; color: var(--text-muted); font-weight: 600;">
                                            ⏱ <c:out value="${test.durationMinutes}"/> mins
                                        </span>
                                    </div>
                                    <h2 class="dash-card-title"><c:out value="${test.subject}"/></h2>
                                    <div style="font-size: 0.9rem; color: var(--text-muted); margin-bottom: 1.25rem;">
                                        <p>Total Marks: <strong><c:out value="${test.totalMarks}"/></strong></p>
                                        <p>Questions: <strong><c:out value="${test.questionCount}"/></strong></p>
                                    </div>
                                </div>

                                <div>
                                    <c:choose>
                                        <c:when test="${test.attempted}">
                                            <div class="alert alert-success" style="margin-bottom: 0; padding: 0.65rem 0.85rem; justify-content: center; font-weight: 700;">
                                                ✓ Completed — Score: <c:out value="${test.studentScore}"/> / <c:out value="${test.totalMarks}"/>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="${pageContext.request.contextPath}/startTest" method="POST">
                                                <input type="hidden" name="testId" value="${test.testId}">
                                                <button type="submit" class="btn btn-primary btn-full">
                                                    Start Test →
                                                </button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) — Online Examination System</p>
    </footer>
</body>
</html>
