package com.mealchemy.recipe.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;

/* Import classes */
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.RecipeStep;
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
        return recipeRepository.findAll().stream().map(RecipeResponse::from).collect(Collectors.toList());
    }

    // Get a single recipe by Id
    public RecipeResponse getRecipeById(Integer id)
    {
        Recipe recipeForReturn = recipeRepository.findById(id).orElseThrow(() -> new RuntimeException("Recipe not found."));
        return RecipeResponse.from(recipeForReturn);
    }

    // Post to create a new recipe
    public RecipeResponse createRecipe(RecipeRequest request, Integer ownerId)
    {
        Recipe recipeForReturn = mapRequestToEntity(request, ownerId);

        List<RecipeIngredient> ingredients = request.ingredients().stream().map(i -> {
            RecipeIngredient recipeIngredient = new RecipeIngredient();
            recipeIngredient.setIngId(i.ingId());
            recipeIngredient.setQuantity(i.quantity());
            recipeIngredient.setUnit(i.unit());
            recipeIngredient.setSortOrder(i.sortOrder());
            recipeIngredient.setRecipe(recipeForReturn);
            return recipeIngredient;
        }).toList();

        List<RecipeStep> steps = request.steps().stream().map(i -> {
            RecipeStep recipeStep = new RecipeStep();
            recipeStep.setStepNr(i.stepNr());
            recipeStep.setContent(i.content());
            recipeStep.setRecipe(recipeForReturn);
            return recipeStep;
        }).toList();

        recipeForReturn.setIngredients(ingredients);
        recipeForReturn.setSteps(steps);

        return RecipeResponse.from(recipeRepository.save(recipeForReturn));
    }

    /* Mapping functions */

    private Recipe mapRequestToEntity(RecipeRequest request, Integer ownerId)
    {
        Recipe recipe = new Recipe();

        recipe.setOwnerId(ownerId);
        recipe.setTitle(request.title());
        recipe.setDescription(request.description());
        recipe.setCuisineType(request.cuisineType());
        recipe.setPrepTimeMins(request.prepTimeMins());
        recipe.setCookingTimeMins(request.cookingTimeMins());
        recipe.setServingSize(request.servingSize());
        recipe.setPhotoUrl(request.photoUrl());
        recipe.setVideoUrl(request.videoUrl());
        recipe.setExternalUrl(request.externalUrl());
        recipe.setIsCommunityPublished(request.isCommunityPublished());

        return recipe;
    }
}