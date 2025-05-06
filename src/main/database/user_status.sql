CREATE TABLE user_status (
    user_id INT PRIMARY KEY,
    status VARCHAR(20) NOT NULL DEFAULT 'offline',
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);