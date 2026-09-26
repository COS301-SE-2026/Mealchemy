package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.time.LocalDate;
import java.util.List;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;

public record GenerateRecommendationsResponse(
    List<MealPlanEntryResponse> generatedEntries,
    List<SkippedDate> skippedDates
){
    public record SkippedDate(LocalDate date, MealSlot mealSlot, Reason reason) {
        public enum Reason {
            MANUAL_ENTRY_PRESENT,
            NO_CANDIDATES_AFTER_PROJECTION
        }
    }
}