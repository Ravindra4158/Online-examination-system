<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Questions - TestVerse</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
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
                <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-secondary btn-sm">Dashboard</a>
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
                    <h1 class="page-title"><c:choose><c:when test="${not empty questionToEdit}">Edit Question</c:when><c:otherwise>Add New Question</c:otherwise></c:choose></h1>
                    <p class="page-subtitle">Add or update multiple choice questions in the central repository.</p>
                </div>
                <c:if test="${not empty questionToEdit}">
                    <a href="${pageContext.request.contextPath}/addQuestion" class="btn btn-secondary btn-sm">Cancel Edit</a>
                </c:if>
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

            <!-- Question Form -->
            <form action="${pageContext.request.contextPath}/addQuestion" method="POST">
                <c:choose>
                    <c:when test="${not empty questionToEdit}">
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="qId" value="${questionToEdit.QId}">
                    </c:when>
                    <c:otherwise>
                        <input type="hidden" name="action" value="add">
                    </c:otherwise>
                </c:choose>

                <div class="form-group">
                    <label for="subject" class="form-label">Subject / Topic</label>
                    <input type="text" id="subject" name="subject" class="form-control" 
                           placeholder="e.g. Java, DBMS, Operating Systems" 
                           value="${questionToEdit != null ? questionToEdit.subject : ''}" required>
                </div>

                <div class="form-group">
                    <label for="questionText" class="form-label">Question Text</label>
                    <textarea id="questionText" name="questionText" class="form-control" rows="3" 
                              placeholder="Enter the question description..." required><c:out value="${questionToEdit != null ? questionToEdit.questionText : ''}"/></textarea>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="optionA" class="form-label">Option A</label>
                        <input type="text" id="optionA" name="optionA" class="form-control" 
                               value="${questionToEdit != null ? questionToEdit.optionA : ''}" required>
                    </div>
                    <div class="form-group">
                        <label for="optionB" class="form-label">Option B</label>
                        <input type="text" id="optionB" name="optionB" class="form-control" 
                               value="${questionToEdit != null ? questionToEdit.optionB : ''}" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="optionC" class="form-label">Option C</label>
                        <input type="text" id="optionC" name="optionC" class="form-control" 
                               value="${questionToEdit != null ? questionToEdit.optionC : ''}" required>
                    </div>
                    <div class="form-group">
                        <label for="optionD" class="form-label">Option D</label>
                        <input type="text" id="optionD" name="optionD" class="form-control" 
                               value="${questionToEdit != null ? questionToEdit.optionD : ''}" required>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Mark Correct Option</label>
                    <div style="display: flex; gap: 2rem; padding: 0.5rem 0;">
                        <label style="display: flex; align-items: center; gap: 0.4rem; cursor: pointer;">
                            <input type="radio" name="correctOption" value="A" ${questionToEdit != null && questionToEdit.correctOption == 'A' ? 'checked' : ''} required>
                            <strong>Option A</strong>
                        </label>
                        <label style="display: flex; align-items: center; gap: 0.4rem; cursor: pointer;">
                            <input type="radio" name="correctOption" value="B" ${questionToEdit != null && questionToEdit.correctOption == 'B' ? 'checked' : ''}>
                            <strong>Option B</strong>
                        </label>
                        <label style="display: flex; align-items: center; gap: 0.4rem; cursor: pointer;">
                            <input type="radio" name="correctOption" value="C" ${questionToEdit != null && questionToEdit.correctOption == 'C' ? 'checked' : ''}>
                            <strong>Option C</strong>
                        </label>
                        <label style="display: flex; align-items: center; gap: 0.4rem; cursor: pointer;">
                            <input type="radio" name="correctOption" value="D" ${questionToEdit != null && questionToEdit.correctOption == 'D' ? 'checked' : ''}>
                            <strong>Option D</strong>
                        </label>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">
                        <c:choose>
                            <c:when test="${not empty questionToEdit}">Update Question</c:when>
                            <c:otherwise>Save to Question Bank</c:otherwise>
                        </c:choose>
                    </button>
                </div>
            </form>
        </div>

        <!-- Question Bank Listing -->
        <div class="content-card">
            <div class="card-header">
                <div>
                    <h2 class="page-title" style="font-size: 1.25rem;">Question Repository</h2>
                    <p class="page-subtitle">Total Questions: <c:out value="${questions.size()}"/></p>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty questions}">
                    <div class="empty-state">
                        <p>No questions found in the repository yet. Use the form above to add questions.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="table-container">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 60px;">#ID</th>
                                    <th style="width: 120px;">Subject</th>
                                    <th>Question</th>
                                    <th style="width: 80px;">Correct</th>
                                    <th style="width: 140px; text-align: right;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="q" items="${questions}">
                                    <tr>
                                        <td><strong>#<c:out value="${q.QId}"/></strong></td>
                                        <td><span class="role-badge admin"><c:out value="${q.subject}"/></span></td>
                                        <td><c:out value="${q.questionText}"/></td>
                                        <td><strong style="color: var(--success);"><c:out value="${q.correctOption}"/></strong></td>
                                        <td style="text-align: right;">
                                            <a href="${pageContext.request.contextPath}/addQuestion?action=edit&qId=${q.QId}" class="btn btn-secondary btn-sm" style="margin-right: 0.35rem;">Edit</a>
                                            <form action="${pageContext.request.contextPath}/addQuestion" method="POST" style="display: inline;" onsubmit="return confirm('Delete question #${q.QId}?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="qId" value="${q.QId}">
                                                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
                                            </form>
                                        </td>
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
