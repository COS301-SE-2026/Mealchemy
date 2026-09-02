package com.mealchemy.engine.dto;

/* Import libraries */

import java.math.BigDecimal;
import java.util.List;
import com.mealchemy.recipe.dto.RecipeResponse;

/* Import classes */

public record EnrichedRecommendationItem(
    Integer recipeId,
    String cuisineType,
    BigDecimal score,
    SignalScoresResponse scoreBreakdown,
    Integer pantryGapCount,
    List<String> missingIngredients,
    RecipeResponse recipe
){}