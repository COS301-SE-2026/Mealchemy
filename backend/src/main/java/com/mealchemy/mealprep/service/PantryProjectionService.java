package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/* Import classes */
import com.mealchemy.engine.dto.PantryEntryRequest;
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.shared.unitconverter.UnitConverter;

@Service
public class PantryProjectionService {
    private final RecommendationService recommendationService;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;

    public PantryProjectionService(RecommendationService recommendationService,
        MealPlanEntryRepository mealPlanEntryRepository, RecipeIngredientRepository recipeIngredientRepository)
    {
        this.recommendationService = recommendationService;
        this.mealPlanEntryRepository = mealPlanEntryRepository;
        this.recipeIngredientRepository = recipeIngredientRepository;
    }
}