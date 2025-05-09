package com.chat.dao;

import com.chat.model.User;
import com.chat.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class UserDAO {
    
    /**
     * Authenticates a user
     * @param username the username
     * @param password the hashed password
     * @return the user if authenticated, or null if not
     */
    public User authenticateUser(String username, String hashedPassword) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            
            String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            stmt.setString(2, hashedPassword);
            
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                
                // Update last login time
                updateLastLogin(user.getId());
                
                return user;
            }
            
            return null;
            
        } catch (SQLException e) {
            System.err.println("Error authenticating user: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            DBUtil.closeResources(conn, stmt, rs);
        }
    }
    
    /**
     * Gets a user by username
     * @param username the username
     * @return the user or null if not found
     */
    public User getUserByUsername(String username) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            
            String sql = "SELECT * FROM users WHERE username = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                
                return user;
            }
            
            return null;
            
        } catch (SQLException e) {
            System.err.println("Error getting user by username: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            DBUtil.closeResources(conn, stmt, rs);
        }
    }
    
    /**
     * Gets a user by ID
     * @param userId the user ID
     * @return the user or null if not found
     */
    public User getUserById(int userId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            
            String sql = "SELECT * FROM users WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setEmail(rs.getString("email"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                
                return user;
            }
            
            return null;
            
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            DBUtil.closeResources(conn, stmt, rs);
        }
    }
    
    /**
     * Updates a user's last login time
     * @param userId the user ID
     */
    private void updateLastLogin(int userId) {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            conn = DBUtil.getConnection();
            
            String sql = "UPDATE users SET last_login = ? WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setTimestamp(1, new Timestamp(new Date().getTime()));
            stmt.setInt(2, userId);
            
            stmt.executeUpdate();
            
        } catch (SQLException e) {
            System.err.println("Error updating last login: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.closeResources(conn, stmt, null);
        }
    }
    
    /**
     * Gets all users
     * @return list of all users
     */
    public List<User> getAllUsers() {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<User> users = new ArrayList<>();
        
        try {
            conn = DBUtil.getConnection();
            
            String sql = "SELECT * FROM users ORDER BY username";
            stmt = conn.prepareStatement(sql);
            
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setLastLogin(rs.getTimestamp("last_login"));
                
                users.add(user);
            }
            
            return users;
            
        } catch (SQLException e) {
            System.err.println("Error getting all users: " + e.getMessage());
            e.printStackTrace();
            return users;
        } finally {
            DBUtil.closeResources(conn, stmt, rs);
        }
    }
    
    /**
     * Registers a new user
     * @param user the user to register
     * @return the new user's ID, or -1 if registration failed
     */
    public int registerUser(User user) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            
            // SQL to insert new user
            String sql = "INSERT INTO users (username, password, email, created_at) VALUES (?, ?, ?, ?)";
            
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getPassword());
            stmt.setString(3, user.getEmail());
            stmt.setTimestamp(4, new Timestamp(user.getCreatedAt().getTime()));
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                // Get the generated user ID
                rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
            return -1; // Registration failed
        } catch (SQLException e) {
            System.err.println("Error registering user: " + e.getMessage());
            e.printStackTrace();
            return -1;
        } finally {
            DBUtil.closeResources(conn, stmt, rs);
        }
    }
}