package com.examsystem.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model class representing a test evaluation Result.
 */
public class Result implements Serializable {
    private static final long serialVersionUID = 1L;

    private int resultId;
    private int userId;
    private int testId;
    private int score;
    private Timestamp dateAttempted;

    // Display fields for reports and summaries
    private String studentName;
    private String studentEmail;
    private String testSubject;
    private int totalMarks;

    public Result() {
    }

    public Result(int resultId, int userId, int testId, int score, Timestamp dateAttempted) {
        this.resultId = resultId;
        this.userId = userId;
        this.testId = testId;
        this.score = score;
        this.dateAttempted = dateAttempted;
    }

    public int getResultId() {
        return resultId;
    }

    public void setResultId(int resultId) {
        this.resultId = resultId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getTestId() {
        return testId;
    }

    public void setTestId(int testId) {
        this.testId = testId;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public Timestamp getDateAttempted() {
        return dateAttempted;
    }

    public void setDateAttempted(Timestamp dateAttempted) {
        this.dateAttempted = dateAttempted;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getTestSubject() {
        return testSubject;
    }

    public void setTestSubject(String testSubject) {
        this.testSubject = testSubject;
    }

    public int getTotalMarks() {
        return totalMarks;
    }

    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }

    public double getPercentage() {
        if (totalMarks <= 0) return 0.0;
        return ((double) score / totalMarks) * 100.0;
    }
}
