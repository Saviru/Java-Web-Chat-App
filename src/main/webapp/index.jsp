<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.chat.model.User"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0;url=login">
    <title>Chat Application</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background-color: #f4f4f4;
        }
        
        h1 {
            color: #3498db;
        }
        
        .loading {
            display: inline-block;
            width: 50px;
            height: 50px;
            border: 3px solid rgba(52, 152, 219, 0.3);
            border-radius: 50%;
            border-top-color: #3498db;
            animation: spin 1s ease-in-out infinite;
            margin: 20px auto;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        p {
            color: #7f8c8d;
        }
        
        a {
            display: inline-block;
            margin-top: 20px;
            color: #3498db;
            text-decoration: none;
        }
        
        a:hover {
            text-decoration: underline;
        }
        
        .time-info {
            font-size: 12px;
            color: #95a5a6;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <h1>Welcome to Chat Application</h1>
    <div class="loading"></div>
    <p>Redirecting you to the login page...</p>
    <a href="login">Click here if you are not redirected automatically</a>
    <p class="time-info">Current time: 2025-05-06 13:12:51 (UTC)</p>
    
    <%
        // Check if user is already logged in
        User currentUser = (User) session.getAttribute("user");
        if (currentUser != null) {
            // Redirect to chat page if already logged in
            response.sendRedirect("chat.jsp");
        }
    %>
</body>
</html>