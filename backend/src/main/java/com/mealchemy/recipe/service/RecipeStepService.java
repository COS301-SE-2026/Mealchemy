package com.mealchemy.recipe.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */

import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepResponse;
import com.mealchemy.recipe.repository.RecipeStepRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

@Service
public class RecipeStepService {

    private final RecipeStepRepository recipeStepRepository;

    private final RecipeRepository recipeRepository;

    public RecipeStepService(RecipeStepRepository recipeStepRepository, RecipeRepository recipeRepository)
    {
        this.recipeStepRepository = recipeStepRepository;
        this.recipeRepository = recipeRepository;
    }

    // Create a new step for a specific recipe
    public RecipeStepResponse createRecipeStep(RecipeStepRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new RuntimeException("Recipe not found."));

        if(!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps.");
        }

        RecipeStep recipeStepForReturn = mapRequestToEntity(request, recipeToCheck);

        return RecipeResponse.from(recipeStepRepository.save(RecipeStepForReturn));
    }

    // Update a specific step in an existing recipe
    public RecipeStepResponse updateRecipeStep(int id, RecipeStepRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new RuntimeException("Recipe not found."));

        if(!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps.");
        }

        RecipeStep recipeStepForReturn = recipeStepRepository.findById(id).orElseThrow(() -> new RuntimeException("Step not found."));

        if(!recipeStepForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Step must be part of the recipe.");
        }

        recipeStepForReturn.setStepNr(request.stepNr());
        recipeStepForReturn.setContent(request.content());

        return RecipeStepResponse.from(recipeStepRepository.save(recipeStepForReturn));
    }

    // Delete a specific step in an existing recipe

    /* Mapping functions */

    public RecipeStep mapRequestToEntity(RecipeStepRequest request, Recipe recipe)
    {
        RecipeStep recipeStep = new RecipeStep();

        recipeStep.setRecipe(recipe);
        recipeStep.setStepNr(request.stepNr());
        recipeStep.setContent(request.content());

        return recipeStep;
    }
}
