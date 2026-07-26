package com.mealchemy.recipe.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.security.test.context.support.WithMockUser;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

import java.math.BigDecimal;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/* Import classes */
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.service.RecipeIngredientService;

@ExtendWith(SpringExtension.class)
@WebMvcTest(RecipeIngredientController.class)
@WithMockUser(username = "1")
public class RecipeIngredientControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private RecipeIngredientService recipeIngredientService;

    @Autowired
    private ObjectMapper objectMapper;

    private RecipeIngredientResponse response;
    private RecipeIngredientRequest request;

    @BeforeEach
    void setUp()
    {
        response = new RecipeIngredientResponse(1, 1, 1, BigDecimal.valueOf(2.75), "grams", 1);

        request = new RecipeIngredientRequest(1, BigDecimal.valueOf(2.75), "grams", 1);
    }

    @Test
    void getIngredientsByRecipeId_returns200_withList() throws Exception
    {
        when(recipeIngredientService.getIngredientsByRecipeId(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/ingredients/recipe/1")).andExpect(status().isOk()).andExpect(jsonPath("$[0].unit").value("grams"));
    }

    @Test
    void getIngredientsByRecipeId_returns200_withEmptyList() throws Exception
    {
        when(recipeIngredientService.getIngredientsByRecipeId(99)).thenReturn(List.of());

        mockMvc.perform(get("/ingredients/recipe/99")).andExpect(status().isOk()).andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void createRecipeIngredient_returns200_withCreatedIngredient() throws Exception
    {
        when(recipeIngredientService.createRecipeIngredient(any(RecipeIngredientRequest.class), eq(1), eq(1))).thenReturn(response);

        mockMvc.perform(post("/ingredients/recipe/1/ingredient/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.unit").value("grams"));
    }

    @Test
    void createRecipeIngredient_returns400_whenUnitBlank() throws Exception
    {
        RecipeIngredientRequest invalidRequest = new RecipeIngredientRequest(1, BigDecimal.valueOf(2.75), "", 1);

        mockMvc.perform(post("/ingredients/recipe/1/ingredient/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void createRecipeIngredient_returns400_whenIngredientNotInCatalogue() throws Exception
    {
        when(recipeIngredientService.createRecipeIngredient(any(RecipeIngredientRequest.class), eq(1), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "The ingredient you want to add does not exist."));

        mockMvc.perform(post("/ingredients/recipe/1/ingredient/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("The ingredient you want to add does not exist."));
    }

    @Test
    void updateRecipeIngredient_returns200_withUpdatedIngredient() throws Exception
    {
        when(recipeIngredientService.updateRecipeIngredient(eq(1), any(RecipeIngredientRequest.class), eq(1), eq(1))).thenReturn(response);

        mockMvc.perform(put("/ingredients/recipe/1/ingredient/1/edit")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.unit").value("grams"));
    }

    @Test
    void updateRecipeIngredient_returns404_whenIngredientNotFound() throws Exception
    {
        when(recipeIngredientService.updateRecipeIngredient(eq(99), any(RecipeIngredientRequest.class), eq(1), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found."));

        mockMvc.perform(put("/ingredients/recipe/1/ingredient/99/edit")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Ingredient not found."));
    }

    @Test
    void deleteRecipeIngredient_returns200() throws Exception
    {
        doNothing().when(recipeIngredientService).deleteRecipeIngredient(1, 1, 1);

        mockMvc.perform(delete("/ingredients/recipe/1/ingredient/1/delete").with(csrf()))
            .andExpect(status().isOk());
    }

    @Test
    void deleteRecipeIngredient_returns403_whenNotOwner() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients."))
            .when(recipeIngredientService).deleteRecipeIngredient(1, 1, 1);

        mockMvc.perform(delete("/ingredients/recipe/1/ingredient/1/delete").with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its ingredients."));
    }
}