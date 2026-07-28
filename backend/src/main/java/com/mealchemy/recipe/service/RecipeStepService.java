package com.mealchemy.recipe.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;

/* Import classes */

import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeStepResponse;
import com.mealchemy.recipe.dto.RecipeStepReorderRequest;
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

    // Retrieve all steps relating to a specific recipe
    public List<RecipeStepResponse> getAllStepsByRecipeId(Integer recipeId)
    {
        return recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(recipeId).stream().map(RecipeStepResponse::from).collect(Collectors.toList());
    }

    // Create a new step for a specific recipe
    public RecipeStepResponse createRecipeStep(RecipeStepRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if(!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps.");
        }

        RecipeStep recipeStepForReturn = mapRequestToEntity(request, recipeToCheck);

        return RecipeStepResponse.from(recipeStepRepository.save(recipeStepForReturn));
    }

    // Update a specific step in an existing recipe
    public RecipeStepResponse updateRecipeStep(int id, RecipeStepRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if(!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps.");
        }

        RecipeStep recipeStepForReturn = recipeStepRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Step not found."));

        if(!recipeStepForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Step must be part of the recipe.");
        }

        recipeStepForReturn.setStepNr(request.stepNr());
        recipeStepForReturn.setContent(request.content());

        return RecipeStepResponse.from(recipeStepRepository.save(recipeStepForReturn));
    }

    // Delete a specific step in an existing recipe
    public void deleteRecipeStep(int id, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its steps.");
        }

        RecipeStep recipeStepForReturn = recipeStepRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Step not found."));

        if (!recipeStepForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Step must be part of the recipe.");
        }

        recipeStepRepository.deleteById(id);
    }

    // Reorder recipe steps
    @Transactional
    public List<RecipeStepResponse> reorderSteps(Integer recipeId, RecipeStepReorderRequest request, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
        
        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the recipe can manipulate the order of the steps.");
        }

        List<RecipeStep> existingSteps = recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(recipeId);

        Map<Integer, RecipeStep> stepsById = existingSteps.stream().collect(Collectors.toMap(RecipeStep::getStepId, step -> step));

        List<Integer> orderedStepIds = request.orderedStepIds();

        if (orderedStepIds.size() != existingSteps.size() || !stepsById.keySet().containsAll(orderedStepIds))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Provided step IDs must match the recipe's existing step.");
        }

        for (int i = 0; i < orderedStepIds.size(); i++)
        {
            RecipeStep step = stepsById.get(orderedStepIds.get(i));
            step.setStepNr(-(i + 1));
        }

        recipeStepRepository.saveAllAndFlush(stepsById.values());
        for(int i = 0; i < orderedStepIds.size(); i++)
        {
            RecipeStep step = stepsById.get(orderedStepIds.get(i));
            step.setStepNr(i + 1);
        }
        recipeStepRepository.saveAllAndFlush(stepsById.values());

        return recipeStepRepository.findByRecipe_RecipeIdOrderByStepNrAsc(recipeId).stream().map(RecipeStepResponse::from).collect(Collectors.toList());
    }

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
