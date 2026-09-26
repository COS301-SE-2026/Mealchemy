package com.mealchemy.mealplan.dto;

/* Import libraries */
import java.math.BigDecimal;

/* Import classes */

public record ShoppingListItem(
    Long ingId,
    String name,
    BigDecimal neededQuantity,
    String unit,
    BigDecimal ownedQuantity,
    BigDecimal shortfallQuantity
){}