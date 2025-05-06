<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - Chat Application</title>
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
        
        .forbidden-container {
            background-color: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 500px;
        }
        
        h1 {
            color: #e74c3c;
            margin-bottom: 15px;
        }
        
        .icon {
            font-size: 60px;
            color: #e74c3c;
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
    <div class="forbidden-container">
        <div class="icon">⚠️</div>
        <h1>Access Denied</h1>
        <p>You don't have permission to access this resource.</p>
        <p>Please log in with an account that has the necessary permissions or contact the administrator if you believe this is a mistake.</p>
        
        <a href="login.jsp" class="login-link">Go to Login Page</a>
        
        <div class="time-info">
            <p>Current Time: 2025-05-06 13:12:51 (UTC)</p>
            <p>Reference ID: <%= java.util.UUID.randomUUID().toString().substring(0, 8) %></p>
        </div>
    </div>
</body>
</html>