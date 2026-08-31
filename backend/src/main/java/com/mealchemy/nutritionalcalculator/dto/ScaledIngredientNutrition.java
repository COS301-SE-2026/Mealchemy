package com.mealchemy.nutritionalcalculator.dto;

import java.math.BigDecimal;

public record ScaledIngredientNutrition( //records are immutable and auto generate constructors
    Integer ingId,
    String name,
    BigDecimal quantity,
    String unit,
    BigDecimal caloriesKcal,
    BigDecimal proteinG,
    BigDecimal carbsG,
    BigDecimal fatG,
    BigDecimal fibreG,
    BigDecimal sodiumMg
) {}