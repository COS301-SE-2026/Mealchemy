package com.mealchemy.mealprep.dto;

/* Import libraries */
import jakarta.validation.constraints.*;
import java.time.*;
import java.util.*;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;

public record GenerateRecommendationsRequest(
    @NotNull LocalDate startDate,
    @NotNull LocalDate endDate,
    @NotEmpty List<MealSlot> mealSlots,
    @NotEmpty Map<MealSlot, LocalTime> slotTimes,
    boolean overwriteRecommended,
    Long seed
){}