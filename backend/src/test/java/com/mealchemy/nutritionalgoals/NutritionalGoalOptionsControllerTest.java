// unit testing for allergens

package com.mealchemy.nutritionalgoals;

// dtos
import com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse;

// controller
import com.mealchemy.nutritionalgoals.controller.NutritionalGoalOptionsController;

// import service
import com.mealchemy.nutritionalgoals.service.NutritionalGoalOptionsService;

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


@WebMvcTest(NutritionalGoalOptionsController.class)
public class NutritionalGoalOptionsControllerTest {

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
    private NutritionalGoalOptionsService nutritionalGoalOptionsService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /nutritionalgoals/all) ==========

    @Test
    void getAllNutritionalGoalOptions_return200() throws Exception {
        // Arrange - mock response
        NutritionalGoalOptionsResponse highProtein = new NutritionalGoalOptionsResponse(
            1, 
            "HIGH_PROTEIN", 
            "High Protein"
        );

        NutritionalGoalOptionsResponse lowCarb = new NutritionalGoalOptionsResponse(
            2, 
            "LOW_CARB", 
            "Low Carb"
        );


        when(nutritionalGoalOptionsService.getAllNutritionalGoalOptions()).thenReturn(List.of(highProtein, lowCarb));


        // Act and assert
        mockMvc.perform(get("/nutritionalgoals/all").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].value").value("HIGH_PROTEIN"))
                .andExpect(jsonPath("$[0].label").value("High Protein"))
                .andExpect(jsonPath("$[1].value").value("LOW_CARB"))
                .andExpect(jsonPath("$[1].label").value("Low Carb"));
    }
}
