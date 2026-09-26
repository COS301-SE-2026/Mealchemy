package com.mealchemy.config;
 
import java.util.List;
import java.util.Set;
 
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessagingException;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;

// Like JwtAuthFilter but for WebSocket

// Auth happens on CONNECT frame

@Component
public class StompAuthChannelInterceptor implements ChannelInterceptor { // intercept messages before continue through system - inspect STOMP message before it continues

    private static final String AUTH_HEADER = "Authorization"; // STOMP header we looking for
    private static final String BEARER_PREFIX = "Bearer ";

    // Destination to subcribe to
    private static final Set<String> ALLOWED_SUBSCRIPTIONS = Set.of(
        "/user/queue/notifications",
        "/user/queue/vault-events"
    );

    private final JwtUtil jwtUtil;

    public StompAuthChannelInterceptor(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override // point of entry of intrceptory - before message sent to channel
    public Message<?> preSend(Message<?> message, MessageChannel channel) {

        // get STOMP headers from message
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        // not a STOMP frame let message continue through channel
        if (accessor == null || accessor.getCommand() == null) {
            return message;
        }

        // Is STOMP
        StompCommand command = accessor.getCommand();

        // CONNECT frame therefore authenticate 
        if (StompCommand.CONNECT.equals(command)) {
            authenticate(accessor);
        }
        // SUBSCRIBE frame therefore check subscription is valid
        else if (StompCommand.SUBSCRIBE.equals(command)) {
            checkSubscription(accessor);
        }
        // SEND frame - clients aren't allowed to send messages
        else if (StompCommand.SEND.equals(command)) {
            throw new MessagingException("Clients may not send messages.");
        }

        return message;
    }

    // ========== Helper functions ==========

    // JWT authentication
    private void authenticate(StompHeaderAccessor accessor) {
        // Inside STOMP CONNECT header 
        String authHeader = accessor.getFirstNativeHeader(AUTH_HEADER); // looks for "Authorization" and gets "Bearer ...."

        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
            throw new MessagingException("Missing or malformed Authorization header.");
        }

        // Valid authorization header - extract JWT token
        String token = authHeader.substring(BEARER_PREFIX.length());

        // pass to jwtUtil to validate token
        if (!jwtUtil.isTokenValid(token)) {
            throw new MessagingException("Invalid or expired token.");
        }

        // JWT Token valid - extract userId
        String userId = jwtUtil.extractUserId(token);

        // Create authentication object
        UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(userId, null, List.of());

        // Attach user to WebSocket session
        accessor.setUser(authentication);
    }

    // Check subscription is valid
    private void checkSubscription(StompHeaderAccessor accessor) {
        // user exists after authentication
        if (accessor.getUser() == null) {
            throw new MessagingException("Not authenticated.");
        }

        // Destination client wants to subscribe to
        String destination = accessor.getDestination();

        if (destination == null || !ALLOWED_SUBSCRIPTIONS.contains(destination)) {
            throw new MessagingException("Subscription to " + destination + " is not allowed.");
        }
    }

}