// unit testing for unit of measurement

package com.mealchemy.unit;

// dtos
import com.mealchemy.unit.dto.UnitOfMeasurementResponse;

// controller
import com.mealchemy.unit.controller.UnitOfMeasurementController;

// enum
import com.mealchemy.shared.enums.MeasurementSystem;

// import service
import com.mealchemy.unit.service.UnitOfMeasurementService;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;

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
import java.math.BigDecimal;
import java.time.OffsetDateTime;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(UnitOfMeasurementController.class)
public class UnitOfMeasurementControllerTest {

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
    private UnitOfMeasurementService unitOfMeasurementService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /api/units-of-measurement) ==========

    @Test
    void getAllUnitsOfMeasurement_return200() throws Exception {
        // Arrange - mock response
        UnitOfMeasurementResponse unit1 = new UnitOfMeasurementResponse(
            1,
            "g",
            MeasurementSystem.METRIC
        );

        UnitOfMeasurementResponse unit2 = new UnitOfMeasurementResponse(
            2,
            "kg",
            MeasurementSystem.METRIC
        );

        UnitOfMeasurementResponse unit3 = new UnitOfMeasurementResponse(
            3,
            "oz",
            MeasurementSystem.IMPERIAL
        );
        
        UnitOfMeasurementResponse unit4 = new UnitOfMeasurementResponse(
            4,
            "lb",
            MeasurementSystem.IMPERIAL
        );

        when(unitOfMeasurementService.getUnitsForUser(anyInt())).thenReturn(List.of(unit1, unit2, unit3, unit4));

        // Act and assert
        mockMvc.perform(get("/api/units-of-measurement").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].name").value("g"))
                .andExpect(jsonPath("$[0].system").value("METRIC"))
                .andExpect(jsonPath("$[2].name").value("oz"))
                .andExpect(jsonPath("$[2].system").value("IMPERIAL"));
    }
}
