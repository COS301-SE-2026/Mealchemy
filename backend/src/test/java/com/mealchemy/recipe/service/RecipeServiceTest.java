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

import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;

@ExtendWith(MockitoExtension.class)
public class RecipeServiceTest {
    @Mock
    private RecipeRepository recipeRepository;

    @Mock
    private IngredientCatalogueRepository ingredientCatalogueRepository;

    @Mock 
    private FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    @InjectMocks
    private RecipeService recipeService;

    private Recipe recipe;
    private Recipe sourceRecipe;
    private RecipeRequest request;
    private RecipeFullRequest fullRequest;

    @BeforeEach
    void setUp()
    {
        recipe = new Recipe();
        recipe.setOwnerId(1);
        recipe.setTitle("Recipe 1");
        recipe.setCuisineType("Japanese");
        ReflectionTestUtils.setField(recipe, "recipeId", 1);

        sourceRecipe = new Recipe();
        sourceRecipe.setOwnerId(1);
        sourceRecipe.setTitle("Recipe 2");
        sourceRecipe.setCuisineType("Italian");
        ReflectionTestUtils.setField(sourceRecipe, "recipeId", 2);

        request = new RecipeRequest("Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false);

        List<RecipeIngredientRequest> ingredients = List.of(
            new RecipeIngredientRequest(1, 2.0, "cup", 1)
        );

        List<RecipeStepRequest> steps = List.of(
            new RecipeStepRequest(1, "Mix everything together.")
        );

        fullRequest = new RecipeFullRequest("FullReq Title", "Full Description", "Chinese", 10, 15, 2, null, null, null, false, ingredients, steps);
    }

    @Test
    void getAllRecipes_returnsListOfRecipes_whenFound()
    {
        when(recipeRepository.findAll()).thenReturn(List.of(recipe));

        List<RecipeResponse> result = recipeRepository.getAllRecipes();

        assertNotNull(result);
        assertEquals("Recipe 1", result.get(0).title());
    }

    @Test
    void getAllRecipes_returnsEmptyList_whenNotFound()
    {
        when(recipeRepository.findAll()).thenReturn(List.of());

        List<RecipeResponse> result = recipeRepository.getAllRecipes();

        assertTrue(result.isEmpty());
    }

    @Test
    void getRecipeById_returnsRecipe_whenFound()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        RecipeResponse result = recipeRepository.getRecipeById(1);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
    }

    @Test
    void getRecipeById_throwsException_whenNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeRepository.getRecipeById(99));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void createRecipe_returnsCreatedRecipe_whenCuisineTypeValid()
    {
        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        RecipeResponse result = recipeRepository.createRecipe(request, 1);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
    }

    @Test
    void createRecipe_throwsException_whenCuisineTypeNotValid()
    {
        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeRepository.createRecipe(request, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Cuisine type is invalid.", ex.getReason());
    }

    @Test
    void createFromFullRecipe_returnsCreatedRecipe_whenSourceIdIsNull()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        RecipeResponse result = recipeRepository.createFromFullRecipe(fullRequest, 1, null);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
    }

    @Test
    void createFromFullRecipe_returnsCreatedRecipe_whenSourceIdIsNotNull()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);
        when(recipeRepository.findById(2)).thenReturn(Optional.of(sourceRecipe));

        RecipeResponse result = recipeRepository.createFromFullRecipe(fullRequest, 1, 2);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
    }

    @Test
    void createFromFullRecipe_throwsException_whenCuisineTypeNotValid()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeRepository.createRecipe(fullRequest, 1, null));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Cuisine type is invalid.", ex.getReason());
    }

    @Test
    void createFromFullRecipe_throwsException_whenSourceRecipeNotFound()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(recipeRepository.findById(2)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeRepository.createRecipe(fullRequest, 1, 2));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Source recipe not found.", ex.getReason());
    }
}
