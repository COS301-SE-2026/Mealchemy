package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record NutritionRequest(
    @JsonProperty("calories_kcal") @NotNull BigDecimal caloriesKcal,
    @JsonProperty("protein_g") @NotNull BigDecimal proteinG,
    @JsonProperty("carbs_g") @NotNull BigDecimal carbsG,
    @JsonProperty("fat_g") @NotNull BigDecimal fatG
)
{}
