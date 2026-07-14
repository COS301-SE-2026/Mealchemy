package com.mealchemy.recipe.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;

/* Import classes */
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;

@Service
public class RecipeIngredientService 
{
    private final RecipeIngredientRepository recipeIngredientRepository;

    public RecipeIngredientService(RecipeIngredientRepository recipeIngredientRepository)
    {
        this.recipeIngredientRepository = recipeIngredientRepository;
    }

    // Create a new step for a specific recipe
    public RecipeIngredientResponse createRecipeIngredient(RecipeIngredientRequest request, Recipe recipe)
    {
        // Add logic to check if recipe owner

        RecipeIngredient recipeIngredientForReturn = mapRequestToEntity(request, recipe);
        
        return RecipeIngredientResponse.from(recipeIngredientRepository.save(recipeIngredientForReturn));
    }

    // Update a specific step in an existing recipe
    public RecipeIngredientResponse updateRecipeIngredient(int id, RecipeIngredientRequest request, Recipe recipe)
    {
        // Add logic to check if recipe owner

        RecipeIngredient recipeIngredientForReturn = recipeIngredientRepository.findById(id).orElseThrow(() -> new RuntimeException("Ingredient not found."));
        
        recipeIngredientForReturn.setIngId(request.ingId());
        recipeIngredientForReturn.setQuantity(request.quantity());
        recipeIngredientForReturn.setUnit(request.unit());
        recipeIngredientForReturn.setSortOrder(request.sortOrder());

        return RecipeIngredientResponse.from(recipeIngredientRepository.save(recipeIngredientForReturn));
    }

    // Delete a specific step in an existing recipe
    public void deleteRecipeIngredient(int id, Recipe recipe)
    {
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
