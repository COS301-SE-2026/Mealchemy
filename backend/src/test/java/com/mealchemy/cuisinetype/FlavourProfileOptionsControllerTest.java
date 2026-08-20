// unit testing for flavour profile options

package com.mealchemy.cuisinetype;

// dtos
import com.mealchemy.cuisinetype.dto.FlavourProfileOptionsResponse;

// controller
import com.mealchemy.cuisinetype.controller.FlavourProfileOptionsController;

// import service
import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;

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


@WebMvcTest(FlavourProfileOptionsController.class)
public class FlavourProfileOptionsControllerTest {

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
    private FlavourProfileOptionsService flavourProfileOptionsService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /cuisinetype/all) ==========

    @Test
    void getAllFlavourProfileOptions_return200() throws Exception {
        // Arrange - mock response
        FlavourProfileOptionsResponse italian = new FlavourProfileOptionsResponse(
            "ITALIAN", 
            "Italian"
        );

        FlavourProfileOptionsResponse mexican = new FlavourProfileOptionsResponse(
            "MEXICAN", 
            "Mexican"
        );

        FlavourProfileOptionsResponse caribbean = new FlavourProfileOptionsResponse(
            "CARIBBEAN", 
            "Caribbean"
        );


        when(flavourProfileOptionsService.getAllCuisineTypes()).thenReturn(List.of(italian, mexican, caribbean));

        // Act and assert
        mockMvc.perform(get("/flavourprofileoptions/all").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].value").value("ITALIAN"))
                .andExpect(jsonPath("$[0].label").value("Italian"))
                .andExpect(jsonPath("$[2].value").value("CARIBBEAN"))
                .andExpect(jsonPath("$[2].label").value("Caribbean"));
    }
}
