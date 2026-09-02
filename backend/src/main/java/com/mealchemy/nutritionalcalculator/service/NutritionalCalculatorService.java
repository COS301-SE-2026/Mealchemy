package com.mealchemy.nutritionalcalculator.service;

import com.mealchemy.nutritionalcalculator.dto.RecipeIngredientNutrition;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionResponse;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionValues;
import com.mealchemy.nutritionalcalculator.dto.ScaledIngredientNutrition;
import com.mealchemy.nutritionalcalculator.repository.NutritionalCalculatorRepository;
import com.mealchemy.nutritionalcalculator.util.NutritionScaler;
import com.mealchemy.nutritionalcalculator.util.RecipeNutritionCalcs;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;

import java.util.List;
import java.util.ArrayList;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class NutritionalCalculatorService {

    private final NutritionalCalculatorRepository nutritionalCalculatorRepository;
    private final RecipeRepository recipeRepository; // need for serving size

    public NutritionalCalculatorService(NutritionalCalculatorRepository nutritionalCalculatorRepository, RecipeRepository recipeRepository) {
        this.nutritionalCalculatorRepository = nutritionalCalculatorRepository;
        this.recipeRepository = recipeRepository;
    }

    // GET request - returns the recipe's nutritional info total, per serving and per ingredient
    public RecipeNutritionResponse getRecipeNutrition(Integer userId, Integer recipeId) {
        //check recipe exists and User has access
        Recipe recipe = recipeRepository.findAccessibleByIdAndUserId(recipeId, userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found or not accessible"));

        List<RecipeIngredientNutrition> ingredientList = nutritionalCalculatorRepository.getRecipeIngredientsNutrition(recipeId);

        if (ingredientList.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe has no ingredients");
        }

        // get list of individual scaled ingredients
        List<ScaledIngredientNutrition> scaledIngredientNutrition = new ArrayList<>();
        for(RecipeIngredientNutrition ingredient : ingredientList) {
            scaledIngredientNutrition.add(NutritionScaler.scale(ingredient));
        }

        // summation to find totals
        RecipeNutritionValues totalRecipeNutrition = RecipeNutritionCalcs.sumNutritionValues(scaledIngredientNutrition);

        // per serving nutritional data
        Integer servingSize = recipe.getServingSize();
        RecipeNutritionValues perServingRecipeNutrition = RecipeNutritionCalcs.perServing(totalRecipeNutrition, servingSize);

        return new RecipeNutritionResponse(
            recipeId,
            servingSize,
            totalRecipeNutrition,
            perServingRecipeNutrition,
            scaledIngredientNutrition
        );
    }
}