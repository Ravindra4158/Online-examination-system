<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Test - TestVerse</title>
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
                    <h1 class="page-title">Assemble New Examination</h1>
                    <p class="page-subtitle">Configure test metadata and choose questions from the question bank.</p>
                </div>
            </div>

            <!-- Feedback Messages -->
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" role="alert">
                    <span>${param.error}</span>
                </div>
            </c:if>

            <form id="createTestForm" action="${pageContext.request.contextPath}/createTest" method="POST">
                <div class="form-row">
                    <div class="form-group" style="flex: 2;">
                        <label for="subject" class="form-label">Test Name / Subject</label>
                        <input type="text" id="subject" name="subject" class="form-control" 
                               placeholder="e.g. Java Programming Mid-Term" required>
                    </div>

                    <div class="form-group">
                        <label for="durationMinutes" class="form-label">Duration (Minutes)</label>
                        <input type="number" id="durationMinutes" name="durationMinutes" class="form-control" 
                               placeholder="15" min="1" max="180" value="15" required>
                    </div>

                    <div class="form-group">
                        <label for="totalMarks" class="form-label">Total Marks</label>
                        <input type="number" id="totalMarks" name="totalMarks" class="form-control" 
                               placeholder="10" min="1" max="1000" value="10" required>
                    </div>
                </div>

                <div class="card-header" style="margin-top: 1.5rem; margin-bottom: 0.75rem;">
                    <div>
                        <h2 class="page-title" style="font-size: 1.15rem;">Select Questions</h2>
                        <p class="page-subtitle">Select at least one question to include in this exam.</p>
                    </div>
                    <div id="selectionCounter" style="font-size: 0.9rem; font-weight: 600; color: var(--primary);">
                        0 questions selected
                    </div>
                </div>

                <c:choose>
                    <c:when test="${empty questions}">
                        <div class="alert alert-warning">
                            <span>No questions available in the question bank. 
                            <a href="${pageContext.request.contextPath}/addQuestion" style="color: var(--primary); font-weight: 600;">Add questions first</a>.</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-container" style="max-height: 400px; overflow-y: auto;">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th style="width: 50px; text-align: center;">
                                            <input type="checkbox" id="selectAllCheckbox" title="Select All">
                                        </th>
                                        <th style="width: 70px;">#ID</th>
                                        <th style="width: 120px;">Subject</th>
                                        <th>Question</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="q" items="${questions}">
                                        <tr>
                                            <td style="text-align: center;">
                                                <input type="checkbox" name="questionIds" value="${q.QId}" class="q-checkbox">
                                            </td>
                                            <td><strong>#<c:out value="${q.QId}"/></strong></td>
                                            <td><span class="role-badge admin"><c:out value="${q.subject}"/></span></td>
                                            <td><c:out value="${q.questionText}"/></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="form-actions">
                    <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="btn btn-secondary">Cancel</a>
                    <button type="submit" id="btnSubmitTest" class="btn btn-primary" disabled>
                        Assemble & Publish Test
                    </button>
                </div>
            </form>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) â€” TestVerse</p>
    </footer>

    <script>
        // Checkbox management: enable submit button only when >= 1 question is selected
        document.addEventListener("DOMContentLoaded", function () {
            const selectAll = document.getElementById("selectAllCheckbox");
            const checkboxes = document.querySelectorAll(".q-checkbox");
            const submitBtn = document.getElementById("btnSubmitTest");
            const counter = document.getElementById("selectionCounter");

            function updateCount() {
                let count = 0;
                checkboxes.forEach(cb => {
                    if (cb.checked) count++;
                });

                if (counter) {
                    counter.textContent = count + " question" + (count === 1 ? "" : "s") + " selected";
                }

                if (submitBtn) {
                    submitBtn.disabled = (count === 0);
                }
            }

            if (selectAll) {
                selectAll.addEventListener("change", function () {
                    checkboxes.forEach(cb => cb.checked = selectAll.checked);
                    updateCount();
                });
            }

            checkboxes.forEach(cb => {
                cb.addEventListener("change", updateCount);
            });

            updateCount();
        });
    </script>
</body>
</html>
