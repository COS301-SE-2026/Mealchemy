package com.mealchemy.externallinks;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;
// controller
import com.mealchemy.externallinks.controller.ExternalLinkController;
// dtos
import com.mealchemy.externallinks.dto.ExternalLinkRequest;
import com.mealchemy.externallinks.dto.ExternalLinkResponse;
// service
import com.mealchemy.externallinks.service.ExternalLinkService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.time.OffsetDateTime;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(ExternalLinkController.class)
public class ExternalLinkControllerTest {

    // setup
    @TestConfiguration
    static class TestSecurityConfig {
        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
            http
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private ExternalLinkService externalLinkService;

    @MockitoBean
    private JwtUtil jwtUtil;


    // ========== GET Testing (GET /api/external-links) ==========
    
    @Test
    void getUserExternalLinks_validToken_returns200() throws Exception {
        // Arrange
        ExternalLinkResponse mockResponse = new ExternalLinkResponse(
            1,
            "Recipe Link",
            "https://www.link.com",
            OffsetDateTime.parse("2026-08-31T23:00:00Z"),
            null
        );

        when(externalLinkService.getExternalLinks(anyInt())).thenReturn(List.of(mockResponse));

        // Act and assert
        mockMvc.perform(get("/api/external-links").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].link_id").value(1))
                .andExpect(jsonPath("$[0].name").value("Recipe Link"))
                .andExpect(jsonPath("$[0].url").value("https://www.link.com"))
                .andExpect(jsonPath("$[0].created_at").value("2026-08-31T23:00:00Z"))
                .andExpect(jsonPath("$[0].updated_at").doesNotExist());
    }


    @Test
    void getUserExternalLinks_validToken_returns200EmptyList() throws Exception {
        // Arrange
        when(externalLinkService.getExternalLinks(anyInt())).thenReturn(List.of());

        // Act and assert
        mockMvc.perform(get("/api/external-links").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }


    // ========== POST Testing (POST /api/external-links) ==========
    
    @Test
    void createExternalLink_validRequest_returns200() throws Exception {
        // Arrange
        ExternalLinkRequest mockRequest = new ExternalLinkRequest(
            "Recipe Link",
            "https://www.link.com"
        );

        ExternalLinkResponse mockResponse = new ExternalLinkResponse(
            1,
            "Recipe Link",
            "https://www.link.com",
            OffsetDateTime.parse("2026-08-31T23:00:00Z"),
            null
        );

        when(externalLinkService.createExternalLink(anyInt(), any(ExternalLinkRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(post("/api/external-links").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.link_id").value(1))
                .andExpect(jsonPath("$.name").value("Recipe Link"))
                .andExpect(jsonPath("$.url").value("https://www.link.com"))
                .andExpect(jsonPath("$.created_at").value("2026-08-31T23:00:00Z"));

    }

    @Test
    void createExternalLink_blankName_returns400() throws Exception {
        // Arrange
        ExternalLinkRequest mockRequest = new ExternalLinkRequest(
            "",
            "https://www.link.com"
        );

        // Act and assert
        mockMvc.perform(post("/api/external-links").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isBadRequest());
               
        verify(externalLinkService, never()).createExternalLink(anyInt(), any());
    }

    @Test
    void createExternalLink_badRequestBody_return400() throws Exception {
        // Arrange
        String badRequest = """
                    {
                        "name",
                        2
                    }
                """;

        // Act and Assert
        mockMvc.perform(post("/api/external-links").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(badRequest))
                .andExpect(status().isBadRequest());
    }


    // ========== PUT Testing (PUT /api/external-links/{linkId}) ==========

    @Test
    void updateExternalLink_validRequest_returns200() throws Exception {
        // Arrange
        ExternalLinkRequest mockRequest = new ExternalLinkRequest(
            "Update Link 1",
            "https://www.updatelink1.com"
        );

        ExternalLinkResponse mockResponse = new ExternalLinkResponse(
            3,
            "Update Link 1",
            "https://www.updatelink1.com",
            OffsetDateTime.parse("2026-08-31T23:00:00Z"),
            OffsetDateTime.parse("2026-08-31T23:00:00Z")
        );

        when(externalLinkService.updateExternalLink(eq(3), anyInt(), any(ExternalLinkRequest.class))).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(put("/api/external-links/{linkId}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.link_id").value(3))
                .andExpect(jsonPath("$.name").value("Update Link 1"))
                .andExpect(jsonPath("$.url").value("https://www.updatelink1.com"))
                .andExpect(jsonPath("$.created_at").exists())
                .andExpect(jsonPath("$.updated_at").exists());
    }

    @Test
    void updateExternalLink_linkNotFound_returns404() throws Exception {
        // Arrange
        ExternalLinkRequest mockRequest = new ExternalLinkRequest(
            "Update Link 1",
            "https://www.updatelink1.com"
        );

        when(externalLinkService.updateExternalLink(eq(99), anyInt(), any(ExternalLinkRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Link not found"));

        // Act and assert
        mockMvc.perform(put("/api/external-links/{linkId}", 99).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                // fields in response object
                .andExpect(jsonPath("$.message").value("Link not found"));
    }

    // ========== DELETE Testing (DELETE /api/external-links/{linkId}) ==========

    @Test
    void deleteExternalLink_validDelete_returns200() throws Exception {
        // Arrange
        doNothing().when(externalLinkService).deleteExternalLink(eq(3), anyInt());

        // Act and assert
        mockMvc.perform(delete("/api/external-links/{linkId}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))     
                .andExpect(status().isNoContent())
                .andExpect(content().string(""));

    }

    @Test
    void deleteExternalLink_linkNotFound_returns404() throws Exception {
        // Arrange
        doThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Link not found")).when(externalLinkService).deleteExternalLink(eq(3), anyInt());

        // Act and assert
        mockMvc.perform(delete("/api/external-links/{linkId}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))     
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Link not found"));
    }
}