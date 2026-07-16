package com.mealchemy.pantry;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;
// controller
import com.mealchemy.pantry.controller.PantryController;
// dtos
import com.mealchemy.pantry.dto.PantryIngredientRequest;
import com.mealchemy.pantry.dto.PantryIngredientResponse;
// service
import com.mealchemy.pantry.service.PantryService;

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

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PantryController.class)
public class PantryControllerTest {

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
    private PantryService pantryService;

    @MockitoBean
    private JwtUtil jwtUtil;


    // ========== GET Testing (GET /api/pantry) ==========
    
    @Test
    void getUserPantryIngredients_validToken_returns200() throws Exception {
        // Arrange - mock response
        PantryIngredientResponse mockResponse = new PantryIngredientResponse(
            1,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("250"),
            "g",
            OffsetDateTime.parse("2026-07-17T14:00:00Z"),
            OffsetDateTime.parse("2026-07-17T14:00:00Z")
        );

        when(pantryService.getUserPantryItems(anyInt())).thenReturn(List.of(mockResponse));

        // Act and assert
        mockMvc.perform(get("/api/pantry").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].p_ingredient_id").value(1))
                .andExpect(jsonPath("$[0].ing_id").value(2))
                .andExpect(jsonPath("$[0].name").value("Hummus"))
                .andExpect(jsonPath("$[0].category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$[0].quantity").value(250))
                .andExpect(jsonPath("$[0].unit").value("g"));
    }

    @Test
    void getUserPantryIngredients_validToken_return200EmptyList() throws Exception {
        // Arrange
        when(pantryService.getUserPantryItems(anyInt())).thenReturn(List.of());

        // Act and assert
        mockMvc.perform(get("/api/pantry").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // check response is array 
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }


    // ========== POST Testing (POST /api/pantry) ==========

    // new ingredient added manually
    @Test
    void addPantryIngredient_validRequest_return200() throws Exception {
        // Arrange - mock request
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("250"),
            "g"
        );

        PantryIngredientResponse mockResponse = new PantryIngredientResponse(
            3,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("250"),
            "g",
            OffsetDateTime.parse("2026-07-17T14:00:00Z"),
            OffsetDateTime.parse("2026-07-17T14:00:00Z")
        );

        when(pantryService.addIngredientManually(anyInt(), any(PantryIngredientRequest.class))).thenReturn(mockResponse);

        // Act and Assert
        mockMvc.perform(post("/api/pantry").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.p_ingredient_id").value(3))
                .andExpect(jsonPath("$.ing_id").value(2))
                .andExpect(jsonPath("$.name").value("Hummus"))
                .andExpect(jsonPath("$.category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.quantity").value(250))
                .andExpect(jsonPath("$.unit").value("g"))
                .andExpect(jsonPath("$.created_at").value("2026-07-17T14:00:00Z"))
                .andExpect(jsonPath("$.updated_at").value("2026-07-17T14:00:00Z"));
    }

    @Test
    void addPantryIngredient_ingIdNotInCatalogue() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("250"),
            "g"
        );

        when(pantryService.addIngredientManually(anyInt(), any(PantryIngredientRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found"));

        // Act and Assert
        mockMvc.perform(post("/api/pantry").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Ingredient not found"));
    }

    //bad request body
    @Test
    void addPantryIngredient_badRequestBody_return400() throws Exception {
        // Arrange
        // Bad request
       String badRequest = """
                    {
                        2,
                        "non-numerical"
                        "g"
                    }
                """;

        // Act and Assert
        mockMvc.perform(post("/api/pantry").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(badRequest))
                .andExpect(status().isBadRequest());
    }


    // ========== PUT Testing (PUT /api/pantry/{id}) ==========

    @Test 
    void updatePantryIngredient_quantityGreaterThanZero_return200() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("100"),
            "g"
        );

        PantryIngredientResponse mockResponse = new PantryIngredientResponse(
            3,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("100"),
            "g",
            OffsetDateTime.parse("2026-07-17T14:00:00Z"),
            OffsetDateTime.parse("2026-07-17T14:00:00Z")
        );

        when(pantryService.updateIngredientManually(anyInt(), eq(3), any(PantryIngredientRequest.class))).thenReturn(Optional.of(mockResponse));

        // Act 
        mockMvc.perform(put("/api/pantry/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))) //check {id}
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.p_ingredient_id").value(3))
                .andExpect(jsonPath("$.ing_id").value(2))
                .andExpect(jsonPath("$.name").value("Hummus"))
                .andExpect(jsonPath("$.category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$.quantity").value(100))
                .andExpect(jsonPath("$.unit").value("g"))
                .andExpect(jsonPath("$.created_at").exists())
                .andExpect(jsonPath("$.updated_at").exists());
    }

    @Test 
    void updatePantryIngredient_quantityZero_return204() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("100"),
            "g"
        );

        when(pantryService.updateIngredientManually(anyInt(), anyInt(), any(PantryIngredientRequest.class))).thenReturn(Optional.empty());

        // Act and assert
        mockMvc.perform(put("/api/pantry/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))) //check {id}
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))        
                .andExpect(status().isNoContent())
                // check response is array 
                .andExpect(content().string(""));
    }

    @Test 
    void updatePantryIngredient_itemDoesNotExist_return404() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("100"),
            "g"
        );

        when(pantryService.updateIngredientManually(anyInt(), anyInt(), any(PantryIngredientRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found"));

        // Act and Assert
        mockMvc.perform(put("/api/pantry/{id}", 3)
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest)))    
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Ingredient not found"));
    }

    @Test 
    void updatePantryIngredient_ingredientNotOwnedByUser_return403() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("100"),
            "g"
        );

        when(pantryService.updateIngredientManually(anyInt(), eq(3), any(PantryIngredientRequest.class))).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User does not own this ingredient"));

        // Act and Assert
        mockMvc.perform(put("/api/pantry/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest))) 
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User does not own this ingredient"));
    }
    

    // {id} not int
    @Test
    void updatePantryIngredient_idNotInt_return400() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("100"),
            "g"
        );

        mockMvc.perform(put("/api/pantry/{id}", "non-int").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest))) 
                .andExpect(status().isBadRequest());
    }


    // ========== DELETE Testing (DELETE /api/pantry/{id}) ==========

    @Test
    void removePantryIngredient_validDelete_return204() throws Exception {
        // delete doesn't need request body

       // delete is void, doesn't return anything

        // Act and assert
        mockMvc.perform(delete("/api/pantry/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))) //check {id}    
                .andExpect(status().isNoContent())
                .andExpect(content().string(""));
    }

    @Test
    void removePantryIngredient_ingredientDoesNotExist_return404() throws Exception {

        when(pantryService.removePantryIngredient(anyInt(), eq(3))).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found"));

        // Act and Assert
        mockMvc.perform(delete("/api/pantry/{id}", 3).with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Ingredient not found"));
    }

    @Test
    void removePantryIngredient_ingredientNotOwnedByUser_return403() throws Exception {
        // Arrange
        PantryIngredientRequest mockRequest = new PantryIngredientRequest(
            2,
            new BigDecimal("100"),
            "g"
        );

        when(pantryService.removePantryIngredient(anyInt(), eq(3))).thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "User does not own this ingredient"));

        // Act and Assert
        mockMvc.perform(delete("/api/pantry/{id}", 3)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(mockRequest))    
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("User does not own this ingredient"));
    }


    // ========== GET Testing (DELETE /api/pantry/search?=) ==========

    @Test
    void searchPantryIngredients_matchFound_returns200() throws Exception {
        // Arrange
        PantryIngredientResponse mockResponse = new PantryIngredientResponse(
            3,
            2,
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("100"),
            "g",
            OffsetDateTime.parse("2026-07-17T14:00:00Z"),
            OffsetDateTime.parse("2026-07-17T14:00:00Z")
        );

        when(pantryService.getIngredientByName(anyInt(), eq("hummus"))).thenReturn(List.of(mockResponse));

        // Act and Assert
        mockMvc.perform(get("/api/pantry/search").param("q", "hummus")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].p_ingredient_id").value(3))
                .andExpect(jsonPath("$[0].ing_id").value(2))
                .andExpect(jsonPath("$[0].name").value("Hummus"))
                .andExpect(jsonPath("$[0].category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$[0].quantity").value(100))
                .andExpect(jsonPath("$[0].unit").value("g"));
    }

    @Test
    void searchPantryIngredients_noMatch_returns200EmptyArray() throws Exception {
        // Arrange
        when(pantryService.getIngredientByName(anyInt(), eq("not-found"))).thenReturn(List.of());

        // Act and Assert
        mockMvc.perform(get("/api/pantry/search").param("q", "not-found")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }
}