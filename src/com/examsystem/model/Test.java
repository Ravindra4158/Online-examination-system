package com.examsystem.model;

import java.io.Serializable;

/**
 * Model class representing a Test.
 */
public class Test implements Serializable {
    private static final long serialVersionUID = 1L;

    private int testId;
    private String subject;
    private int durationMinutes;
    private int totalMarks;
    
    // Auxiliary display fields
    private int questionCount;
    private boolean attempted;
    private Integer studentScore;

    public Test() {
    }

    public Test(int testId, String subject, int durationMinutes, int totalMarks) {
        this.testId = testId;
        this.subject = subject;
        this.durationMinutes = durationMinutes;
        this.totalMarks = totalMarks;
    }

    public Test(String subject, int durationMinutes, int totalMarks) {
        this.subject = subject;
        this.durationMinutes = durationMinutes;
        this.totalMarks = totalMarks;
    }

    public int getTestId() {
        return testId;
    }

    public void setTestId(int testId) {
        this.testId = testId;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public int getTotalMarks() {
        return totalMarks;
    }

    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public boolean isAttempted() {
        return attempted;
    }

    public void setAttempted(boolean attempted) {
        this.attempted = attempted;
    }

    public Integer getStudentScore() {
        return studentScore;
    }

    public void setStudentScore(Integer studentScore) {
        this.studentScore = studentScore;
    }
}
