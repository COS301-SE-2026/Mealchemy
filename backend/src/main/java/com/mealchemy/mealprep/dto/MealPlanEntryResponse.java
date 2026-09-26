package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.time.*;

/* Import classes */
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.MealSlot;

public record MealPlanEntryResponse(
    Integer entryId,
    Integer planId,
    Integer recipeId,
    LocalDate entryDate,
    MealSlot mealSlot,
    LocalTime mealTime,
    String title,
    String note,
    MealPlanEntrySource source,
    Integer addedBy
){}