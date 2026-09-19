<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - TestVerse</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <main class="main-content" style="justify-content: center;">
        <div class="content-card content-card-sm">
            <div class="card-header" style="text-align: center; display: block; border-bottom: none; margin-bottom: 1.25rem;">
                <div class="brand-icon" style="margin: 0 auto 0.75rem; width: 44px; height: 44px; font-size: 22px;">TV</div>
                <h1 class="page-title">Sign In</h1>
                <p class="page-subtitle">TestVerse</p>
            </div>

            <!-- Error Banners -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <span>${error}</span>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger" role="alert">
                    <span>${param.error}</span>
                </div>
            </c:if>

            <!-- Success Banners -->
            <c:if test="${param.registered eq 'true'}">
                <div class="alert alert-success" role="alert">
                    <span>Registration successful! Please log in with your credentials.</span>
                </div>
            </c:if>
            <c:if test="${param.loggedOut eq 'true'}">
                <div class="alert alert-success" role="alert">
                    <span>You have been logged out successfully.</span>
                </div>
            </c:if>

            <!-- Login Form -->
            <form action="${pageContext.request.contextPath}/login" method="POST">
                <div class="form-group">
                    <label for="email" class="form-label">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           value="${email != null ? email : ''}" placeholder="name@domain.com" required autofocus>
                </div>

                <div class="form-group">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢" required>
                </div>

                <div class="form-group" style="margin-top: 1.5rem;">
                    <button type="submit" id="btnLogin" class="btn btn-primary btn-full">Login</button>
                </div>
            </form>

            <div style="text-align: center; margin-top: 1.5rem; font-size: 0.9rem; color: var(--text-muted);">
                Don't have an account? 
                <a href="${pageContext.request.contextPath}/register.jsp" style="color: var(--primary); font-weight: 600; text-decoration: none;">Register as Student</a>
            </div>
        </div>
    </main>

    <footer class="app-footer">
        <p>&copy; Advance Java Lab (5CAI4-24) â€” TestVerse</p>
    </footer>
</body>
</html>
