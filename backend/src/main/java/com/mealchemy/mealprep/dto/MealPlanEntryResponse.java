package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.time.*;

/* Import classes */
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.MealSlot;

public record MealPlanEntryResponse(
    Long entryId,
    Long planId,
    Long recipeId,
    LocalDate entryDate,
    MealSlot mealSlot,
    LocalTime mealTime,
    String title,
    String note,
    MealPlanEntrySource source,
    Long addedBy
){}