// unit testing for equipment

package com.mealchemy.equipment;

// dtos
import com.mealchemy.equipment.dto.EquipmentResponse;

// controller
import com.mealchemy.equipment.controller.EquipmentController;

// import service
import com.mealchemy.equipment.service.EquipmentService;

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

import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;


@WebMvcTest(EquipmentController.class)
public class EquipmentControllerTest {

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
    private EquipmentService equipmentService;

    @MockitoBean
    private JwtUtil jwtUtil;

    // ========== GET Testing (GET /api/equipment) ==========

    @Test
    void getAllEquipmentOptions_return200() throws Exception {
        // Arrange - mock response
        EquipmentResponse oven = new EquipmentResponse(
            1,
            "OVEN",
            "Oven"
        );

        EquipmentResponse airfryer = new EquipmentResponse(
            2,
            "AIRFRYER",
            "Airfryer"
        );

        EquipmentResponse microwave = new EquipmentResponse(
            3,
            "MICROWAVE",
            "Microwave"
        );
        
        EquipmentResponse blender = new EquipmentResponse(
            4,
            "BLENDER",
            "Blender"
        );

        when(equipmentService.getAllEquipmentOptions()).thenReturn(List.of(oven, airfryer, microwave, blender));

        // Act and assert
        mockMvc.perform(get("/api/equipment").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].value").value("OVEN"))
                .andExpect(jsonPath("$[0].label").value("Oven"))
                .andExpect(jsonPath("$[2].value").value("MICROWAVE"))
                .andExpect(jsonPath("$[2].label").value("Microwave"));
    }
}
