<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - TestVerse</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Authenticated Header -->
    <header class="app-header">
        <div class="header-container">
            <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="brand-link">
                <div class="brand-icon">TV</div>
                <span class="brand-title">TestVerse</span>
            </a>
            <div class="user-nav">
                <div class="user-profile">
                    <span class="user-name"><c:out value="${sessionScope.user.name}"/></span>
                    <span class="role-badge admin">Admin</span>
                </div>
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
                    <h1 class="page-title">Administrator Dashboard</h1>
                    <p class="page-subtitle">Manage examination question banks, assemble tests, and inspect student reports.</p>
                </div>
            </div>

            <!-- Feedback Messages -->
            <c:if test="${not empty param.msg}">
                <div class="alert alert-success" role="alert">
                    <span>${param.msg}</span>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" role="alert">
                    <span>${param.error}</span>
                </div>
            </c:if>

            <!-- Dashboard Action Grid -->
            <div class="dashboard-grid">
                <!-- Manage Questions Card -->
                <div class="dash-card">
                    <div>
                        <div class="dash-card-icon">ðŸ“š</div>
                        <h2 class="dash-card-title">Manage Questions</h2>
                        <p class="dash-card-desc">Add new multiple-choice questions, update options, or delete items from the central question bank.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/addQuestion" class="btn btn-primary btn-full">Open Question Bank</a>
                </div>

                <!-- Create Test Card -->
                <div class="dash-card">
                    <div>
                        <div class="dash-card-icon">ðŸ“</div>
                        <h2 class="dash-card-title">Create Test</h2>
                        <p class="dash-card-desc">Assemble timed tests by setting subjects, time limits, total marks, and picking questions from the repository.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/createTest" class="btn btn-primary btn-full">Assemble New Test</a>
                </div>

                <!-- View Reports Card -->
                <div class="dash-card">
                    <div>
                        <div class="dash-card-icon">ðŸ“Š</div>
                        <h2 class="dash-card-title">View Reports</h2>
                        <p class="dash-card-desc">Review student test submission records, calculate score distributions, and monitor exam performance.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/viewResults" class="btn btn-primary btn-full">View Exam Reports</a>
                </div>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) â€” TestVerse</p>
    </footer>
</body>
</html>
