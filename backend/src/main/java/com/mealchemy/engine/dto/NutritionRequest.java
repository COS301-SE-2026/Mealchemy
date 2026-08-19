package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import java.math.BigDecimal;
import com.fasterxml.jackson.annotation.JsonProperty;

public record NutritionRequest(
    @JsonProperty("calories_kcal") Integer caloriesKcal,
    @JsonProperty("protein_g") BigDecimal proteinG,
    @JsonProperty("carbs_g") BigDecimal carbsG,
    @JsonProperty("fat_g") BigDecimal fatG
)
{}
