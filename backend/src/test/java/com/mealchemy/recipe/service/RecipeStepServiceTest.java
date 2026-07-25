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
}
