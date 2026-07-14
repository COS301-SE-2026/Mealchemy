package com.mealchemy.recipe.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.*;

/* Import classes */
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.repository.RecipeRepository;

@Service
public class RecipeService
{
    private final RecipeRepository recipeRepository;

    public RecipeService(RecipeRepository recipeRepository)
    {
        this.recipeRepository = recipeRepository;
    }

    // Get all recipes
    public List<RecipeResponse> getAllRecipes()
    {
        return recipeRepository.findAll().stream().map(RecipeResponse::from).collect(Collectors.List());
    }

    // Get a single recipe by Id
    public RecipeResponse getRecipeById(Integer id)
    {
        Recipe recipeForReturn = recipeRepository.findById(id).orElseThrow(() -> new RuntimeException("Recipe not found."));
        return RecipeResponse.from(recipeForReturn);
    }
}