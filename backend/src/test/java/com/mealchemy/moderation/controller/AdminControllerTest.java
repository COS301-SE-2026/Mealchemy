package com.mealchemy.moderation;

// dtos
import com.mealchemy.moderation.dto.FlaggedRecipeResponse;
import com.mealchemy.moderation.dto.FlaggedRecipeDetailResponse;
import com.mealchemy.moderation.dto.UserSummaryResponse;
import com.mealchemy.recipe.dto.RecipeResponse;

// controller
import com.mealchemy.moderation.controller.AdminController;

// import service
import com.mealchemy.moderation.service.FlagService;
import com.mealchemy.moderation.service.AdminService;

// enums
import com.mealchemy.shared.enums.FlagStatus;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(AdminController.class)
public class AdminControllerTest {

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
    private FlagService flagService;
    
    @MockitoBean
    private AdminService adminService;

    @MockitoBean
    private JwtUtil jwtUtil;


    // ========== Dealing with flagged recipes ==========

    // ========== GET Testing (GET /admin/flags) ==========

    @Test 
    void getFlagsByStatus_noStatusParam_returns200() throws Exception {
        // Arrange - mock response 
        FlaggedRecipeResponse mockResponse = new FlaggedRecipeResponse(
            12, // flaggedId
            87, // recipeId
            "Penne Alla Vodka",
            "https://photoUr.com/penne,jpeg",
            4, // userId
            "SPAM_MISLEADING",
            "Spam / misleading",
            FlagStatus.PENDING,
            OffsetDateTime.parse("2026-09-17T23:00:00Z")
        );
        
        when(flagService.getFlags(isNull(), anyInt())).thenReturn(List.of(mockResponse));

        // Act and assert
        mockMvc.perform(get("/admin/flags").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].flagged_id").value(12))
                .andExpect(jsonPath("$[0].recipe_id").value(87))
                .andExpect(jsonPath("$[0].recipe_title").value("Penne Alla Vodka"))
                .andExpect(jsonPath("$[0].recipe_photo_url").value("https://photoUr.com/penne,jpeg"))
                .andExpect(jsonPath("$[0].flagged_by_user_id").value(4))
                .andExpect(jsonPath("$[0].reason_value").value("SPAM_MISLEADING"))
                .andExpect(jsonPath("$[0].reason_label").value("Spam / misleading"))
                .andExpect(jsonPath("$[0].status").value("PENDING"));
    }


    @Test 
    void getFlagsByStatus_withStatusParam_returns200() throws Exception {
        // Arrange - mock response 
        FlaggedRecipeResponse mockResponse = new FlaggedRecipeResponse(
            13, // flaggedId
            87, // recipeId
            "Penne Alla Vodka",
            "https://photoUr.com/penne,jpeg",
            4, // userId
            "SPAM_MISLEADING",
            "Spam / misleading",
            FlagStatus.REVIEWED,
            OffsetDateTime.parse("2026-09-17T23:00:00Z")
        );
        
        when(flagService.getFlags(eq(FlagStatus.REVIEWED), anyInt())).thenReturn(List.of(mockResponse));

        // Act and assert
        mockMvc.perform(get("/admin/flags").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].flagged_id").value(13))
                .andExpect(jsonPath("$[0].status").value("REVIEWED"));
    }

    @Test 
    void getFlagsByStatus_validToken_returns200EmptyList() throws Exception {
        // Arrange 
        when(flagService.getFlags(isNull(), anyInt())).thenReturn(List.of());

        // Act and assert
        mockMvc.perform(get("/admin/flags").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test 
    void getFlagsByStatus_notAdmin_returns403() throws Exception {
        // Arrange
        when(flagService.getFlags(isNull(), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin."));

        // Act and Assert
        mockMvc.perform(get("/admin/flags").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User is not an Admin."));
    }

    @Test 
    void getFlagsByStatus_adminUserNotFound_returns404() throws Exception {
        // Arrange 
        when(flagService.getFlags(isNull(), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        // Act and Assert
        mockMvc.perform(get("/admin/flags").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found."));
    }


    // ========== GET Testing (GET /admin/flags/{flaggedId}) ==========

    @Test
    void getFlaggedRecipeDetails_validToken_returns200() throws Exception {
        // Arrange
        RecipeResponse mockRecipeResponse = new RecipeResponse(
            87,
            9, 
            "Penne Alla Vodka",
            "Weeknigh favourite",
            "ITALIAN",
            30,
            4,
            "https://photoUr.com/penne,jpeg",
            null,
            null,
            true,
            OffsetDateTime.parse("2026-09-17T23:00:00Z"),
            OffsetDateTime.parse("2026-09-17T23:00:00Z"),
            null
        );

         FlaggedRecipeDetailResponse mockDetailedResponse = new FlaggedRecipeDetailResponse(
            12, // flaggedId
            87, // recipeId
            "Penne Alla Vodka",
            "https://photoUr.com/penne,jpeg",
            4, // userId
            "SPAM_MISLEADING",
            "Spam / misleading",
            FlagStatus.PENDING,
            OffsetDateTime.parse("2026-09-17T23:00:00Z"),
            mockRecipeResponse
        );

        when(flagService.getFlagDetail(eq(12), anyInt())).thenReturn(mockDetailedResponse);

        // Act and assert
        mockMvc.perform(get("/admin/flags/{flaggedId}", 12).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.flagged_id").value(12))
                .andExpect(jsonPath("$.reason_value").value("SPAM_MISLEADING"))
                .andExpect(jsonPath("$.reason_label").value("Spam / misleading"))
                .andExpect(jsonPath("$.recipeResponse.title").value("Penne Alla Vodka"))
                .andExpect(jsonPath("$.recipeResponse.isCommunityPublished").value(true));
    }


    @Test 
    void getFlaggedRecipeDetails_notAdmin_returns403() throws Exception {
        // Arrange 
        when(flagService.getFlagDetail(eq(12), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin."));

        // Act and Assert
        mockMvc.perform(get("/admin/flags/{flaggedId}", 12).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User is not an Admin."));
    }

    @Test 
    void getFlaggedRecipeDetails_flagNotFound_returns404() throws Exception {
        // Arrange
        when(flagService.getFlagDetail(eq(999), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Flag not found."));

        // Act and Assert
        mockMvc.perform(get("/admin/flags/{flaggedId}", 999).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Flag not found."));
    }


    // ========== PUT Testing (PUT /admin/flags/{flaggedId}/dismiss) ==========

    @Test
    void dismissFlaggedRecipe_validRequest_return200() throws Exception {
        // Arrange - mock response 
        FlaggedRecipeResponse mockResponse = new FlaggedRecipeResponse(
            12, // flaggedId
            87, // recipeId
            "Penne Alla Vodka",
            "https://photoUr.com/penne,jpeg",
            4, // userId
            "SPAM_MISLEADING",
            "Spam / misleading",
            FlagStatus.REVIEWED,
            OffsetDateTime.parse("2026-09-17T23:00:00Z")
        );
        
        when(flagService.dismissFlag(eq(12), anyInt())).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(put("/admin/flags/{flaggedId}/dismiss", 12).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.flagged_id").value(12))
                .andExpect(jsonPath("$.status").value("REVIEWED"));
    }

    @Test 
    void dismissFlaggedRecipe_notAdmin_returns403() throws Exception {
        // Arrange
        when(flagService.dismissFlag(eq(12), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin."));

        // Act and Assert
        mockMvc.perform(put("/admin/flags/{flaggedId}/dismiss", 12).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User is not an Admin."));
    }

    @Test 
    void dismissFlaggedRecipe_flagNotFound_returns404() throws Exception {
        // Arrange
        when(flagService.dismissFlag(eq(999), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Flag not found."));

        // Act and Assert
        mockMvc.perform(put("/admin/flags/{flaggedId}/dismiss", 999).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Flag not found."));
    }


    // ========== DELETE Testing (DELETE /admin/flags/{flaggedId}/recipe) ==========

    @Test
    void removeFlaggedRecipe_validRequest_return200() throws Exception {
        // Arrange - mock response 
        FlaggedRecipeResponse mockResponse = new FlaggedRecipeResponse(
            12, // flaggedId
            87, // recipeId
            "Penne Alla Vodka",
            "https://photoUr.com/penne,jpeg",
            4, // userId
            "SPAM_MISLEADING",
            "Spam / misleading",
            FlagStatus.REMOVED,
            OffsetDateTime.parse("2026-09-17T23:00:00Z")
        );
        
        when(flagService.removeFlaggedRecipe(eq(12), anyInt())).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(delete("/admin/flags/{flaggedId}/recipe", 12).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.flagged_id").value(12))
                .andExpect(jsonPath("$.status").value("REMOVED"));
    }

    @Test 
    void removeFlaggedRecipe_notAdmin_returns403() throws Exception {
        // Arrange 
        when(flagService.removeFlaggedRecipe(eq(12), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin."));

        // Act and Assert
        mockMvc.perform(delete("/admin/flags/{flaggedId}/recipe", 12).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User is not an Admin."));
    }

    @Test 
    void removeFlaggedRecipe_flagNotFound_returns404() throws Exception {
        // Arrange
        when(flagService.removeFlaggedRecipe(eq(999), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Flag not found."));

        // Act and Assert
        mockMvc.perform(delete("/admin/flags/{flaggedId}/recipe", 999).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Flag not found."));
    }



    // ========== Dealing with promoting a User to admin ==========

    // ========== GET Testing (GET /admin/users) ==========

    @Test
    void findUserByEmail_validRequest_return200() throws Exception {
        // Arrange - mock response  
        UserSummaryResponse mockResponse = new UserSummaryResponse(
            1,
            "Test User",
            "testuser@email.com",
            List.of("USER")
        );

        when(adminService.findUserByEmail(eq("testuser@email.com"), anyInt())).thenReturn(mockResponse);
        
        // Act and assert
        mockMvc.perform(get("/admin/users").param("email", "testuser@email.com").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.user_id").value(1))
                .andExpect(jsonPath("$.display_name").value("Test User"))
                .andExpect(jsonPath("$.email").value("testuser@email.com"))
                .andExpect(jsonPath("$.roles[0]").value("USER"));
    }

    @Test
    void findUserByEmail_emailParamMissing_return400() throws Exception {
        // Act and assert
        mockMvc.perform(get("/admin/users").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isBadRequest());
    }

    @Test
    void findUserByEmail_notAdmin_return403() throws Exception {
        // Arrange
        when(adminService.findUserByEmail(eq("testuser@email.com"), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin."));

        // Act and assert
        mockMvc.perform(get("/admin/users").param("email", "testuser@email.com").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User is not an Admin."));
    }

    @Test 
    void findUserByEmail_userNotFound_returns404() throws Exception {
        // Arrange
        when(adminService.findUserByEmail(eq("nobody@email.com"), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        // Act and Assert
        mockMvc.perform(get("/admin/users").param("email", "nobody@email.com").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found."));
    }


    // ========== PUT Testing (PUT /admin/users/{userId}/promote) ==========

    @Test
    void promoteUserToAdmin_validRequest_return200() throws Exception {
        // Arrange - mock response
        UserSummaryResponse mockResponse = new UserSummaryResponse(
            4,
            "New Admin",
            "newadmin@email.com",
            List.of("USER", "ADMIN")
        );

        when(adminService.promoteToAdmin(eq(4), anyInt())).thenReturn(mockResponse);

        // Act and assert
        mockMvc.perform(put("/admin/users/{userId}/promote", 4).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$.user_id").value(4))
                .andExpect(jsonPath("$.roles[1]").value("ADMIN"));
    }

    @Test
    void promoteUserToAdmin_notAdming_return403() throws Exception {
        // Arrange
        when(adminService.promoteToAdmin(eq(4), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User is not an Admin."));

        // Act and assert
        mockMvc.perform(put("/admin/users/{userId}/promote", 4).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User is not an Admin."));
    }

    @Test 
    void promoteUserToAdmin_targetUserNotFound_returns404() throws Exception {
        // Arrange
        when(adminService.promoteToAdmin(eq(99), anyInt())).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

       // Act and assert
        mockMvc.perform(put("/admin/users/{userId}/promote", 99).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found."));
    }
}