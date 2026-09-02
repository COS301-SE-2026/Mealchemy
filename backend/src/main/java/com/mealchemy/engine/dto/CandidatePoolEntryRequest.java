package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record CandidatePoolEntryRequest(
    @NotNull @JsonProperty("recipe_id") Integer recipeId,
    @NotBlank String title,
    @NotBlank String cuisine,
    @NotNull @JsonProperty("dietary_tags") List<String> dietaryTags,
    @NotNull List<IngredientRequest> ingredients,
    NutritionRequest nutrition
)
{}