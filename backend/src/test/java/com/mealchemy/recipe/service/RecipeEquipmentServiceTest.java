package com.mealchemy.recipe.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeEquipment;
import com.mealchemy.equipment.model.Equipment;
import com.mealchemy.recipe.dto.RecipeEquipmentResponse;
import com.mealchemy.recipe.repository.RecipeEquipmentRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

@ExtendWith(MockitoExtension.class)
public class RecipeEquipmentServiceTest 
{
    @Mock private RecipeEquipmentRepository recipeEquipmentRepository;
    @Mock private RecipeRepository recipeRepository;

    @InjectMocks
    private RecipeEquipmentService recipeEquipmentService;

    private Recipe recipe;
    private Equipment equipment;
    private RecipeEquipment recipeEquipment;

    @BeforeEach
    void setUp()
    {
        recipe = new Recipe();
        recipe.setOwnerId(1);
        ReflectionTestUtils.setField(recipe, "recipeId", 1);

        equipment = new Equipment();
        ReflectionTestUtils.setField(equipment, "equipmentId", 3);
        equipment.setEquipmentValue("OVEN");
        equipment.setEquipmentLabel("Oven");

        recipeEquipment = new RecipeEquipment();
        ReflectionTestUtils.setField(recipeEquipment, "recipeEquipmentId", 41);
        recipeEquipment.setRecipe(recipe);
        recipeEquipment.setEquipment(equipment);
    }

    @Test
    void getAllEquipmentByRecipeId_whenEquipmentFound_returnList() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(recipe));
        when(recipeEquipmentRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(recipeEquipment));

        // Act 
        List<RecipeEquipmentResponse> result = recipeEquipmentService.getAllEquipmentByRecipeId(1, 1);

        // Assert
        assertEquals(1, result.size());
        assertEquals(3, result.get(0).equipmentId());
        assertEquals("OVEN", result.get(0).value());
        assertEquals("Oven", result.get(0).label());

    }

    @Test
    void getAllEquipmentByRecipeId_noEquipment_returnEmptyList() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(recipe));
        when(recipeEquipmentRepository.findByRecipe_RecipeId(1)).thenReturn(List.of());

        // Act 
        List<RecipeEquipmentResponse> result = recipeEquipmentService.getAllEquipmentByRecipeId(1, 1);

        // Assert
        assertTrue(result.isEmpty());
    }

    @Test
    void getAllEquipmentByRecipeId_RecipeNotAccessible_throwsException() 
    {
        // Arrange
        when(recipeRepository.findAccessibleByIdAndUserId(1, 99)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeEquipmentService.getAllEquipmentByRecipeId(1, 99));

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }
}