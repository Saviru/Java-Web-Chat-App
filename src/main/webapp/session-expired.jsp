<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Session Expired - Chat Application</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            text-align: center;
        }
        
        .session-container {
            background-color: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 500px;
        }
        
        h1 {
            color: #f39c12;
            margin-bottom: 15px;
        }
        
        .icon {
            font-size: 60px;
            color: #f39c12;
            margin-bottom: 20px;
        }
        
        p {
            color: #555;
            margin-bottom: 20px;
        }
        
        .login-link {
            display: inline-block;
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 3px;
            margin-top: 10px;
        }
        
        .login-link:hover {
            background-color: #2980b9;
        }
        
        .time-info {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="session-container">
        <div class="icon">⏰</div>
        <h1>Session Expired</h1>
        <p>Your session has expired due to inactivity.</p>
        <p>For your security, you've been logged out. Please log in again to continue using the Chat Application.</p>
        
        <a href="login.jsp" class="login-link">Login Again</a>
        
        <div class="time-info">
            <p>Current Time: 2025-05-06 13:12:51 (UTC)</p>
            <p>Session timeout: 30 minutes</p>
        </div>
    </div>
</body>
</html>