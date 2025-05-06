// Set a flag to indicate that this script has loaded
window.chatJsLoaded = true;

// Log loading status
console.log("chat.js: Script loaded successfully");

// Global variables
let messagePollingInterval;
let typingPollingInterval;
let typingTimeout;
let lastProcessedTimestamp = 0;
let isInitialLoad = true;
let messageCache = {}; // Cache to store messages by ID

// Function to log if debug mode is on
function debug(message) {
    if (window.debugMode) {
        console.log("DEBUG: " + message);
    }
}

// Function to update the page title with online status
function updatePageTitle(username) {
    if (username) {
        document.title = `Chat with ${username} - Chat App`;
    } else {
        // Count online users from the UI
        const onlineUsers = document.querySelectorAll('.status-online').length;
        document.title = `Chat App - ${onlineUsers} Online`;
    }
}

// Function to select a user to chat with
function selectUser(userId, username) {
    debug("selectUser function called with userId: " + userId + ", username: " + username);
    
    try {
        // Update global variables
        window.selectedUserId = userId;
        window.selectedUsername = username;
        
        debug("Set global selectedUserId to: " + window.selectedUserId);
        
        // Visual feedback
        document.querySelectorAll('.user-item').forEach(function(item) {
            item.classList.remove('active');
            if (item.textContent.includes(username)) {
                item.classList.add('active');
            }
        });
        
        // Update chat header with visual feedback
        const chatHeader = document.getElementById('chat-header');
        
        // Get the user's status from the user-item element
        const userItem = document.querySelector(`.user-item[onclick*="${userId}"]`);
        const userStatus = userItem ? userItem.getAttribute('data-status') : 'offline';
        
        let statusHtml = '';
        if (userStatus === 'online') {
            statusHtml = '<span class="status-indicator status-online" title="Online"></span>';
        } else if (userStatus === 'away') {
            statusHtml = '<span class="status-indicator status-away" title="Away"></span>';
        } else {
            statusHtml = '<span class="status-indicator status-offline" title="Offline"></span>';
        }
        
        chatHeader.innerHTML = `<h3>${statusHtml} Chat with ${username}</h3>`;
        chatHeader.style.backgroundColor = '#34495e';
        
        // Update page title
        updatePageTitle(username);
        
        // Show message input
        const messageInputContainer = document.getElementById('message-input-container');
        messageInputContainer.style.display = 'flex';
        
        // Reset message cache for this conversation
        messageCache = {};
        
        // Reset timestamp for new messages
        lastProcessedTimestamp = 0;
        isInitialLoad = true;
        
        // Clear existing messages
        const messagesContainer = document.getElementById('messages-container');
        messagesContainer.innerHTML = '<div class="loading-messages">Loading messages...</div>';
        
        // Load messages
        loadMessages();
        
        // Start polling for new messages
        clearInterval(messagePollingInterval);
        messagePollingInterval = setInterval(loadMessages, 3000);
        
        // Set focus to the input field
        document.getElementById('message-input').focus();
        
        debug("User selection complete. Selected user ID: " + window.selectedUserId);
    } catch (e) {
        console.error("Error in selectUser function:", e);
        alert("An error occurred while selecting the user. Please try again.");
    }
}

// Function to select a user from click event
function selectUserFromClick(userId, username) {
    debug("User clicked directly: " + username + " (ID: " + userId + ")");
    selectUser(userId, username);
}

// Function to load messages between the current user and the selected user
function loadMessages() {
    if (!window.selectedUserId) {
        debug("No user selected, cannot load messages");
        return;
    }
    
    debug("Loading messages for conversation with " + window.selectedUsername);
    
    // Add timestamp to prevent caching
    const timestamp = new Date().getTime();
    const contextPath = document.querySelector('link[rel="stylesheet"]').getAttribute('href').split('/css')[0];
    fetch(`${contextPath}/getMessages?receiverId=${window.selectedUserId}&_=${timestamp}`)
        .then(response => {
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.status);
            }
            return response.json();
        })
        .then(messages => {
            debug("Received " + messages.length + " messages");
            displayMessages(messages, isInitialLoad);
            isInitialLoad = false;
        })
        .catch(error => {
            console.error('Error loading messages:', error);
            if (isInitialLoad) {
                document.getElementById('messages-container').innerHTML = 
                    '<div class="error-message">Error loading messages: ' + error.message + '</div>';
            }
        });
}

// Rest of your chat.js code...

// Function to display messages in the chat area
function displayMessages(messages, isInitialLoad) {
    const messagesContainer = document.getElementById('messages-container');
    
    // Save scroll position
    const wasAtBottom = messagesContainer.scrollHeight - messagesContainer.clientHeight <= messagesContainer.scrollTop + 10;
    
    let newMessages = false;
    let newMessagesHtml = '';
    let messagesHtml = '';
    
    if (messages.length === 0 && isInitialLoad) {
        messagesHtml = '<div class="no-messages">No messages yet. Start the conversation!</div>';
        messagesContainer.innerHTML = messagesHtml;
        return;
    }
    
    // Group messages by date
    let currentDate = '';
    
    // First initial load - replace everything
    if (isInitialLoad) {
        messages.forEach(message => {
            // Add to cache
            messageCache[message.id] = message;
            
            const messageDate = new Date(message.sentTime);
            const messageDay = formatDate(messageDate);
            
            // Add date separator if date changes
            if (messageDay !== currentDate) {
                messagesHtml += `<div class="date-separator">${messageDay}</div>`;
                currentDate = messageDay;
            }
            
            messagesHtml += createMessageHtml(message);
        });
        
        messagesContainer.innerHTML = messagesHtml;
        lastProcessedTimestamp = messages.length > 0 ? new Date(messages[messages.length - 1].sentTime).getTime() : 0;
    } 
    // Subsequent loads - only add new messages
    else {
        // Find any messages newer than our last processed one
        for (let i = 0; i < messages.length; i++) {
            const message = messages[i];
            const messageTime = new Date(message.sentTime).getTime();
            
            // Check if message is already in cache
            if (!messageCache[message.id]) {
                messageCache[message.id] = message;
                
                if (messageTime > lastProcessedTimestamp) {
                    const messageDate = new Date(message.sentTime);
                    const messageDay = formatDate(messageDate);
                    
                    // Add date separator if date changes
                    const lastMessage = i > 0 ? messages[i-1] : null;
                    const lastMessageDay = lastMessage ? formatDate(new Date(lastMessage.sentTime)) : '';
                    
                    if (messageDay !== lastMessageDay) {
                        newMessagesHtml += `<div class="date-separator">${messageDay}</div>`;
                    }
                    
                    newMessagesHtml += createMessageHtml(message);
                    newMessages = true;
                }
            } 
            // Update existing message status if needed
            else {
                const cachedMessage = messageCache[message.id];
                
                // Update message status if it has changed
                if (cachedMessage.status !== message.status) {
                    const messageElement = document.querySelector(`.message[data-id="${message.id}"]`);
                    if (messageElement) {
                        const statusElement = messageElement.querySelector('.message-status');
                        if (statusElement) {
                            statusElement.innerHTML = getStatusIcon(message.status);
                            statusElement.setAttribute('title', message.status.charAt(0).toUpperCase() + message.status.slice(1));
                        }
                    }
                    cachedMessage.status = message.status;
                }
            }
            
            // Update the last processed timestamp
            if (messageTime > lastProcessedTimestamp) {
                lastProcessedTimestamp = messageTime;
            }
        }
        
        // Only update DOM if we have new messages
        if (newMessages) {
            messagesContainer.insertAdjacentHTML('beforeend', newMessagesHtml);
        }
    }
    
    // Scroll to bottom if we were already at the bottom or have new messages
    if (wasAtBottom || newMessages) {
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
}

// Function to create HTML for a message
function createMessageHtml(message) {
    const isCurrentUser = message.senderId === window.currentUserId;
    const messageClass = isCurrentUser ? 'message-sent' : 'message-received';
    const sender = isCurrentUser ? 'You' : message.senderUsername;
    
    // Format time
    const messageDate = new Date(message.sentTime);
    const formattedTime = formatTime(messageDate);
    
    // Status indicator for sent messages
    const statusIndicator = isCurrentUser ? 
        `<span class="message-status" title="${message.status ? message.status.charAt(0).toUpperCase() + message.status.slice(1) : 'Sent'}">${getStatusIcon(message.status)}</span>` : '';
    
    return `
        <div class="message ${messageClass}" data-id="${message.id}">
            <div class="message-content">${formatMessageContent(message.content)}</div>
            <div class="message-info">
                <span class="message-sender">${sender}</span>
                <span class="message-time">${formattedTime}</span>
                ${statusIndicator}
            </div>
        </div>
    `;
}

// Function to get status icon
function getStatusIcon(status) {
    if (!status) return '✓';
    
    switch(status) {
        case 'sent': return '✓';
        case 'delivered': return '✓✓';
        case 'read': return '✓✓ <span class="status-read">✓</span>';
        default: return '✓';
    }
}

// Function to format message content
function formatMessageContent(content) {
    if (!content) return '';
    
    // Basic HTML escaping
    content = content
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
    
    // Replace emoji shortcodes with actual emojis
    content = content.replace(/:\)/g, '😊')
                    .replace(/:\(/g, '😢')
                    .replace(/:D/g, '😃')
                    .replace(/;\)/g, '😉')
                    .replace(/:\|/g, '😐')
                    .replace(/:P/g, '😛')
                    .replace(/<3/g, '❤️');
                    
    // Convert URLs to links
    content = content.replace(/(https?:\/\/[^\s]+)/g, '<a href="$1" target="_blank">$1</a>');
    
    return content;
}

// Function to format date
function formatDate(date) {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    const messageDay = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    
    if (messageDay.getTime() === today.getTime()) {
        return 'Today';
    } else if (messageDay.getTime() === yesterday.getTime()) {
        return 'Yesterday';
    } else {
        return `${date.getFullYear()}-${padZero(date.getMonth() + 1)}-${padZero(date.getDate())}`;
    }
}

// Function to format time
function formatTime(date) {
    return `${padZero(date.getHours())}:${padZero(date.getMinutes())}`;
}

// Function to pad zero
function padZero(num) {
    return num < 10 ? `0${num}` : num;
}

// Function to send a message
function sendMessage() {
    debug("sendMessage function called");
    debug("Current selectedUserId: " + window.selectedUserId);
    
    if (!window.selectedUserId) {
        alert("Please select a user to chat with first.");
        return;
    }
    
    const messageInput = document.getElementById('message-input');
    const content = messageInput.value.trim();
    
    if (content === '') return;
    
    // Clear the input field
    messageInput.value = '';
    
    debug("Sending message to: " + window.selectedUsername + " (ID: " + window.selectedUserId + ")");
    debug("Message content: " + content);
    
    // Generate temporary ID for this message
    const tempId = 'temp-' + new Date().getTime();
    
    // Add message immediately to UI for better UX
    const messagesContainer = document.getElementById('messages-container');
    const tempMessageHtml = `
        <div class="message message-sent temp-message" id="${tempId}">
            <div class="message-content">${formatMessageContent(content)}</div>
            <div class="message-info">
                <span class="message-sender">You</span>
                <span class="message-time">${formatTime(new Date())}</span>
                <span class="message-status" title="Sending">⌛</span>
            </div>
        </div>
    `;
    messagesContainer.insertAdjacentHTML('beforeend', tempMessageHtml);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
    
    // Get the context path
    const contextPath = document.querySelector('link[rel="stylesheet"]').getAttribute('href').split('/css')[0];
    
    // Send the message
    fetch(`${contextPath}/sendMessage`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `receiverId=${encodeURIComponent(window.selectedUserId)}&content=${encodeURIComponent(content)}`
    })
    .then(response => {
        if (!response.ok) {
            debug("Server returned error: " + response.status);
            throw new Error('Network response was not ok: ' + response.status);
        }
        return response.json();
    })
    .then(data => {
        debug("Server response: " + JSON.stringify(data));
        if (data.success) {
            // Update temporary message status
            const tempElement = document.getElementById(tempId);
            if (tempElement) {
                const statusElement = tempElement.querySelector('.message-status');
                if (statusElement) {
                    statusElement.innerHTML = getStatusIcon('sent');
                    statusElement.setAttribute('title', 'Sent');
                }
                // Remove the temporary ID so it will be replaced with the real message
                tempElement.id = '';
            }
            
            // Reload messages to get the real message with ID
            setTimeout(loadMessages, 500);
        } else {
            console.error('Error sending message:', data.error);
            
            // Update temporary message status
            const tempElement = document.getElementById(tempId);
            if (tempElement) {
                tempElement.classList.add('message-failed');
                const statusElement = tempElement.querySelector('.message-status');
                if (statusElement) {
                    statusElement.innerHTML = '❌';
                    statusElement.setAttribute('title', 'Failed to send');
                }
                
                // Add error details
                if (data.error) {
                    tempElement.insertAdjacentHTML('beforeend', 
                        `<div class="message-error">${data.error}</div>`);
                }
            }
        }
    })
    .catch(error => {
        console.error('Error sending message:', error);
        
        // Update temporary message status
        const tempElement = document.getElementById(tempId);
        if (tempElement) {
            tempElement.classList.add('message-failed');
            const statusElement = tempElement.querySelector('.message-status');
            if (statusElement) {
                statusElement.innerHTML = '❌';
                statusElement.setAttribute('title', 'Failed to send');
            }
            
            // Add error details
            tempElement.insertAdjacentHTML('beforeend', 
                `<div class="message-error">Network error: ${error.message}</div>`);
        }
    });
}

// Set up event listeners when the DOM is fully loaded
document.addEventListener('DOMContentLoaded', function() {
    debug("DOM fully loaded - setting up event listeners");
    
    // Event listener for pressing Enter to send a message
    const messageInput = document.getElementById('message-input');
    if (messageInput) {
        messageInput.addEventListener('keypress', function(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                sendMessage();
            }
        });
    }
    
    // Send button click handler
    const sendButton = document.getElementById('send-button');
    if (sendButton) {
        sendButton.addEventListener('click', function(event) {
            event.preventDefault();
            sendMessage();
        });
    }
    
    // Update initial status
    updateUserStatus('online');
    
    debug("Event handlers set up successfully");
});

// Function to update user status
function updateUserStatus(status) {
    const contextPath = document.querySelector('link[rel="stylesheet"]').getAttribute('href').split('/css')[0];
    fetch(`${contextPath}/updateStatus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `status=${status || 'online'}`
    }).catch(error => {
        console.error('Error updating status:', error);
    });
}

// Cleanup when page is unloaded
window.addEventListener('beforeunload', function() {
    clearInterval(messagePollingInterval);
    clearInterval(typingPollingInterval);
    updateUserStatus('offline');
});

// Log that the script finished loading
console.log("chat.js: Script initialization complete");