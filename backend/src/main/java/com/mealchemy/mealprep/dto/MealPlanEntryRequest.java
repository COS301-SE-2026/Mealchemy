package com.mealchemy.mealprep.dto;

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.*;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;

public record MealPlanEntryRequest(
    @NotNull Long recipeId,
    @NotNull LocalDate entryDate,
    @NotNull MealSlot mealSlot,
    @NotNull LocalTime mealTime,
    @Size(max = 200) String title,
    @Size(max = 500) String note
){}