package com.mealchemy.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthFilter extends OncePerRequestFilter { //runs once per request before it reaches controller

    private final JwtUtil jwtUtil; //uses JwtUtil to check every request - extracts user_id

    //constructor
    public JwtAuthFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    //called automatically on every request
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        //get authorization header
        String authHeader = request.getHeader("Authorization");

        // If no token or doesn't start with "Bearer " - pass request through unauthorized - security config will reject it if endpoint requires auth
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        //else extract token from auth header
        String token = authHeader.substring(7);

        //validate and authenticate token
        if (jwtUtil.isTokenValid(token)) {
            String userId = jwtUtil.extractUserId(token);

            //created authentication object with extracted user
            UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                    userId,   //@AuthenticationPrincipal receives in controller
                    null, //not needed after authentication
                    List.of() 
                );

            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        filterChain.doFilter(request, response); //pass on request
    }
}