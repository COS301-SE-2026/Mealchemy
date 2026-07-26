package com.mealchemy.recipe.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;

@Service
public class RecipeIngredientService 
{
    private final RecipeIngredientRepository recipeIngredientRepository;

    private final RecipeRepository recipeRepository;

    private final IngredientCatalogueRepository ingredientCatalogueRepository;

    public RecipeIngredientService(RecipeIngredientRepository recipeIngredientRepository, RecipeRepository recipeRepository, IngredientCatalogueRepository ingredientCatalogueRepository)
    {
        this.recipeIngredientRepository = recipeIngredientRepository;
        this.recipeRepository = recipeRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
    }

    // Retrieve all ingredients relating to a specific recipe
    public List<RecipeIngredientResponse> getAllIngredientsByRecipeId(Integer recipeId)
    {
        return recipeIngredientRepository.findByRecipe_RecipeId(recipeId).stream().map(RecipeIngredientResponse::from).collect(Collectors.toList());
    }

    // Create a new ingredient for a specific recipe
    public RecipeIngredientResponse createRecipeIngredient(RecipeIngredientRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients.");
        }

        if (!ingredientCatalogueRepository.existsById(request.ingId()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "The ingredient you want to add does not exist.");
        }

        RecipeIngredient recipeIngredientForReturn = mapRequestToEntity(request, recipeToCheck);
        
        return RecipeIngredientResponse.from(recipeIngredientRepository.save(recipeIngredientForReturn));
    }

    // Update a specific ingredient in an existing recipe
    public RecipeIngredientResponse updateRecipeIngredient(int id, RecipeIngredientRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients.");
        }

        RecipeIngredient recipeIngredientForReturn = recipeIngredientRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found."));
        
        if (!recipeIngredientForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Ingredient must be part of the recipe.");
        }

        if (!ingredientCatalogueRepository.existsById(request.ingId()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "The ingredient you want to change to does not exist.");
        }

        recipeIngredientForReturn.setIngId(request.ingId());
        recipeIngredientForReturn.setQuantity(request.quantity());
        recipeIngredientForReturn.setUnit(request.unit());
        recipeIngredientForReturn.setSortOrder(request.sortOrder());

        return RecipeIngredientResponse.from(recipeIngredientRepository.save(recipeIngredientForReturn));
    }

    // Delete a specific ingredient in an existing recipe
    public void deleteRecipeIngredient(int id, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients.");
        }

        RecipeIngredient recipeIngredientForReturn = recipeIngredientRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found."));
        
        if (!recipeIngredientForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Ingredient must be part of the recipe.");
        }

        recipeIngredientRepository.deleteById(id);
    }

    /* Mapping functions */

    public RecipeIngredient mapRequestToEntity(RecipeIngredientRequest request, Recipe recipe)
    {
        RecipeIngredient recipeIngredient = new RecipeIngredient();

        recipeIngredient.setRecipe(recipe);
        recipeIngredient.setIngId(request.ingId());
        recipeIngredient.setQuantity(request.quantity());
        recipeIngredient.setUnit(request.unit());
        recipeIngredient.setSortOrder(request.sortOrder());

        return recipeIngredient;
    }
}
