<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Chat Application</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            text-align: center;
        }
        
        .error-container {
            background-color: white;
            padding: 30px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            max-width: 600px;
            width: 100%;
        }
        
        h1 {
            color: #e74c3c;
            margin-bottom: 10px;
        }
        
        .error-details {
            padding: 15px;
            background-color: #f8d7da;
            border-radius: 5px;
            margin: 20px 0;
            color: #721c24;
            text-align: left;
            overflow-x: auto;
        }
        
        .home-link {
            display: inline-block;
            padding: 10px 15px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 3px;
            margin-top: 15px;
        }
        
        .home-link:hover {
            background-color: #2980b9;
        }
        
        .support-info {
            margin-top: 25px;
            font-size: 14px;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>Oops! Something went wrong</h1>
        <p>We apologize for the inconvenience. An error occurred while processing your request.</p>
        
        <% if (exception != null) { %>
            <div class="error-details">
                <strong>Error Type:</strong> <%= exception.getClass().getName() %><br/>
                <strong>Message:</strong> <%= exception.getMessage() %><br/>
                <% 
                    StackTraceElement[] stackTrace = exception.getStackTrace();
                    if (stackTrace.length > 0) {
                %>
                    <strong>Location:</strong> <%= stackTrace[0].getClassName() %> (<%= stackTrace[0].getFileName() %>:<%= stackTrace[0].getLineNumber() %>)<br/>
                <% } %>
            </div>
        <% } else { %>
            <div class="error-details">
                <strong>Status Code:</strong> <%= response.getStatus() %><br/>
                <strong>Error:</strong> Unknown error occurred
            </div>
        <% } %>
        
        <p>Please try again later or contact support if the problem persists.</p>
        
        <a href="login.jsp" class="home-link">Return to Home</a>
        
        <div class="support-info">
            <p>Current Time: <%= new java.util.Date() %></p>
             <p>Support Contact: support@chatapp.com</p>
        </div>
    </div>
</body>
</html>