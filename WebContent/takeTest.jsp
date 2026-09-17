<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination in Progress - <c:out value="${test.subject}"/></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <!-- Sticky Exam Header with Countdown Timer -->
    <div class="exam-sticky-header">
        <div class="exam-subject-info">
            <h2><c:out value="${test.subject}"/></h2>
            <p>Total Questions: <c:out value="${questions.size()}"/> | Total Marks: <c:out value="${test.totalMarks}"/></p>
        </div>

        <div id="timerBox" class="timer-box">
            <span class="timer-label">Time Left</span>
            <span id="timerDisplay" class="timer-display" data-seconds="${test.durationMinutes * 60}">--:--</span>
        </div>
    </div>

    <!-- Timeout Auto-Submit Banner (hidden initially) -->
    <div id="timeoutBanner" class="alert alert-warning" style="display: none; margin: 1rem auto; max-width: 900px; text-align: center; font-weight: 700;">
        ⚠️ Time's up! Automatically submitting your answers...
    </div>

    <main class="main-content" style="padding-top: 1.5rem;">
        <div class="content-card">
            <!-- Progress Tracker -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                <span style="font-size: 0.9rem; font-weight: 600; color: var(--text-main);">Exam Progress</span>
                <span id="progressText" style="font-size: 0.85rem; color: var(--text-muted);">0 of <c:out value="${questions.size()}"/> answered</span>
            </div>
            <div class="progress-indicator">
                <div id="progressFill" class="progress-bar-fill"></div>
            </div>

            <!-- Exam Questions Form -->
            <form id="examForm" action="${pageContext.request.contextPath}/submitTest" method="POST">
                <c:forEach var="q" items="${questions}" varStatus="status">
                    <div class="question-block" id="question-${q.QId}">
                        <div class="question-title">
                            <span style="color: var(--primary); font-weight: 700;">Q<c:out value="${status.count}"/>.</span> 
                            <c:out value="${q.questionText}"/>
                        </div>

                        <div class="options-list">
                            <label class="option-item" for="q_${q.QId}_A">
                                <input type="radio" id="q_${q.QId}_A" name="answer_${q.QId}" value="A">
                                <span class="option-text"><strong>A.</strong> <c:out value="${q.optionA}"/></span>
                            </label>

                            <label class="option-item" for="q_${q.QId}_B">
                                <input type="radio" id="q_${q.QId}_B" name="answer_${q.QId}" value="B">
                                <span class="option-text"><strong>B.</strong> <c:out value="${q.optionB}"/></span>
                            </label>

                            <label class="option-item" for="q_${q.QId}_C">
                                <input type="radio" id="q_${q.QId}_C" name="answer_${q.QId}" value="C">
                                <span class="option-text"><strong>C.</strong> <c:out value="${q.optionC}"/></span>
                            </label>

                            <label class="option-item" for="q_${q.QId}_D">
                                <input type="radio" id="q_${q.QId}_D" name="answer_${q.QId}" value="D">
                                <span class="option-text"><strong>D.</strong> <c:out value="${q.optionD}"/></span>
                            </label>
                        </div>
                    </div>
                </c:forEach>

                <div class="form-actions" style="justify-content: space-between; align-items: center; margin-top: 2rem; border-top: 1px solid var(--border); padding-top: 1.5rem;">
                    <div style="font-size: 0.85rem; color: var(--text-muted);">
                        Clicking submit will finalize your attempt and calculate your score immediately.
                    </div>
                    <button type="submit" id="btnSubmitExam" class="btn btn-success" style="padding: 0.75rem 2rem; font-size: 1.05rem;">
                        Submit Examination
                    </button>
                </div>
            </form>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) — Online Examination System</p>
    </footer>

    <!-- Timer & Exam UX script -->
    <script src="${pageContext.request.contextPath}/js/timer.js"></script>
</body>
</html>
