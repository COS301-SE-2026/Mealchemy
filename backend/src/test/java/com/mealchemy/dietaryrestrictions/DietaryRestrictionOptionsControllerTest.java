// unit testing for allergens

package com.mealchemy.dietaryrestrictions;

// dtos
import com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse;

// controller
import com.mealchemy.dietaryrestrictions.controller.DietaryRestrictionOptionsController;

// import service
import com.mealchemy.dietaryrestrictions.service.DietaryRestrictionOptionsService;

import com.mealchemy.config.JwtUtil;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(DietaryRestrictionOptionsController.class)
public class DietaryRestrictionOptionsControllerTest {

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
    private DietaryRestrictionOptionsService dietaryRestrictionOptionsService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /dietaryrestrictions/all) ==========

    @Test
    void getAllDietaryRestrictionOptions_return200() throws Exception {
        // Arrange - mock response
        DietaryRestrictionOptionsResponse vegetarian = new DietaryRestrictionOptionsResponse(
            1, 
            "VEGETARIAN", 
            "Vegetarian"
        );

        DietaryRestrictionOptionsResponse glutenFree = new DietaryRestrictionOptionsResponse(
            2, 
            "GLUTEN_FREE", 
            "Gluten Free"
        );

        DietaryRestrictionOptionsResponse diabetesFriendly = new DietaryRestrictionOptionsResponse(
            3, 
            "DIABETES_Friendly", 
            "Diabetes-Friendly"
        );


        when(dietaryRestrictionOptionsService.getAllDietaryRestrictionOptions()).thenReturn(List.of(vegetarian, glutenFree, diabetesFriendly));


        // Act and assert
        mockMvc.perform(get("/dietaryrestrictions/all").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].value").value("VEGETARIAN"))
                .andExpect(jsonPath("$[0].label").value("Vegetarian"))
                .andExpect(jsonPath("$[2].value").value("DIABETES_Friendly"))
                .andExpect(jsonPath("$[2].label").value("Diabetes-Friendly"));
    }
}
