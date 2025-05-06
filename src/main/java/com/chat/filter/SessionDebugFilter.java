package com.chat.filter;

import com.chat.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class SessionDebugFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String uri = httpRequest.getRequestURI();
        
        System.out.println("\n==== Session Debug Info ====");
        System.out.println("Requested URI: " + uri);
        System.out.println("Query String: " + httpRequest.getQueryString());
        System.out.println("Session exists: " + (session != null));
        
        if (session != null) {
            System.out.println("Session ID: " + session.getId());
            User user = (User) session.getAttribute("user");
            System.out.println("User attribute exists: " + (user != null));
            if (user != null) {
                System.out.println("User ID: " + user.getId() + ", Username: " + user.getUsername());
            }
        }
        System.out.println("===========================\n");
        
        // Continue with the request
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}