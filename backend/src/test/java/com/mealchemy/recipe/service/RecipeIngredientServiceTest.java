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

import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;

@ExtendWith(MockitoExtension.class)
public class RecipeIngredientServiceTest {
    @Mock
    private RecipeIngredientRepository recipeIngredientRepository;

    @Mock
    private RecipeRepository recipeRepository;

    @Mock
    private IngredientCatalogueRepository ingredientCatalogueRepository;

    @InjectMocks
    private RecipeIngredientService recipeIngredientService;

    private RecipeIngredient recipeIngredient;
    private Recipe recipe;
    private Recipe otherRecipe;
    private RecipeIngredientRequest request;

    @BeforeEach
    void setUp()
    {
        recipe = new Recipe();
        recipe.setOwnerId(1);
        ReflectionTestUtils.setField(recipe, "recipeId", 1);

        otherRecipe = new Recipe();
        ReflectionTestUtils.setField(otherRecipe, "recipeId", 2);

        recipeIngredient = new RecipeIngredient();
        recipeIngredient.setRecipe(recipe);
        ReflectionTestUtils.setField(recipeIngredient, "ingredientId", 1);
        recipeIngredient.setIngId(1);
        recipeIngredient.setQuantity(2.75);
        recipeIngredient.setUnit("grams");
        recipeIngredient.setSortOrder(1);
        
        request = new RecipeIngredientRequest(2, 30, "ml", 1);
    }

    @Test
    void createRecipeIngredient_returnsNewIngredient_whenFoundOwnerAndInCatalogue()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(ingredientCatalogueRepository.existsById(request.ingId())).thenReturn(true);
        when(recipeIngredientRepository.save(any(RecipeIngredient.class))).thenReturn(recipeIngredient);

        RecipeIngredientResponse result = recipeIngredientService.createRecipeIngredient(request, 1, 1);

        assertNotNull(result);
        assertEquals(1, result.ingredientId());
        verify(recipeIngredientRepository, times(1)).save(any(RecipeIngredient.class));
    }

    @Test
    void createRecipeIngredient_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.createRecipeIngredient(request, 99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void createRecipeIngredient_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.createRecipeIngredient(request, 1, 99));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can modify its ingredients.", ex.getReason());
    }

    @Test
    void createRecipeIngredient_throwsException_whenNotInCatalogue()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(ingredientCatalogueRepository.existsById(request.ingId())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.createRecipeIngredient(request, 1, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("The ingredient you want to add does not exist.", ex.getReason());
    }

    @Test
    void updateRecipeIngredient_returnsUpdatedIngredient_whenFoundOwnerBelongsToRecipeAndInCatalogue()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeIngredientRepository.findById(1)).thenReturn(Optional.of(recipeIngredient));
        when(ingredientCatalogueRepository.existsById(request.ingId())).thenReturn(true);
        when(recipeIngredientRepository.save(any(RecipeIngredient.class))).thenReturn(recipeIngredient);

        RecipeIngredientResponse result = recipeIngredientService.updateRecipeIngredient(1, request, 1, 1);

        assertNotNull(result);
        assertEquals(2, result.ingredientId());
        verify(recipeIngredientRepository, times(1)).save(any(RecipeIngredient.class));
    }

    @Test
    void updateRecipeIngredient_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.updateRecipeIngredient(1, request, 99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void updateRecipeIngredient_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.updateRecipeIngredient(1, request, 1, 99));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can modify its ingredients.", ex.getReason());
    }

    @Test
    void updateRecipeIngredient_throwsException_whenIngredientRowNotFound()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeIngredientRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.updateRecipeIngredient(99, request, 1, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Ingredient not found.", ex.getReason());
    }

    @Test
    void updateRecipeIngredient_throwsException_whenIngredientNotFromRecipe()
    {
        recipeIngredient.setRecipe(otherRecipe);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeIngredientRepository.findById(1)).thenReturn(Optional.of(recipeIngredient));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.updateRecipeIngredient(1, request, 1, 1));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Ingredient must be part of the recipe.", ex.getReason());
    }

    @Test
    void updateRecipeIngredient_throwsException_whenNotInCatalogue()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeIngredientRepository.findById(1)).thenReturn(Optional.of(recipeIngredient));
        when(ingredientCatalogueRepository.existsById(request.ingId())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.updateRecipeIngredient(1, request, 1, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("The ingredient you want to change to does not exist.", ex.getReason());
    }

    @Test
    void deleteRecipeIngredient_callsDeleteById_whenFoundOwnerAndBelongsToRecipe()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(recipeIngredientRepository.findById(1)).thenReturn(Optional.of(recipeIngredient));
        doNothing().when(recipeIngredientRepository).deleteById(1);

        recipeIngredientService.deleteRecipeIngredient(1, 1, 1);

        verify(recipeIngredientRepository, times(1)).deleteById(1);
    }

    @Test
    void deleteRecipeIngredient_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.deleteRecipeIngredient(1, 99, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void deleteRecipeIngredient_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeIngredientService.deleteRecipeIngredient(1, 1, 99));
        
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can modify its ingredients.", ex.getReason());
    }
}
