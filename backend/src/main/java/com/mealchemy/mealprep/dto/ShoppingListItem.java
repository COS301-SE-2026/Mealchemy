package com.mealchemy.mealprep.dto;

/* Import libraries */
import java.math.BigDecimal;

/* Import classes */

public record ShoppingListItem(
    Integer ingId,
    String name,
    BigDecimal neededQuantity,
    String unit,
    BigDecimal ownedQuantity,
    BigDecimal shortfallQuantity
){}