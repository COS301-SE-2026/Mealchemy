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
import com.mealchemy.recipe.dto.RecipeStepReorderRequest;
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
    private RecipeStep recipeStep2;
    private RecipeStep recipeStep3;
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
        
        recipeStep2 = new RecipeStep();
        recipeStep2.setRecipe(recipe);
        recipeStep2.setStepNr(2);
        recipeStep2.setContent("Add milk.");
        ReflectionTestUtils.setField(recipeStep2, "stepId", 2);

        recipeStep3 = new RecipeStep();
        recipeStep3.setRecipe(recipe);
        recipeStep3.setStepNr(3);
        recipeStep3.setContent("Whisk.");
        ReflectionTestUtils.setField(recipeStep3, "stepId", 3);

        request = new RecipeStepRequest(2, "Add milk.");
    }

    @Test
    void getAllStepsByRecipeId_returnsListOfSteps_whenFound()
    {
        when(recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(1)).thenReturn(List.of(recipeStep, recipeStep2, recipeStep3));

        List<RecipeStepResponse> result = recipeStepService.getAllStepsByRecipeId(1);

        assertEquals(3, result.size());
        assertEquals(1, result.get(0).stepNr());
    }

    @Test
    void getAllStepsByRecipeId_returnsEmptyList_whenNoneFound()
    {
        when(recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(99)).thenReturn(List.of());

        List<RecipeStepResponse> result = recipeStepService.getAllStepsByRecipeId(99);

        assertTrue(result.isEmpty());
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

        RecipeStepResponse result = recipeStepService.updateRecipeStep(1, request, 1, 1);

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

    @Test
    void updateRecipeStep_throwsException_whenStepNotFromRecipe()
    {
        recipeStep.setRecipe(otherRecipe);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findById(1)).thenReturn(Optional.of(recipeStep));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.updateRecipeStep(1, request, 1, 1));
        
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Step must be part of the recipe.", ex.getReason());
    }

    @Test
    void deleteRecipeStep_callsDeleteById_whenFoundOwnerAndBelongsToRecipe()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findById(1)).thenReturn(Optional.of(recipeStep));
        doNothing().when(recipeStepRepository).deleteById(1);

        recipeStepService.deleteRecipeStep(1, 1, 1);

        verify(recipeStepRepository, times(1)).deleteById(1);
    }

    @Test
    void deleteRecipeStep_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.deleteRecipeStep(1, 99, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void deleteRecipeStep_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.deleteRecipeStep(1, 1, 99));
        
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can modify its steps.", ex.getReason());
    }

    @Test
    void deleteRecipeStep_throwsException_whenStepNotFound()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.deleteRecipeStep(99, 1, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Step not found.", ex.getReason());
    }

    @Test
    void deleteRecipeStep_throwsException_whenStepNotFromRecipe()
    {
        recipeStep.setRecipe(otherRecipe);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findById(1)).thenReturn(Optional.of(recipeStep));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.deleteRecipeStep(1, 1, 1));
        
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Step must be part of the recipe.", ex.getReason());
    }

    @Test
    void reorderSteps_returnsReorderedSteps_whenFoundAndOwner()
    {
        RecipeStepReorderRequest reorderRequest = new RecipeStepReorderRequest(List.of(3, 1, 2));

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(1)).thenReturn(List.of(recipeStep, recipeStep2, recipeStep3)).thenReturn(List.of(recipeStep3, recipeStep, recipeStep2));
        when(recipeStepRepository.save(any(RecipeStep.class))).thenAnswer(invocation -> invocation.getArgument(0));

        List<RecipeStepResponse> result = recipeStepService.reorderSteps(1, reorderRequest, 1);

        assertEquals(3, result.size());
        verify(recipeStepRepository, times(3)).save(any(RecipeStep.class));
    }

    @Test
    void reorderSteps_throwsException_whenNotOwner()
    {
        RecipeStepReorderRequest reorderRequest = new RecipeStepReorderRequest(List.of(1, 2, 3));

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.reorderSteps(1, reorderRequest, 99));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of the recipe can manipulate the order of the steps.", ex.getReason());
    }

    @Test
    void reorderSteps_throwsException_whenRecipeNotFound()
    {
        RecipeStepReorderRequest reorderRequest = new RecipeStepReorderRequest(List.of(1, 2, 3));

        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.reorderSteps(99, reorderRequest, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void reorderSteps_throwsException_whenSizeMismatch()
    {
        RecipeStepReorderRequest reorderRequest = new RecipeStepReorderRequest(List.of(1, 2));

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(1)).thenReturn(List.of(recipeStep, recipeStep2, recipeStep3));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.reorderSteps(1, reorderRequest, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Provided step IDs must match the recipe's existing step.", ex.getReason());
    }

    @Test
    void reorderSteps_throwsException_whenStepIdNotPartOfRecipe()
    {
        RecipeStepReorderRequest reorderRequest = new RecipeStepReorderRequest(List.of(1, 2, 999));

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(1)).thenReturn(List.of(recipeStep, recipeStep2, recipeStep3));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeStepService.reorderSteps(1, reorderRequest, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Provided step IDs must match the recipe's existing step.", ex.getReason());
    }
}
