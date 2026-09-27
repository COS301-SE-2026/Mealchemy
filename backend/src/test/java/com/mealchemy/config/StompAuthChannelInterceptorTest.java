package com.mealchemy.config;
 
/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
 
import java.util.List;
 
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
 
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessagingException;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
 
 
@ExtendWith(MockitoExtension.class)
public class StompAuthChannelInterceptorTest {
    // @Mock - reate fake version of dependency
    @Mock private JwtUtil jwtUtil;
    @Mock private MessageChannel channel;
 
    private StompAuthChannelInterceptor interceptor;
 
    @BeforeEach
    void setUp()
    {
        interceptor = new StompAuthChannelInterceptor(jwtUtil);
    }
 
    // ========== Helpers ==========
 
    // builds STOMP frame the way the broker hands it to the interceptor
    private Message<byte[]> stompMessage(StompCommand command, String authHeader, String destination, boolean authenticated)
    {
        StompHeaderAccessor accessor = StompHeaderAccessor.create(command);
 
        if (authHeader != null)
        {
            accessor.setNativeHeader("Authorization", authHeader);
        }
 
        if (destination != null)
        {
            accessor.setDestination(destination);
        }
 
        if (authenticated)
        {
            accessor.setUser(new UsernamePasswordAuthenticationToken("1", null, List.of()));
        }
 
        // required otherwise getAccessor() in the interceptor returns null
        accessor.setLeaveMutable(true);
 
        return MessageBuilder.createMessage(new byte[0], accessor.getMessageHeaders());
    }
 
    // ========== Tests ==========
 
    // CONNECT
    @Test
    void connect_validToken_setsUser()
    {
        // Arrange
        when(jwtUtil.isTokenValid("xyz")).thenReturn(true);
        when(jwtUtil.extractUserId("xyz")).thenReturn("1");
 
        // Act
        Message<?> result = interceptor.preSend(stompMessage(StompCommand.CONNECT, "Bearer xyz", null, false), channel);
 
        // Assert 
        // principal name is the userId (what convertAndSendToUser targets)
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(result, StompHeaderAccessor.class);
        assertEquals("1", accessor.getUser().getName());
    }
 
    @Test
    void connect_missingHeader_throws()
    {
        // Act and Assert
        assertThrows(
            MessagingException.class,
            () -> interceptor.preSend(stompMessage(StompCommand.CONNECT, null, null, false), channel)
        );
        verifyNoInteractions(jwtUtil);
    }
 
    @Test
    void connect_invalidToken_throws()
    {
        // Arrange
        when(jwtUtil.isTokenValid("bad-token")).thenReturn(false);
 
        // Act and Assert
        assertThrows(
            MessagingException.class,
            () -> interceptor.preSend(stompMessage(StompCommand.CONNECT, "Bearer bad-token", null, false), channel)
        );
    }
 
 
    // SUBSCRIBE
    @Test
    void subscribe_allowedDestination_passes()
    {
        // Act and Assert
        assertDoesNotThrow(
            () -> interceptor.preSend(stompMessage(StompCommand.SUBSCRIBE, null, "/user/queue/notifications", true), channel)
        );
    }
 
    @Test
    void subscribe_otherDestination_throws()
    {
        // Act and Assert
        assertThrows(
            MessagingException.class,
            () -> interceptor.preSend(stompMessage(StompCommand.SUBSCRIBE, null, "/queue/notifications-user5", true), channel)
        );
    }
 
    @Test
    void subscribe_notAuthenticated_throws()
    {
        // Act and Assert
        assertThrows(
            MessagingException.class,
            () -> interceptor.preSend(stompMessage(StompCommand.SUBSCRIBE, null, "/user/queue/notifications", false), channel)
        );
    }
 
 
    // SEND
    @Test
    void send_alwaysThrows()
    {
        // Act and Assert - clients may never send (prevents spoofed notifications)
        assertThrows(
            MessagingException.class,
            () -> interceptor.preSend(stompMessage(StompCommand.SEND, null, "/user/5/queue/notifications", true), channel)
        );
    }
 
 
    // non-STOMP message
    @Test
    void nonStompMessage_passesThrough()
    {
        // Arrange
        Message<String> message = MessageBuilder.withPayload("internal").build();
 
        // Act
        Message<?> result = interceptor.preSend(message, channel);
 
        // Assert
        assertSame(message, result);
    }
}