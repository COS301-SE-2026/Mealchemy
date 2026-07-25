package com.mealchemy.recipe.service;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.OffsetDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/* Import classes */

import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepResponse;
import com.mealchemy.recipe.repository.RecipeStepRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

@ExtendWith(MockitoExtension.class)
public class RecipeStepServiceTest {
    @Mock
    private RecipeStepRepository recipeStepRepository;

    @Mock
    private RecipeRepository recipeRepository;

    @InjectMocks
    private RecipeStepService recipeStepService;

    private RecipeStep recipeStep;
    private Recipe recipe;
    private Recipe otherRecipe;
    private RecipeStepRequest request;

    @BeforeEach
    void setUp()
    {
        recipe = new Recipe();
        recipe.setOwnerId(1);
        ReflectionTestUtils.setField(recipe, "recipeId", 1);

        otherRecipe = new Recipe();
        ReflectionTestUtils.setField(otherRecipe, "recipeId", 2);

        recipeStep = new RecipeStep();
        recipeStep.setRecipe(recipe);
        recipeStep.setStepNr(1);
        recipeStep.setContent("Break the eggs.");
        ReflectionTestUtils.setField(recipeStep, "stepId", 1);

        request = new RecipeStepRequest(2, "Add milk.");
    }

    @Test
    void createRecipeStep_returnsCreatedRecipe_whenFoundAndOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.save(any(RecipeStep.class))).thenReturn(recipeStep);

        RecipeStepResponse result = recipeStepService.createRecipeStep(request, 1, 1);

        assertNotNull(result);
        assertEquals(2, result.stepNr());
        verify(recipeStepRepository, times(1)).save(any(RecipeStep.class));
    }

    @Test
    void createRecipeStep_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.createRecipeStep(request, 99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void createRecipeStep_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.createRecipeStep(request, 1, 99));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can modify its steps.", ex.getReason());
    }

    @Test
    void updateRecipeStep_returnsUpdatedStep_whenFoundOwnerAndBelongsToRecipe()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findById(1)).thenReturn(Optional.of(recipeStep));
        when(recipeStepRepository.save(any(RecipeStep.class))).thenReturn(recipeStep);

        RecipeStepResponse result = recipeStepService.createRecipeStep(1, request, 1, 1);

        assertNotNull(result);
        assertEquals(2, result.stepNr());
        verify(recipeStepRepository, times(1)).save(any(RecipeStep.class));
    }

    @Test
    void updateRecipeStep_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.updateRecipeStep(1, request, 99, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void updateRecipeStep_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.updateRecipeStep(1, request, 1, 99));
        
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can modify its steps.", ex.getReason());
    }

    @Test
    void updateRecipeStep_throwsException_whenStepNotFound()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.updateRecipeStep(99, request, 1, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Step not found.", ex.getReason());
    }
}
