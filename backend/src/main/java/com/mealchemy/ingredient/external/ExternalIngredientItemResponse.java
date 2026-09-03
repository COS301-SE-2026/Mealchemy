package com.mealchemy.ingredient.external;

import java.math.BigDecimal;

public record ExternalIngredientItemResponse ( //records are immutable and auto generate constructors
   String name,
   String categoryName,
   Integer caloriesKCal,
   BigDecimal proteinG, 
   BigDecimal carbsG,
   BigDecimal fatG,
   BigDecimal fibreG,
   BigDecimal sodiumMg,
   String sourceApi,
   String sourceId
) {}

// name and category from ingredient catalogue - built in pantry/service by combining the data from the 2 sources