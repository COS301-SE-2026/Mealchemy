package com.mealchemy.config;
 
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

// STOMP over WebSocket config
// Clients connect to /ws and authenticate on the STOMP CONNECT frame (STOMP CONNECT frame contains JWT) - (StompAuthChannel Interceptor)

// Clients subscribe to own per-user queues

@Configuration
@EnableWebSocketMessageBroker // for STOMP message broker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final StompAuthChannelInterceptor stompAuthChannelInterceptor; // for authentication interceptor
    
    public WebSocketConfig(StompAuthChannelInterceptor stompAuthChannelInterceptor) {
        this.stompAuthChannelInterceptor = stompAuthChannelInterceptor;
    }

    // endpoint client opens the WebSocket on
    @Override 
    public void registerStompEndpoints(StompEndpointRegistry registry) { // where client intitially connects
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*"); // auth is JWT on STOMP 
    }

    // in-memory - forwards anything sent to /queue/ to its subscribers
    @Override 
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/queue"); // any /queue handled by this broker
    }

    // every inbound STOMP frame passes through auth interceptor first (messages from client to app)
    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(stompAuthChannelInterceptor);
    }

}