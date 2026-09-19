<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Result - TestVerse</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <header class="app-header">
        <div class="header-container">
            <a href="${pageContext.request.contextPath}/studentDashboard.jsp" class="brand-link">
                <div class="brand-icon">TV</div>
                <span class="brand-title">TestVerse</span>
            </a>
            <div class="user-nav">
                <div class="user-profile">
                    <span class="user-name"><c:out value="${sessionScope.user.name}"/></span>
                    <span class="role-badge student">Student</span>
                </div>
                <a href="${pageContext.request.contextPath}/studentDashboard.jsp" class="btn btn-secondary btn-sm">Dashboard</a>
                <form action="${pageContext.request.contextPath}/logout" method="POST" style="margin: 0;">
                    <button type="submit" class="btn btn-secondary btn-sm">Logout</button>
                </form>
            </div>
        </div>
    </header>

    <main class="main-content">
        <div class="content-card content-card-sm" style="max-width: 580px;">
            <div class="result-box">
                <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">ðŸŽ¯</div>
                <h1 class="page-title">Examination Completed</h1>
                <p class="page-subtitle"><c:out value="${result.testSubject}"/></p>

                <!-- Color-Coded Score Calculation -->
                <!-- Green: >= 60%, Amber: 40-59%, Red: < 40% -->
                <c:set var="pct" value="${result.percentage}"/>
                <div class="score-display <c:choose><c:when test="${pct >= 60.0}">score-green</c:when><c:when test="${pct >= 40.0}">score-amber</c:when><c:otherwise>score-red</c:otherwise></c:choose>">
                    <c:out value="${result.score}"/> / <c:out value="${result.totalMarks}"/>
                </div>

                <div class="result-meta">
                    <p>Percentage: <strong><fmt:formatNumber value="${pct}" maxFractionDigits="1"/>%</strong></p>
                    <p style="font-size: 0.95rem; margin-top: 0.35rem;">
                        Status: 
                        <c:choose>
                            <c:when test="${pct >= 60.0}">
                                <span class="role-badge" style="background-color: var(--success-bg); color: var(--success);">First Division / Pass</span>
                            </c:when>
                            <c:when test="${pct >= 40.0}">
                                <span class="role-badge" style="background-color: var(--warning-bg); color: var(--warning);">Pass</span>
                            </c:when>
                            <c:otherwise>
                                <span class="role-badge" style="background-color: var(--danger-bg); color: var(--danger);">Needs Improvement</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                    <c:if test="${not empty result.dateAttempted}">
                        <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.5rem;">
                            Submitted on: <c:out value="${result.dateAttempted}"/>
                        </p>
                    </c:if>
                </div>

                <div style="margin-top: 2rem;">
                    <a href="${pageContext.request.contextPath}/studentDashboard.jsp" class="btn btn-primary btn-full">
                        Return to Student Dashboard
                    </a>
                </div>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) â€” TestVerse</p>
    </footer>
</body>
</html>
