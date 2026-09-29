package com.mealchemy.recipe.controller;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.List;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.mealchemy.config.JwtUtil;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import com.mealchemy.recipe.dto.RecipeEquipmentResponse;
import com.mealchemy.recipe.service.RecipeEquipmentService;
import com.mealchemy.config.WithMockJwtUser;


@ExtendWith(SpringExtension.class)
@WebMvcTest(RecipeEquipmentController.class)
@WithMockJwtUser(userId = "1")
public class RecipeEquipmentControllerTest 
{
    @Autowired
    private MockMvc mockMvc;

    @MockitoBean 
    private JwtUtil jwtUtil;

    @MockitoBean
    private RecipeEquipmentService recipeEquipmentService;

    private RecipeEquipmentResponse response;

    @BeforeEach
    void setUp()
    {
        response = new RecipeEquipmentResponse(
            41, 
            1, 
            3, 
            "OVEN", 
            "Oven"
        );
    }

    // Get testing
    @Test
    void getAllEquipmentByRecipeId_withList_returns200() throws Exception
    {
        // Arrange
        when(recipeEquipmentService.getAllEquipmentByRecipeId(1, 1)).thenReturn(List.of(response));

        // Act and Assert 
        mockMvc.perform(get("/recipeequipment/recipe/1"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[0].equipmentId").value(3))
            .andExpect(jsonPath("$[0].value").value("OVEN"))
            .andExpect(jsonPath("$[0].label").value("Oven"));
    }


    @Test
    void getAllEquipmentByRecipeId_withEmptyList_returns200() throws Exception
    {
        // Arrange
        when(recipeEquipmentService.getAllEquipmentByRecipeId(99, 1)).thenReturn(List.of());

        // Act and Assert 
        mockMvc.perform(get("/recipeequipment/recipe/99"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$").isEmpty());
    }

    @Test
    void getAllEquipmentByRecipeId_RecipeNotAccessible_returns404() throws Exception
    {
        // Arrange
        when(recipeEquipmentService.getAllEquipmentByRecipeId(1, 1)).thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        // Act and Assert 
        mockMvc.perform(get("/recipeequipment/recipe/1"))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.message").value("Recipe not found."));
    }
}