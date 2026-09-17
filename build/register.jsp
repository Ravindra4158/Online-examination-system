<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Registration - Online Examination System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <main class="main-content" style="justify-content: center;">
        <div class="content-card content-card-sm">
            <div class="card-header" style="text-align: center; display: block; border-bottom: none; margin-bottom: 1.25rem;">
                <div class="brand-icon" style="margin: 0 auto 0.75rem; width: 44px; height: 44px; font-size: 22px;">OE</div>
                <h1 class="page-title">Student Registration</h1>
                <p class="page-subtitle">Create your student exam account</p>
            </div>

            <!-- Error Banner -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <span>${error}</span>
                </div>
            </c:if>

            <!-- Registration Form -->
            <form action="${pageContext.request.contextPath}/register" method="POST">
                <div class="form-group">
                    <label for="name" class="form-label">Full Name</label>
                    <input type="text" id="name" name="name" class="form-control" 
                           value="${name != null ? name : ''}" placeholder="e.g. Rahul Sharma" required autofocus>
                </div>

                <div class="form-group">
                    <label for="email" class="form-label">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           value="${email != null ? email : ''}" placeholder="name@domain.com" required>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="Minimum 6 characters" required minlength="6">
                </div>

                <div class="form-group">
                    <label for="confirmPassword" class="form-label">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                           placeholder="Re-enter password" required minlength="6">
                </div>

                <div class="form-group" style="margin-top: 1.5rem;">
                    <button type="submit" id="btnRegister" class="btn btn-primary btn-full">Register Account</button>
                </div>
            </form>

            <div style="text-align: center; margin-top: 1.5rem; font-size: 0.9rem; color: var(--text-muted);">
                Already registered? 
                <a href="${pageContext.request.contextPath}/login.jsp" style="color: var(--primary); font-weight: 600; text-decoration: none;">Sign In here</a>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) — Online Examination System</p>
    </footer>
</body>
</html>
