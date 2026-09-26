package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.time.LocalDate;
import java.util.List;

/* Import classes */

public record ShoppingListResponse(
    LocalDate startDate,
    LocalDate endDate,
    List<ShoppingListItem> items
){}