/**
 * TestVerse - Exam Countdown Timer & Client UX Handler
 * Advance Java Lab (5CAI4-24), B.Tech CSE-AI, 3rd Year
 */

document.addEventListener("DOMContentLoaded", function () {
    const timerElement = document.getElementById("timerDisplay");
    const timerBox = document.getElementById("timerBox");
    const examForm = document.getElementById("examForm");
    const progressFill = document.getElementById("progressFill");
    const progressText = document.getElementById("progressText");
    const timeoutBanner = document.getElementById("timeoutBanner");

    if (!timerElement || !examForm) {
        return; // Not on the exam page
    }

    // Read duration in seconds passed from data attribute on the timer element
    let remainingSeconds = parseInt(timerElement.getAttribute("data-seconds"), 10);
    if (isNaN(remainingSeconds) || remainingSeconds <= 0) {
        remainingSeconds = 600; // 10 minutes fallback
    }

    let isSubmitted = false;

    function formatTime(totalSeconds) {
        const minutes = Math.floor(totalSeconds / 60);
        const seconds = totalSeconds % 60;
        const mm = String(minutes).padStart(2, '0');
        const ss = String(seconds).padStart(2, '0');
        return `${mm}:${ss}`;
    }

    function updateTimerDisplay() {
        timerElement.textContent = formatTime(remainingSeconds);

        // Color coding rules:
        // Normal (> 5 min): default gray
        // Amber (< 5 min / 300s): warning
        // Red (< 1 min / 60s): danger with pulse
        if (remainingSeconds <= 60) {
            timerBox.classList.remove("timer-warning");
            timerBox.classList.add("timer-danger");
        } else if (remainingSeconds <= 300) {
            timerBox.classList.remove("timer-danger");
            timerBox.classList.add("timer-warning");
        }
    }

    // Initialize display
    updateTimerDisplay();

    // Timer Interval
    const countdownInterval = setInterval(function () {
        if (isSubmitted) {
            clearInterval(countdownInterval);
            return;
        }

        remainingSeconds--;

        if (remainingSeconds <= 0) {
            clearInterval(countdownInterval);
            triggerAutoSubmit();
        } else {
            updateTimerDisplay();
        }
    }, 1000);

    function triggerAutoSubmit() {
        if (isSubmitted) return;
        isSubmitted = true;

        timerElement.textContent = "00:00";
        if (timeoutBanner) {
            timeoutBanner.style.display = "block";
            timeoutBanner.scrollIntoView({ behavior: "smooth" });
        }

        // Disable all inputs
        const allInputs = examForm.querySelectorAll("input, button");
        allInputs.forEach(input => {
            if (input.type !== "hidden") {
                input.disabled = true;
            }
        });

        // Submit form after brief visual feedback
        setTimeout(function () {
            examForm.submit();
        }, 1200);
    }

    // Manual Submit with Confirmation Dialog
    examForm.addEventListener("submit", function (e) {
        if (isSubmitted) return;

        const totalQuestions = document.querySelectorAll(".question-block").length;
        const answeredQuestions = getAnsweredCount();

        let confirmMsg = "Are you sure you want to submit your exam?";
        if (answeredQuestions < totalQuestions) {
            confirmMsg = `You have answered ${answeredQuestions} of ${totalQuestions} questions.\nUnanswered questions will be scored zero.\n\nAre you sure you want to submit?`;
        }

        if (!confirm(confirmMsg)) {
            e.preventDefault();
            return false;
        }

        isSubmitted = true;
        clearInterval(countdownInterval);
    });

    // Progress Tracking Logic
    function getAnsweredCount() {
        const questionBlocks = document.querySelectorAll(".question-block");
        let answered = 0;
        questionBlocks.forEach(block => {
            const checked = block.querySelector("input[type='radio']:checked");
            if (checked) {
                answered++;
            }
        });
        return answered;
    }

    function updateProgress() {
        const totalQuestions = document.querySelectorAll(".question-block").length;
        if (totalQuestions === 0) return;

        const answered = getAnsweredCount();
        const percentage = Math.round((answered / totalQuestions) * 100);

        if (progressFill) {
            progressFill.style.width = percentage + "%";
        }
        if (progressText) {
            progressText.textContent = `Question ${answered} of ${totalQuestions} answered (${percentage}%)`;
        }
    }

    // Listen to radio changes to update progress live
    const radioButtons = examForm.querySelectorAll("input[type='radio']");
    radioButtons.forEach(radio => {
        radio.addEventListener("change", updateProgress);
    });

    // Initialize progress counter
    updateProgress();
});
