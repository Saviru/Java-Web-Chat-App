<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.chat.model.User"%>
<%@ page import="com.chat.dao.UserDAO"%>
<%@ page import="com.chat.dao.UserStatusDAO"%>
<%@ page import="com.chat.model.UserStatus"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

<%
    // Check if the user is logged in
    User currentUser = (User) session.getAttribute("user");
    
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Format current date and time
    String currentDateTime = "2025-05-06 13:07:17"; // Using provided time
    
    // Get all users
    UserDAO userDAO = new UserDAO();
    List<User> users = userDAO.getAllUsers();
    
    // Get user statuses
    UserStatusDAO statusDAO = new UserStatusDAO();
    List<UserStatus> allStatuses = statusDAO.getAllUserStatuses();
    Map<Integer, String> userStatuses = new HashMap<>();
    for (UserStatus status : allStatuses) {
        userStatuses.put(status.getUserId(), status.getStatus());
    }
    
    // Count online users
    int onlineUsers = 0;
    for (String status : userStatuses.values()) {
        if ("online".equals(status)) {
            onlineUsers++;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat App - <%= onlineUsers %> Online</title>
    
    <style>
        /* Basic reset */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f4f4f4;
        }
        
        /* Layout */
        .chat-container {
            display: flex;
            height: 100vh;
            max-height: 100vh;
            overflow: hidden;
        }
        
        .sidebar {
            width: 30%;
            min-width: 250px;
            background-color: #2c3e50;
            color: white;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .chat-area {
            flex: 1;
            display: flex;
            flex-direction: column;
            background-color: #ecf0f1;
            overflow: hidden;
        }
        
        /* User info */
        .user-info {
            padding: 15px;
            background-color: #34495e;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .user-info h3 {
            margin: 0;
        }
        
        .logout-button {
            background-color: #e74c3c;
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 3px;
            text-decoration: none;
            font-size: 0.9em;
        }
        
        .logout-button:hover {
            background-color: #c0392b;
        }
        
        /* Status bar */
        .status-bar {
            display: flex;
            justify-content: space-between;
            padding: 5px 15px;
            background-color: #34495e;
            border-bottom: 1px solid #2c3e50;
            font-size: 0.8em;
        }
        
        .online-count {
            color: #2ecc71;
        }
        
        .current-date {
            color: #bdc3c7;
        }
        
        /* Search container */
        .search-container {
            padding: 15px;
            display: flex;
            border-bottom: 1px solid #2c3e50;
        }
        
        .search-container input {
            flex: 1;
            padding: 8px;
            border: none;
            border-radius: 3px 0 0 3px;
        }
        
        .search-container button {
            padding: 8px 15px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 0 3px 3px 0;
            cursor: pointer;
        }
        
        /* User list */
        .user-list {
            list-style: none;
            flex: 1;
            overflow-y: auto;
            padding: 15px;
        }
        
        .user-item {
            padding: 10px;
            margin-bottom: 5px;
            background-color: #34495e;
            border-radius: 3px;
            cursor: pointer;
            transition: background-color 0.2s;
            display: flex;
            align-items: center;
        }
        
        .user-item:hover, .user-item.active {
            background-color: #3498db;
        }
        
        .no-users {
            text-align: center;
            padding: 15px;
            color: #bdc3c7;
            font-style: italic;
        }
        
        /* Status indicators */
        .status-indicator {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 8px;
        }
        
        .status-online {
            background-color: #2ecc71;
            animation: pulse 2s infinite;
        }
        
        .status-away {
            background-color: #f39c12;
        }
        
        .status-offline {
            background-color: #e74c3c;
        }
        
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.6; }
            100% { opacity: 1; }
        }
        
        /* Chat header */
        #chat-header {
            padding: 15px;
            background-color: #34495e;
            color: white;
            border-bottom: 1px solid #2c3e50;
            display: flex;
            align-items: center;
        }
        
        #chat-header h3 {
            margin: 0;
            display: flex;
            align-items: center;
        }
        
        /* Messages container */
        #messages-container {
            flex: 1;
            overflow-y: auto;
            padding: 15px;
            display: flex;
            flex-direction: column;
            background-color: #fff;
        }
        
        .loading-messages {
            text-align: center;
            padding: 20px;
            color: #7f8c8d;
            font-style: italic;
        }
        
        .no-messages {
            text-align: center;
            padding: 30px;
            color: #7f8c8d;
            background-color: #f9f9f9;
            border-radius: 5px;
            margin: 20px auto;
            max-width: 80%;
        }
        
        .error-message {
            text-align: center;
            padding: 15px;
            color: #721c24;
            background-color: #f8d7da;
            border-radius: 5px;
            margin: 20px auto;
            max-width: 80%;
        }
        
        /* Date separator */
        .date-separator {
            text-align: center;
            padding: 10px;
            color: #7f8c8d;
            font-size: 0.9em;
            margin: 10px 0;
            position: relative;
        }
        
        .date-separator:before, .date-separator:after {
            content: '';
            width: 30%;
            height: 1px;
            background-color: #ddd;
            position: absolute;
            top: 50%;
        }
        
        .date-separator:before {
            left: 0;
        }
        
        .date-separator:after {
            right: 0;
        }
        
        .message-sender-top {
   			font-weight: bold;
    		font-size: 0.85em;
    		margin-bottom: 4px;
    		opacity: 0.8;
    		color: #2c3e50;
   	 	}

/* Status indicators */
		.status-delivered {
    color: #2ecc71; /* Green color for delivered status */
}

.status-read {
    color: #3498db; /* Blue color for read status */
}
        
        /* Messages */
        .message {
    padding: 8px 15px;
    margin-bottom: 10px;
    border-radius: 5px;
    max-width: 80%;
    animation: fadeIn 0.3s ease-out;
    position: relative;
}
        
        .message-sent {
            background-color: #3498db;
            color: white;
            margin-left: auto;
            border-bottom-right-radius: 0;
        }
        
        .message-received {
            background-color: #bdc3c7;
            color: #333;
            margin-right: auto;
            border-bottom-left-radius: 0;
        }
        
        .message-content {
            word-wrap: break-word;
        }
        
        .message-info {
    display: flex;
    font-size: 0.8em;
    margin-top: 5px;
    align-items: center;
    justify-content: flex-end;
}
        
        .message-sender {
            font-weight: bold;
            margin-right: 8px;
        }
        
        .message-time {
            opacity: 0.8;
        }
        
        .message-status {
            margin-left: auto;
            font-size: 0.9em;
            color: rgba(255, 255, 255, 0.8);
        }
        
        .status-read {
            color: #2ecc71;
        }
        
        /* Failed messages */
        .message-failed {
            opacity: 0.7;
        }
        
        .message-info .message-sender {
    display: none;
}
        
        .message-error {
            font-size: 0.8em;
            color: #e74c3c;
            margin-top: 5px;
            padding: 3px 5px;
            background-color: rgba(231, 76, 60, 0.1);
            border-radius: 3px;
        }
        
        /* Message input */
        .message-input {
            padding: 15px;
            background-color: white;
            border-top: 1px solid #ddd;
            display: flex;
        }
        
        .message-input input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 3px;
            margin-right: 10px;
        }
        
        .message-input button {
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        
        .message-input button:hover {
            background-color: #2980b9;
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        /* Typing indicator */
        .typing-indicator {
            padding: 10px;
            color: #7f8c8d;
            font-style: italic;
            font-size: 0.9em;
        }
        
        /* Search results */
        .search-results {
            background-color: #f1f1f1;
            padding: 10px 15px;
            margin-bottom: 15px;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .back-to-chat {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 3px;
            cursor: pointer;
        }
        
        .back-to-chat:hover {
            background-color: #2980b9;
        }
        
        /* Media queries */
        @media (max-width: 768px) {
            .chat-container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: 40vh;
            }
            
            .chat-area {
                height: 60vh;
            }
            
            .message {
                max-width: 90%;
            }
        }
        
        /* Debug info */
        .debug-info {
            position: fixed;
            bottom: 5px;
            right: 5px;
            background-color: rgba(0,0,0,0.7);
            color: white;
            font-size: 10px;
            padding: 5px;
            border-radius: 3px;
            z-index: 1000;
            max-width: 300px;
            max-height: 100px;
            overflow: auto;
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="sidebar">
            <div class="user-info">
                <h3>Welcome, <%= currentUser.getUsername() %></h3>
                <a href="logout" class="logout-button">Logout</a>
            </div>
            
            <div class="status-bar">
                <div class="online-count"><span id="online-count"><%= onlineUsers %></span> users online</div>
                <div class="current-date" id="current-date"><%= currentDateTime %></div>
            </div>
            
            <div class="search-container">
                <input type="text" id="search-input" placeholder="Search messages...">
                <button id="search-button">Search</button>
            </div>
            
            <h3>Users</h3>
            <ul class="user-list" id="user-list">
                <% 
                boolean hasUsers = false;
                for (User user : users) { 
                    if (user.getId() != currentUser.getId()) {
                        hasUsers = true;
                        String statusClass = "status-offline";
                        String statusText = "Offline";
                        String userStatus = userStatuses.getOrDefault(user.getId(), "offline");
                        
                        if ("online".equals(userStatus)) {
                            statusClass = "status-online";
                            statusText = "Online";
                        } else if ("away".equals(userStatus)) {
                            statusClass = "status-away";
                            statusText = "Away";
                        }
                %>
                    <li class="user-item" onclick="selectUser(<%= user.getId() %>, '<%= user.getUsername() %>')" 
                        data-status="<%= userStatus %>" data-userid="<%= user.getId() %>">
                        <span class="status-indicator <%= statusClass %>" title="<%= statusText %>"></span>
                        <%= user.getUsername() %>
                    </li>
                <% } 
                }
                
                if (!hasUsers) { %>
                    <li class="no-users">No other users available. Invite friends to join!</li>
                <% } %>
            </ul>
        </div>
        
        <div class="chat-area">
            <div id="chat-header">
                <h3>Select a user to start chatting</h3>
            </div>
            
            <div id="messages-container"></div>
            
            <div class="message-input" id="message-input-container" style="display: none;">
                <input type="text" id="message-input" placeholder="Type your message...">
                <button id="send-button">Send</button>
            </div>
        </div>
    </div>
    
    <!-- Debug info -->
    <div id="debug-panel" class="debug-info" style="display: none;">
        <div id="debug-content"></div>
    </div>
    
    <script>
        // Initialize global variables
        var currentUserId = <%= currentUser.getId() %>;
        var currentUsername = "<%= currentUser.getUsername() %>";
        var selectedUserId = null;
        var selectedUsername = null;
        var lastMessageTime = 0;
        var messageCache = {};
        var tempMessageIds = {}; // Track temporary message IDs to permanent ones
        var messagePollingInterval = null;
        var isInitialLoad = true;
        var debugMode = false; // Set to true to enable debug panel
        var sendInProgress = false; // Flag to prevent double-sending
        
        // Helper functions
        function debug(message) {
            if (debugMode) {
                console.log("DEBUG: " + message);
                var debugPanel = document.getElementById('debug-panel');
                var debugContent = document.getElementById('debug-content');
                
                debugPanel.style.display = 'block';
                debugContent.innerHTML += new Date().toLocaleTimeString() + ': ' + message + '<br>';
                
                // Limit debug content
                if (debugContent.innerHTML.length > 5000) {
                    debugContent.innerHTML = debugContent.innerHTML.substring(debugContent.innerHTML.length - 5000);
                }
                
                // Auto-scroll
                debugPanel.scrollTop = debugPanel.scrollHeight;
            }
        }
        
        function padZero(num) {
            return num < 10 ? '0' + num : num;
        }
        
        // Format current time
        function updateDateTime() {
            var now = new Date();
            var dateStr = now.getFullYear() + '-' + 
                          padZero(now.getMonth() + 1) + '-' + 
                          padZero(now.getDate()) + ' ' + 
                          padZero(now.getHours()) + ':' + 
                          padZero(now.getMinutes()) + ':' + 
                          padZero(now.getSeconds());
            document.getElementById('current-date').textContent = dateStr;
        }
        
        // Update time every minute
        setInterval(updateDateTime, 60000);
        
        // Select a user to chat with
        function selectUser(userId, username) {
            debug("Selecting user: " + username + " (ID: " + userId + ")");
            
            try {
                // Update global variables
                selectedUserId = userId;
                selectedUsername = username;
                
                // Visual feedback in the user list
                document.querySelectorAll('.user-item').forEach(function(item) {
                    item.classList.remove('active');
                    if (item.textContent.includes(username)) {
                        item.classList.add('active');
                    }
                });
                
                // Get the user's status
                var userItem = document.querySelector('.user-item[data-userid="' + userId + '"]');
                var userStatus = userItem ? userItem.getAttribute('data-status') : 'offline';
                
                // Create status indicator HTML
                var statusHtml = '';
                if (userStatus === 'online') {
                    statusHtml = '<span class="status-indicator status-online" title="Online"></span>';
                } else if (userStatus === 'away') {
                    statusHtml = '<span class="status-indicator status-away" title="Away"></span>';
                } else {
                    statusHtml = '<span class="status-indicator status-offline" title="Offline"></span>';
                }
                
                // Update chat header
                var chatHeader = document.getElementById('chat-header');
                chatHeader.innerHTML = '<h3>' + statusHtml + ' Chat with ' + username + '</h3>';
                
                // Update page title
                document.title = 'Chat with ' + username + ' - Chat App';
                
                // Show message input
                document.getElementById('message-input-container').style.display = 'flex';
                
                // Reset message cache and temporary message tracking
                messageCache = {};
                tempMessageIds = {};
                lastMessageTime = 0;
                isInitialLoad = true;
                
                // Clear existing messages and show loading indicator
                var messagesContainer = document.getElementById('messages-container');
                messagesContainer.innerHTML = '<div class="loading-messages">Loading messages...</div>';
                
                // Load messages
                loadMessages();
                
                // Start periodic updates
                if (messagePollingInterval) {
                    clearInterval(messagePollingInterval);
                }
                messagePollingInterval = setInterval(loadMessages, 3000);
                
                // Focus on input
                document.getElementById('message-input').focus();
                
                debug("User selection complete");
            } catch (e) {
                console.error("Error selecting user:", e);
            }
        }
        
        // Load messages
        function loadMessages() {
            if (!selectedUserId) {
                debug("No user selected");
                return;
            }
            
            debug("Loading messages for conversation with " + selectedUsername);
            
            var timestamp = new Date().getTime();
            fetch('getMessages?receiverId=' + selectedUserId + '&_=' + timestamp)
                .then(function(response) {
                    if (!response.ok) {
                        throw new Error('Server returned status ' + response.status);
                    }
                    return response.json();
                })
                .then(function(messages) {
                    debug("Received " + messages.length + " messages");
                    
                    // Update message statuses for received messages
                    for (var i = 0; i < messages.length; i++) {
                        var message = messages[i];
                        
                        // If this is an incoming message (not sent by current user) and not read yet
                        if (message.senderId !== currentUserId && message.status !== "read") {
                            debug("Marking message " + message.id + " as read");
                            updateMessageStatus(message.id, "read");
                        }
                        // If this is an outgoing message (sent by current user) with "sent" status
                        else if (message.senderId === currentUserId && message.status === "sent") {
                            // If the message is older than 2 seconds, mark as delivered
                            var messageTime = new Date(message.sentTime).getTime();
                            var currentTime = new Date().getTime();
                            
                            if (currentTime - messageTime > 2000) {
                                debug("Marking outgoing message " + message.id + " as delivered");
                                updateMessageStatus(message.id, "delivered");
                            }
                        }
                    }
                    
                    displayMessages(messages, isInitialLoad);
                    isInitialLoad = false;
                })
                .catch(function(error) {
                    console.error("Error loading messages:", error);
                    if (isInitialLoad) {
                        document.getElementById('messages-container').innerHTML = 
                            '<div class="error-message">Error loading messages: ' + error.message + '</div>';
                    }
                });
        }
        
        // Display messages
        function displayMessages(messages, isInitialLoad) {
            var messagesContainer = document.getElementById('messages-container');
            
            // Save scroll position
            var wasAtBottom = messagesContainer.scrollHeight - messagesContainer.clientHeight <= messagesContainer.scrollTop + 10;
            
            // Empty message list case
            if (messages.length === 0 && isInitialLoad) {
                messagesContainer.innerHTML = '<div class="no-messages">No messages yet. Start the conversation!</div>';
                return;
            }
            
            var newMessages = false;
            var messagesHtml = '';
            var newMessagesHtml = '';
            
            // Group messages by date
            var currentDate = '';
            
            if (isInitialLoad) {
                // Replace all messages
                for (var i = 0; i < messages.length; i++) {
                    var message = messages[i];
                    
                    // Add to cache using message ID as key
                    messageCache[message.id] = message;
                    
                    var messageDate = new Date(message.sentTime);
                    var messageDay = formatDate(messageDate);
                    
                    // Add date separator
                    if (messageDay !== currentDate) {
                        messagesHtml += '<div class="date-separator">' + messageDay + '</div>';
                        currentDate = messageDay;
                    }
                    
                    messagesHtml += createMessageHtml(message);
                }
                
                messagesContainer.innerHTML = messagesHtml;
                if (messages.length > 0) {
                    lastMessageTime = new Date(messages[messages.length - 1].sentTime).getTime();
                }
            } else {
                // Get the last existing date separator in the DOM
                var existingDateSeparators = messagesContainer.querySelectorAll('.date-separator');
                if (existingDateSeparators.length > 0) {
                    currentDate = existingDateSeparators[existingDateSeparators.length - 1].textContent.trim();
                }
                
                debug("Last date separator in DOM: " + currentDate);
                
                // Process only new messages or updates
                for (var i = 0; i < messages.length; i++) {
                    var message = messages[i];
                    var messageTime = new Date(message.sentTime).getTime();
                    
                    // Check if message is already in cache
                    if (!messageCache[message.id]) {
                        // Check if this is a permanent version of a temporary message
                        var isTempMessage = false;
                        for (var tempId in tempMessageIds) {
                            // Match based on content and timestamps (within a small window)
                            if (tempMessageIds[tempId].content === message.content && 
                                Math.abs(tempMessageIds[tempId].time - messageTime) < 5000) {
                                
                                debug("Found permanent ID " + message.id + " for temp message " + tempId);
                                
                                // Find and update the temporary message in the DOM
                                var tempElement = document.getElementById(tempId);
                                if (tempElement) {
                                    tempElement.setAttribute('data-id', message.id);
                                    tempElement.removeAttribute('id'); // Remove temp ID
                                    
                                    // Update the status if needed
                                    var statusElement = tempElement.querySelector('.message-status');
                                    if (statusElement) {
                                        statusElement.innerHTML = getStatusIcon(message.status);
                                        statusElement.setAttribute('title', message.status.charAt(0).toUpperCase() + message.status.slice(1));
                                    }
                                }
                                
                                // Add to cache but don't create a new DOM element
                                messageCache[message.id] = message;
                                
                                // Remove from temp tracking
                                delete tempMessageIds[tempId];
                                
                                isTempMessage = true;
                                break;
                            }
                        }
                        
                        // If not a temp message, add as a new message
                        if (!isTempMessage && messageTime > lastMessageTime) {
                            messageCache[message.id] = message;
                            
                            var messageDate = new Date(message.sentTime);
                            var messageDay = formatDate(messageDate);
                            
                            // Add date separator only if it's different from current date
                            if (messageDay !== currentDate) {
                                newMessagesHtml += '<div class="date-separator">' + messageDay + '</div>';
                                currentDate = messageDay;
                                debug("Adding new date separator: " + messageDay);
                            }
                            
                            newMessagesHtml += createMessageHtml(message);
                            newMessages = true;
                        }
                    } else {
                        // Update existing message status
                        var cachedMessage = messageCache[message.id];
                        
                        if (cachedMessage.status !== message.status) {
                            var messageElement = document.querySelector('.message[data-id="' + message.id + '"]');
                            if (messageElement) {
                                var statusElement = messageElement.querySelector('.message-status');
                                if (statusElement) {
                                    statusElement.innerHTML = getStatusIcon(message.status);
                                    statusElement.setAttribute('title', message.status.charAt(0).toUpperCase() + message.status.slice(1));
                                }
                            }
                            cachedMessage.status = message.status;
                        }
                    }
                    
                    // Update the last processed timestamp
                    if (messageTime > lastMessageTime) {
                        lastMessageTime = messageTime;
                    }
                }
                
                // Append new messages
                if (newMessages) {
                    messagesContainer.insertAdjacentHTML('beforeend', newMessagesHtml);
                }
            }
            
            // Scroll to bottom if we were already at bottom or have new messages
            if (wasAtBottom || newMessages) {
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }
        }
        
        // Create message HTML
       function createMessageHtml(message) {
    var isCurrentUser = message.senderId === currentUserId;
    var messageClass = isCurrentUser ? 'message-sent' : 'message-received';
    var sender = isCurrentUser ? 'You' : message.senderUsername;
    
    // Format time
    var messageDate = new Date(message.sentTime);
    var formattedTime = formatTime(messageDate);
    
    // Status indicator
    var statusIndicator = isCurrentUser ? 
        '<span class="message-status" title="' + (message.status ? message.status.charAt(0).toUpperCase() + message.status.slice(1) : 'Sent') + '">' + getStatusIcon(message.status) + '</span>' : '';
    
    return '<div class="message ' + messageClass + '" data-id="' + message.id + '">' +
        '<div class="message-sender-top">' + sender + '</div>' +
        '<div class="message-content">' + formatMessageContent(message.content) + '</div>' +
        '<div class="message-info">' +
            '<span class="message-time">' + formattedTime + '</span>' +
            statusIndicator +
        '</div>' +
    '</div>';
}
        
        // Status icon based on message status
        function getStatusIcon(status) {
    if (!status) return '✓';
    
    switch(status) {
        case 'sent': return '✓';
        case 'delivered': return '<span class="status-delivered">✓✓</span>';
        case 'read': return '<span class="status-read">✓✓</span>'; // Only two ticks, colored for read
        default: return '✓';
    }
}
        
        // Format message content
        function formatMessageContent(content) {
            if (!content) return '';
            
            // Basic HTML escaping
            content = content
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
            
            // Add emoji support
            content = content.replace(/:\)/g, '😊')
                            .replace(/:\(/g, '😢')
                            .replace(/:D/g, '😃')
                            .replace(/;\)/g, '😉')
                            .replace(/:\|/g, '😐')
                            .replace(/:P/g, '😛')
                            .replace(/<3/g, '❤️');
                            
            // Make URLs clickable
            content = content.replace(/(https?:\/\/[^\s]+)/g, '<a href="$1" target="_blank">$1</a>');
            
            return content;
        }
        
        // Format date
        function formatDate(date) {
            var now = new Date();
            var today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            var yesterday = new Date(today);
            yesterday.setDate(yesterday.getDate() - 1);
            
            var messageDay = new Date(date.getFullYear(), date.getMonth(), date.getDate());
            
            if (messageDay.getTime() === today.getTime()) {
                return 'Today';
            } else if (messageDay.getTime() === yesterday.getTime()) {
                return 'Yesterday';
            } else {
                return date.getFullYear() + '-' + padZero(date.getMonth() + 1) + '-' + padZero(date.getDate());
            }
        }
        
        // Format time
        function formatTime(date) {
            return padZero(date.getHours()) + ':' + padZero(date.getMinutes());
        }
        
        // Send a message
        function sendMessage() {
            debug("sendMessage called");
            
            if (!selectedUserId) {
                alert("Please select a user to chat with first.");
                return;
            }
            
            if (sendInProgress) {
                debug("Send already in progress, ignoring duplicate call");
                return;
            }
            
            var messageInput = document.getElementById('message-input');
            var content = messageInput.value.trim();
            
            if (content === '') return;
            
            // Set flag to prevent duplicate sends
            sendInProgress = true;
            
            // Clear input field immediately
            messageInput.value = '';
            
            debug("Sending message to " + selectedUsername + " (ID: " + selectedUserId + "): " + content);
            
            // Generate temporary ID
            var tempId = 'temp-' + new Date().getTime();
            
            // Store temp message info for matching later
            tempMessageIds[tempId] = {
                content: content,
                time: new Date().getTime()
            };
            
            // Add message to UI immediately
            var messagesContainer = document.getElementById('messages-container');
            var tempTime = formatTime(new Date());
            var tempMessageHtml = 
                '<div class="message message-sent temp-message" id="' + tempId + '">' +
                    '<div class="message-content">' + formatMessageContent(content) + '</div>' +
                    '<div class="message-info">' +
                        '<span class="message-sender">You</span>' +
                        '<span class="message-time">' + tempTime + '</span>' +
                        '<span class="message-status" title="Sending">⌛</span>' +
                    '</div>' +
                '</div>';
            messagesContainer.insertAdjacentHTML('beforeend', tempMessageHtml);
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
            
            // Send to server
            var formData = new URLSearchParams();
            formData.append('receiverId', selectedUserId);
            formData.append('content', content);
            
            fetch('sendMessage', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.json();
            })
            .then(function(data) {
                debug("Server response: " + JSON.stringify(data));
                
                if (data.success) {
                    // Update temp message
                    var tempElement = document.getElementById(tempId);
                    if (tempElement) {
                        var statusElement = tempElement.querySelector('.message-status');
                        if (statusElement) {
                            statusElement.innerHTML = getStatusIcon('sent');
                            statusElement.setAttribute('title', 'Sent');
                        }
                        
                        // Store server message ID if provided
                        if (data.messageId) {
                            tempElement.setAttribute('data-id', data.messageId);
                            // Add to message cache to prevent duplication
                            messageCache[data.messageId] = {
                                id: data.messageId,
                                senderId: currentUserId,
                                receiverId: selectedUserId,
                                content: content,
                                sentTime: new Date().toISOString(),
                                status: 'sent',
                                senderUsername: currentUsername
                            };
                            // Remove from temp tracking
                            delete tempMessageIds[tempId];
                            // Remove temp ID
                            tempElement.removeAttribute('id');
                        }
                    }
                    
                    // No need to immediately refresh messages if we handled temp->permanent ID mapping
                    if (!data.messageId) {
                        setTimeout(loadMessages, 500);
                    }
                } else {
                    console.error('Error sending message:', data.error);
                    // Update temp message to show error
                    var tempElement = document.getElementById(tempId);
                    if (tempElement) {
                        tempElement.classList.add('message-failed');
                        var statusElement = tempElement.querySelector('.message-status');
                        if (statusElement) {
                            statusElement.innerHTML = '❌';
                            statusElement.setAttribute('title', 'Failed to send');
                        }
                        
                        // Add error details
                        if (data.error) {
                            tempElement.insertAdjacentHTML('beforeend', 
                                '<div class="message-error">' + data.error + '</div>');
                        }
                    }
                }
                
                // Reset send flag
                sendInProgress = false;
            })
            .catch(function(error) {
                console.error('Error sending message:', error);
                
                // Update temp message to show error
                var tempElement = document.getElementById(tempId);
                if (tempElement) {
                    tempElement.classList.add('message-failed');
                    var statusElement = tempElement.querySelector('.message-status');
                    if (statusElement) {
                        statusElement.innerHTML = '❌';
                        statusElement.setAttribute('title', 'Failed to send');
                    }
                    
                    // Add error details
                    tempElement.insertAdjacentHTML('beforeend', 
                        '<div class="message-error">Network error: ' + error.message + '</div>');
                }
                
                // Reset send flag
                sendInProgress = false;
            });
        }
        
        // Update message status
        function updateMessageStatus(messageId, status) {
            // Don't send updates for messages we've already updated
            if (messageCache[messageId] && messageCache[messageId].status === status) {
                return;
            }
            
            var formData = new URLSearchParams();
            formData.append('messageId', messageId);
            formData.append('status', status);
            
            fetch('updateMessageStatus', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData
            })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.json();
            })
            .then(function(data) {
                if (data.success) {
                    debug("Successfully updated message " + messageId + " to status: " + status);
                    
                    // Update the message in cache
                    if (messageCache[messageId]) {
                        messageCache[messageId].status = status;
                        
                        // Also update the DOM
                        var messageElement = document.querySelector('.message[data-id="' + messageId + '"]');
                        if (messageElement) {
                            var statusElement = messageElement.querySelector('.message-status');
                            if (statusElement) {
                                statusElement.innerHTML = getStatusIcon(status);
                                statusElement.setAttribute('title', status.charAt(0).toUpperCase() + status.slice(1));
                            }
                        }
                    }
                } else {
                    console.error("Failed to update message status:", data.error);
                }
            })
            .catch(function(error) {
                console.error("Error updating message status:", error);
            });
        }
        
        // Update user statuses
        function refreshUserStatuses() {
            fetch('getActiveUsers')
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    // Update online count
                    document.getElementById('online-count').textContent = data.onlineCount;
                    
                    // Update user statuses in the list
                    data.users.forEach(function(user) {
                        var userItem = document.querySelector('.user-item[data-userid="' + user.id + '"]');
                        if (userItem) {
                            // Remove existing status classes
                            userItem.querySelector('.status-indicator').classList.remove('status-online', 'status-offline', 'status-away');
                            
                            // Set new status
                            var statusClass = 'status-offline';
                            if (user.status === 'online') {
                                statusClass = 'status-online';
                            } else if (user.status === 'away') {
                                statusClass = 'status-away';
                            }
                            
                            userItem.querySelector('.status-indicator').classList.add(statusClass);
                            userItem.setAttribute('data-status', user.status);
                            
                            // Update chat header if this is the selected user
                            if (parseInt(userItem.getAttribute('data-userid')) === selectedUserId) {
                                var statusIndicator = document.querySelector('#chat-header .status-indicator');
                                if (statusIndicator) {
                                    statusIndicator.classList.remove('status-online', 'status-offline', 'status-away');
                                    statusIndicator.classList.add(statusClass);
                                    
                                    // Update title for the status tooltip
                                    var statusText = 'Offline';
                                    if (user.status === 'online') statusText = 'Online';
                                    else if (user.status === 'away') statusText = 'Away';
                                    
                                    statusIndicator.setAttribute('title', statusText);
                                }
                            }
                        }
                    });
                })
                .catch(function(error) { console.error('Error refreshing user statuses:', error); });
        }
        
        // Update own status
        function updateUserStatus(status) {
            var formData = new URLSearchParams();
            formData.append('status', status || 'online');
            
            fetch('updateStatus', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData
            }).catch(function(error) {
                console.error('Error updating status:', error);
            });
        }
        
        // Search messages
        function searchMessages(query) {
            if (!selectedUserId || !query) return;
            
            var messagesContainer = document.getElementById('messages-container');
            messagesContainer.innerHTML = '<div class="loading-messages">Searching messages...</div>';
            
            fetch('searchMessages?receiverId=' + selectedUserId + '&query=' + encodeURIComponent(query))
                .then(function(response) {
                    if (!response.ok) {
                        throw new Error('Search failed: ' + response.status);
                    }
                    return response.json();
                })
                .then(function(messages) {
                    if (messages.length === 0) {
                        messagesContainer.innerHTML = 
                            '<div class="no-messages">No messages found matching "' + query + '"</div>';
                        return;
                    }
                    
                    var messagesHtml = '<div class="search-results">' +
                        'Search results for "' + query + '" (' + messages.length + ' message' + (messages.length === 1 ? '' : 's') + ' found):' +
                        '<button onclick="loadMessages()" class="back-to-chat">Back to chat</button>' +
                    '</div>';
                    
                    var currentDate = '';
                    
                    for (var i = 0; i < messages.length; i++) {
                        var message = messages[i];
                        var messageDate = new Date(message.sentTime);
                        var messageDay = formatDate(messageDate);
                        
                        if (messageDay !== currentDate) {
                            messagesHtml += '<div class="date-separator">' + messageDay + '</div>';
                            currentDate = messageDay;
                        }
                        
                        messagesHtml += createMessageHtml(message);
                    }
                    
                    messagesContainer.innerHTML = messagesHtml;
                })
                .catch(function(error) {
                    console.error('Search error:', error);
                    messagesContainer.innerHTML = 
                        '<div class="error-message">Error searching messages: ' + error.message + '</div>';
                });
        }
        
        // Set up event listeners
        document.addEventListener('DOMContentLoaded', function() {
            debug("DOM loaded, setting up event listeners");
            
            // Message input: Enter key sends message
            var messageInput = document.getElementById('message-input');
            if (messageInput) {
                messageInput.addEventListener('keypress', function(event) {
                    if (event.key === 'Enter') {
                        event.preventDefault();
                        sendMessage();
                    }
                });
            }
            
            // Send button
            var sendButton = document.getElementById('send-button');
            if (sendButton) {
                sendButton.addEventListener('click', function(event) {
                    event.preventDefault();
                    sendMessage();
                });
            }
            
            // Search button
            var searchButton = document.getElementById('search-button');
            if (searchButton) {
                searchButton.addEventListener('click', function() {
                    var searchTerm = document.getElementById('search-input').value.trim();
                    if (searchTerm && selectedUserId) {
                        searchMessages(searchTerm);
                    } else {
                        alert("Please select a user and enter a search term");
                    }
                });
            }
            
            // Set status to online
            updateUserStatus('online');
            
            // Start periodic updates
            setInterval(refreshUserStatuses, 10000); // Every 10 seconds
            
            debug("Event handlers set up successfully");
            
            // Set up inactivity detection
            var inactivityTimeout;
            
            function resetInactivityTimer() {
                clearTimeout(inactivityTimeout);
                
                // After 2 minutes of inactivity, set status to away
                inactivityTimeout = setTimeout(function() {
                    updateUserStatus('away');
                }, 2 * 60 * 1000);
            }
            
            // Monitor user activity
            document.addEventListener('mousemove', resetInactivityTimer);
            document.addEventListener('keypress', resetInactivityTimer);
            document.addEventListener('click', resetInactivityTimer);
            
            // Initial timer start
            resetInactivityTimer();
        });
        
        // When page is unloaded
        window.addEventListener('beforeunload', function() {
            if (messagePollingInterval) {
                clearInterval(messagePollingInterval);
            }
            updateUserStatus('offline');
        });
        
        // Toggle debug mode
        document.addEventListener('keydown', function(event) {
            // Ctrl+Shift+D to toggle debug mode
            if (event.ctrlKey && event.shiftKey && event.key === 'D') {
                debugMode = !debugMode;
                document.getElementById('debug-panel').style.display = debugMode ? 'block' : 'none';
                debug("Debug mode " + (debugMode ? "enabled" : "disabled"));
            }
        });
    </script>
</body>
</html>