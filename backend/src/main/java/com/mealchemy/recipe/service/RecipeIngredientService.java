package com.mealchemy.recipe.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;

/* Import classes */
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;

@Service
public class RecipeIngredientService 
{
    private final RecipeIngredientRepository recipeIngredientRepository;

    public RecipeIngredienService(RecipeIngredientRepository recipeIngredientRepository)
    {
        this.recipeIngredientRepository = recipeIngredientRepository;
    }

    // Get all steps that belong to a recipe
    public List<RecipeIngredientResponse> getStepsByRecipeId(int id)
    {
        return recipeIngredientRepository.findById(id).stream().map(RecipeIngredientResponse::from).collect(Collectors.toList());
    }
    
}
