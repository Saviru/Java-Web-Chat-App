<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - Chat Application</title>
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
        
        .not-found-container {
            background-color: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 500px;
        }
        
        h1 {
            color: #3498db;
            margin-bottom: 15px;
        }
        
        .icon {
            font-size: 70px;
            color: #3498db;
            margin-bottom: 20px;
        }
        
        p {
            color: #555;
            margin-bottom: 20px;
        }
        
        .home-link {
            display: inline-block;
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 3px;
            margin-top: 10px;
        }
        
        .home-link:hover {
            background-color: #2980b9;
        }
        
        .url-info {
            background-color: #f8f9fa;
            padding: 10px;
            border-radius: 3px;
            margin: 15px 0;
            font-family: monospace;
            word-break: break-all;
        }
        
        .time-info {
            font-size: 12px;
            color: #7f8c8d;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="not-found-container">
        <div class="icon">🔍</div>
        <h1>404 - Page Not Found</h1>
        <p>The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.</p>
        
        <div class="url-info">
            <%= request.getRequestURL() %>
        </div>
        
        <p>Please check the URL for errors or try one of the links below:</p>
        
        <a href="index.jsp" class="home-link">Go to Home Page</a>
        <a href="login.jsp" class="home-link">Login Page</a>
        
        <div class="time-info">
            <p>Current Time: 2025-05-06 13:12:51 (UTC)</p>
            <p>Reference ID: <%= java.util.UUID.randomUUID().toString().substring(0, 8) %></p>
        </div>
    </div>
</body>
</html>