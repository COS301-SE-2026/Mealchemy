package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.time.LocalDate;
import java.util.List;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.engine.dto.EnrichedRecommendationItem;

public record DayRecommendationResponse(
    LocalDate date,
    MealSlot mealSlot,
    List<EnrichedRecommendationItem> recommendations
){}