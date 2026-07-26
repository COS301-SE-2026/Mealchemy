package com.mealchemy.recipe.controller;

/* Import libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.security.test.context.support.WithMockUser;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;

import java.util.List;
import com.mealchemy.config.JwtUtil;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/* Import classes */
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepReorderRequest;
import com.mealchemy.recipe.dto.RecipeStepResponse;
import com.mealchemy.recipe.service.RecipeStepService;
import com.mealchemy.config.WithMockJwtUser;

@ExtendWith(SpringExtension.class)
@WebMvcTest(RecipeStepController.class)
@WithMockJwtUser(userId = "1")
public class RecipeStepControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private RecipeStepService recipeStepService;

    @Autowired
    private ObjectMapper objectMapper;

    private RecipeStepResponse response;
    private RecipeStepRequest request;
    private RecipeStepReorderRequest reorderRequest;

    @BeforeEach
    void setUp()
    {
        response = new RecipeStepResponse(1, 1, 1, "Break the eggs.");

        request = new RecipeStepRequest(1, "Break the eggs.");

        reorderRequest = new RecipeStepReorderRequest(List.of(3, 1, 2));
    }

    @Test
    void getAllStepsByRecipeId_returns200_withList() throws Exception
    {
        when(recipeStepService.getAllStepsByRecipeId(1)).thenReturn(List.of(response));

        mockMvc.perform(get("/steps/recipe/1")).andExpect(status().isOk()).andExpect(jsonPath("$[0].content").value("Break the eggs."));
    }

    @Test
    void getAllStepsByRecipeId_returns200_withEmptyList() throws Exception
    {
        when(recipeStepService.getAllStepsByRecipeId(99)).thenReturn(List.of());

        mockMvc.perform(get("/steps/recipe/99")).andExpect(status().isOk()).andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void createRecipeStep_returns200_withCreatedStep() throws Exception
    {
        when(recipeStepService.createRecipeStep(any(RecipeStepRequest.class), eq(1), eq(1))).thenReturn(response);

        mockMvc.perform(post("/steps/recipe/1/step/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").value("Break the eggs."));
    }

    @Test
    void createRecipeStep_returns400_whenContentBlank() throws Exception
    {
        RecipeStepRequest invalidRequest = new RecipeStepRequest(1, "");

        mockMvc.perform(post("/steps/recipe/1/step/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(invalidRequest)))
            .andExpect(status().isBadRequest());
    }

    @Test
    void createRecipeStep_returns403_whenNotOwner() throws Exception
    {
        when(recipeStepService.createRecipeStep(any(RecipeStepRequest.class), eq(1), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps."));

        mockMvc.perform(post("/steps/recipe/1/step/create")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its steps."));
    }

    @Test
    void updateRecipeStep_returns200_withUpdatedStep() throws Exception
    {
        when(recipeStepService.updateRecipeStep(eq(1), any(RecipeStepRequest.class), eq(1), eq(1))).thenReturn(response);

        mockMvc.perform(put("/steps/recipe/1/step/1/edit")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content").value("Break the eggs."));
    }

    @Test
    void updateRecipeStep_returns404_whenStepNotFound() throws Exception
    {
        when(recipeStepService.updateRecipeStep(eq(99), any(RecipeStepRequest.class), eq(1), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Step not found."));

        mockMvc.perform(put("/steps/recipe/1/step/99/edit")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Step not found."));
    }

    @Test
    void reorderSteps_returns200_withReorderedSteps() throws Exception
    {
        when(recipeStepService.reorderSteps(eq(1), any(RecipeStepReorderRequest.class), eq(1))).thenReturn(List.of(response));

        mockMvc.perform(put("/steps/recipe/1/reorder")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(reorderRequest)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].content").value("Break the eggs."));
    }

    @Test
    void reorderSteps_returns400_whenStepIdsMismatch() throws Exception
    {
        when(recipeStepService.reorderSteps(eq(1), any(RecipeStepReorderRequest.class), eq(1)))
            .thenThrow(new ResponseStatusException(HttpStatus.BAD_REQUEST, "Provided step IDs must match the recipe's existing step."));

        mockMvc.perform(put("/steps/recipe/1/reorder")
            .with(csrf())
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(reorderRequest)))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.message").value("Provided step IDs must match the recipe's existing step."));
    }

    @Test
    void deleteRecipeStep_returns200() throws Exception
    {
        doNothing().when(recipeStepService).deleteRecipeStep(1, 1, 1);

        mockMvc.perform(delete("/steps/recipe/1/step/1/delete").with(csrf()))
            .andExpect(status().isOk());
    }

    @Test
    void deleteRecipeStep_returns403_whenNotOwner() throws Exception
    {
        doThrow(new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps."))
            .when(recipeStepService).deleteRecipeStep(1, 1, 1);

        mockMvc.perform(delete("/steps/recipe/1/step/1/delete").with(csrf()))
            .andExpect(status().isForbidden())
            .andExpect(jsonPath("$.message").value("Only the owner of this recipe can modify its steps."));
    }
}