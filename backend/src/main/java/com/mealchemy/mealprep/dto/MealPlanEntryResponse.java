package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.time.*;

/* Import classes */
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.recipe.dto.RecipeResponse;

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
    Integer addedBy,
    RecipeResponse recipe
)
{
    public static MealPlanEntryResponse from(MealPlanEntry entry, RecipeResponse recipe)
    {
        return new MealPlanEntryResponse(
            entry.getEntryId(),
            entry.getPlan().getPlanId(),
            entry.getRecipeId(),
            entry.getEntryDate(),
            entry.getMealSlot(),
            entry.getMealTime(),
            entry.getTitle(),
            entry.getNote(),
            entry.getSource(),
            entry.getAddedBy(),
            recipe
        );
    }
}