// unit testing for allergens

package com.mealchemy.allergens;

// dtos
import com.mealchemy.allergens.dto.AllergenOptionsResponse;

// controller
import com.mealchemy.allergens.controller.AllergenOptionsController;

// import service
import com.mealchemy.allergens.service.AllergenOptionsService;

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


@WebMvcTest(AllergenOptionsController.class)
public class AllergenOptionsControllerTest {

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
    private AllergenOptionsService allergenOptionsService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /allergies/all) ==========

    @Test
    void getAllEquipmentOptions_return200() throws Exception {
        // Arrange - mock response
        AllergenOptionsResponse peanuts = new AllergenOptionsResponse(
            1, 
            "PEANUTS", 
            "Peanuts"
        );

        AllergenOptionsResponse dairy = new AllergenOptionsResponse(
            2, 
            "DAIRY", 
            "Dairy"
        );

        AllergenOptionsResponse soy = new AllergenOptionsResponse(
            3, 
            "SOY", 
            "Soy"
        );

        AllergenOptionsResponse fish = new AllergenOptionsResponse(
            4, 
            "FISH", 
            "Fish"
        );

        when(allergenOptionsService.getAllAllergenOptions()).thenReturn(List.of(peanuts, dairy, soy, fish));


        // Act and assert
        mockMvc.perform(get("/allergies/all").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].value").value("PEANUTS"))
                .andExpect(jsonPath("$[0].label").value("Peanuts"))
                .andExpect(jsonPath("$[2].value").value("SOY"))
                .andExpect(jsonPath("$[2].label").value("Soy"));
    }
}
