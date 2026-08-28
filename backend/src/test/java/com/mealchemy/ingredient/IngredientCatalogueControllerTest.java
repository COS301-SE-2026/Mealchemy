package com.mealchemy.ingredient;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mealchemy.config.JwtUtil;
// controller
import com.mealchemy.ingredient.controller.IngredientCatalogueController;
// dtos
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;
import com.mealchemy.ingredient.dto.IngredientSearchResponse;
// service
import com.mealchemy.ingredient.service.IngredientCatalogueService;
import com.mealchemy.ingredient.service.CategoryRequiredException;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.nullValue;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(IngredientCatalogueController.class)
public class IngredientCatalogueControllerTest {

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
    private IngredientCatalogueService ingredientCatalogueService;

    @MockitoBean
    private JwtUtil jwtUtil;


    // ========== GET Testing (GET /api/ingredient-catalogue) ==========

    @Test
    void getIngredientCatalogue_validToken_returns200() throws Exception {
        // Arrange - mock response
        IngredientCatalogueResponse mockResponse = new IngredientCatalogueResponse(
            1,
            "Hummus",
            "Legumes and Legume Products"
        );

        when(ingredientCatalogueService.getIngredientCatalogue()).thenReturn(List.of(mockResponse));

        // Act and assert
        mockMvc.perform(get("/api/ingredient-catalogue").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // fields in response object
                .andExpect(jsonPath("$[0].ing_id").value(1))
                .andExpect(jsonPath("$[0].name").value("Hummus"))
                .andExpect(jsonPath("$[0].category").value("Legumes and Legume Products"));
    }

    @Test
    void getIngredientCatalogue_validToken_return200EmptyList() throws Exception {
        // Arrange
        when(ingredientCatalogueService.getIngredientCatalogue()).thenReturn(List.of());

        // Act and assert
        mockMvc.perform(get("/api/ingredient-catalogue").with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))
                .andExpect(status().isOk())
                // check response is array 
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    // ========== GET Testing (GET /api/ingredient-catalogue/search?=) ==========

    @Test
    void getIngredientFromCatalogueByName_matchFoundInLocalCatalogue_returns200() throws Exception {
        // Arrange
        IngredientSearchResponse localMatch = new IngredientSearchResponse(
            1,
            "Hummus",
            "Legumes and Legume Products",
            null,
            null
        );

        when(ingredientCatalogueService.getIngredientByName(eq("hummus"))).thenReturn(List.of(localMatch));

        // Act and Assert
        mockMvc.perform(get("/api/ingredient-catalogue/search").param("q", "hummus")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].ing_id").value(1))
                .andExpect(jsonPath("$[0].name").value("Hummus"))
                .andExpect(jsonPath("$[0].category").value("Legumes and Legume Products"))
                .andExpect(jsonPath("$[0].source_id").value(nullValue()))
                .andExpect(jsonPath("$[0].source_api").value(nullValue()));
    }

    @Test
    void getIngredientFromCatalogueByName_noMatch_returns200EmptyArray() throws Exception {
        // Arrange
        when(ingredientCatalogueService.getIngredientByName(eq("not-found"))).thenReturn(List.of());

        // Act and Assert
        mockMvc.perform(get("/api/ingredient-catalogue/search").param("q", "not-found")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void getIngredientFromCatalogueByName_usdaFallBack_returnsNullIngId() throws Exception {
        // Arrange
        IngredientSearchResponse externalMatch = new IngredientSearchResponse(
            null,
            "Kimchi",
            null,
            "2710077",
            "USDA"
        );

        when(ingredientCatalogueService.getIngredientByName(eq("kimchi"))).thenReturn(List.of(externalMatch));

        // Act and Assert
        mockMvc.perform(get("/api/ingredient-catalogue/search").param("q", "kimchi")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of()))))  
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].ing_id").value(nullValue()))
                .andExpect(jsonPath("$[0].name").value("Kimchi"))
                .andExpect(jsonPath("$[0].category").value(nullValue()))
                .andExpect(jsonPath("$[0].source_id").value("2710077"))
                .andExpect(jsonPath("$[0].source_api").value("USDA"));
    }

    // ========== POST Testing (POST /api/ingredient-catalogue/add-external) ==========
    @Test
    void addExternalIngredient_ingredientAddedSuccessfully_returns200WithSavedIngredient() throws Exception {
        // Arrange
        IngredientCatalogueResponse saved = new IngredientCatalogueResponse(
            306, 
            "Kimchi", 
            "Vegetables and Vegetable Products"
        );

        when(ingredientCatalogueService.saveExternalIngredientToCatalogue(eq("2710077"), isNull())).thenReturn(saved);

        String requestBody = """
                { 
                    "source_id": "2710077", 
                    "category_id": null 
                }
            """;

        // Act and Assert
        mockMvc.perform(post("/api/ingredient-catalogue/add-external")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.ing_id").value(306))
                .andExpect(jsonPath("$.name").value("Kimchi"))
                .andExpect(jsonPath("$.category").value("Vegetables and Vegetable Products"));
    }

    @Test
    void addExternalIngredient_categoryRequired_returns422WithPendingResponse() throws Exception {
        // Arrange
        when(ingredientCatalogueService.saveExternalIngredientToCatalogue(eq("2710077"), isNull())).thenThrow(new CategoryRequiredException("2710077", "Kimchi"));

        String requestBody = """
                { 
                    "source_id": "2710077", 
                    "category_id": null 
                }
            """;

        // Act and Assert
        mockMvc.perform(post("/api/ingredient-catalogue/add-external")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.source_id").value("2710077"))
                .andExpect(jsonPath("$.name").value("Kimchi"));
    }

    @Test
    void addExternalIngredient_retryWithCategoryId_returns200() throws Exception {
        // Arrange
        IngredientCatalogueResponse saved = new IngredientCatalogueResponse(
            306, 
            "Kimchi", 
            "Vegetables and Vegetable Products"
        );

        when(ingredientCatalogueService.saveExternalIngredientToCatalogue(eq("2710077"), eq(19))).thenReturn(saved);

        String requestBody = """
                { 
                    "source_id": "2710077", 
                    "category_id": 19 
                }
            """;


        // Act and Assert
        mockMvc.perform(post("/api/ingredient-catalogue/add-external")
                .with(authentication(new UsernamePasswordAuthenticationToken("1", null, List.of())))
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.category").value("Vegetables and Vegetable Products"));
    }
}