<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${sessionScope.role eq 'admin'}">Exam Performance Reports</c:when><c:otherwise>My Exam Results</c:otherwise></c:choose> - TestVerse</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <header class="app-header">
        <div class="header-container">
            <a href="${pageContext.request.contextPath}/${sessionScope.role eq 'admin' ? 'adminDashboard.jsp' : 'studentDashboard.jsp'}" class="brand-link">
                <div class="brand-icon">TV</div>
                <span class="brand-title">TestVerse</span>
            </a>
            <div class="user-nav">
                <div class="user-profile">
                    <span class="user-name"><c:out value="${sessionScope.user.name}"/></span>
                    <span class="role-badge ${sessionScope.role eq 'admin' ? 'admin' : 'student'}"><c:out value="${sessionScope.role}"/></span>
                </div>
                <a href="${pageContext.request.contextPath}/${sessionScope.role eq 'admin' ? 'adminDashboard.jsp' : 'studentDashboard.jsp'}" class="btn btn-secondary btn-sm">Dashboard</a>
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
                    <h1 class="page-title">
                        <c:choose>
                            <c:when test="${sessionScope.role eq 'admin'}">Student Examination Reports</c:when>
                            <c:otherwise>My Test Performance History</c:otherwise>
                        </c:choose>
                    </h1>
                    <p class="page-subtitle">
                        <c:choose>
                            <c:when test="${sessionScope.role eq 'admin'}">Inspect student attempts, scores, and completion timestamps.</c:when>
                            <c:otherwise>Summary of all your completed examinations and scores.</c:otherwise>
                        </c:choose>
                    </p>
                </div>

                <!-- Admin Test Filter Dropdown -->
                <c:if test="${sessionScope.role eq 'admin'}">
                    <form action="${pageContext.request.contextPath}/viewResults" method="GET" style="display: flex; gap: 0.5rem; align-items: center;">
                        <label for="filterTestId" class="form-label" style="margin-bottom: 0; white-space: nowrap;">Filter Test:</label>
                        <select id="filterTestId" name="testId" class="form-control" style="width: auto;" onchange="this.form.submit();">
                            <option value="">-- All Tests --</option>
                            <c:forEach var="t" items="${tests}">
                                <option value="${t.testId}" ${selectedTestId == t.testId ? 'selected' : ''}>
                                    <c:out value="${t.subject}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </form>
                </c:if>
            </div>

            <!-- Error Banner -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <span>${error}</span>
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty results}">
                    <div class="empty-state">
                        <div style="font-size: 2.5rem; margin-bottom: 0.75rem;">ðŸ“Š</div>
                        <h3 style="color: var(--text-main); margin-bottom: 0.5rem;">No Examination Records Found</h3>
                        <p>No student submissions have been recorded for the selected criteria.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 60px;">#ID</th>
                                    <c:if test="${sessionScope.role eq 'admin'}">
                                        <th>Student Name</th>
                                        <th>Email</th>
                                    </c:if>
                                    <th>Examination / Subject</th>
                                    <th style="width: 110px;">Score</th>
                                    <th style="width: 100px;">Percentage</th>
                                    <th style="width: 180px;">Date Attempted</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="r" items="${results}">
                                    <tr>
                                        <td><strong>#<c:out value="${r.resultId}"/></strong></td>
                                        <c:if test="${sessionScope.role eq 'admin'}">
                                            <td><strong><c:out value="${r.studentName}"/></strong></td>
                                            <td><c:out value="${r.studentEmail}"/></td>
                                        </c:if>
                                        <td><span class="role-badge admin"><c:out value="${r.testSubject}"/></span></td>
                                        <td>
                                            <strong><c:out value="${r.score}"/></strong> / <c:out value="${r.totalMarks}"/>
                                        </td>
                                        <td>
                                            <c:set var="pct" value="${r.percentage}"/>
                                            <span style="font-weight: 700; color: <c:choose><c:when test="${pct >= 60}">var(--success)</c:when><c:when test="${pct >= 40}">var(--warning)</c:when><c:otherwise>var(--danger)</c:otherwise></c:choose>;">
                                                <fmt:formatNumber value="${pct}" maxFractionDigits="1"/>%
                                            </span>
                                        </td>
                                        <td><c:out value="${r.dateAttempted}"/></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) â€” TestVerse</p>
    </footer>
</body>
</html>
