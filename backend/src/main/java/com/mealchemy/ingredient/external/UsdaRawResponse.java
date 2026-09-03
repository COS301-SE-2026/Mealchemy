package com.mealchemy.ingredient.external;

import java.util.List;

record UsdaSearchResponse(
    List<UsdaSearchFood> foods
) {}

record UsdaSearchFood(
    Long fdcId,
    String description,
    String dataType,
    List<UsdaShortNutrient> foodNutrients
) {}

record UsdaShortNutrient(
    Integer number,
    String name,
    Double amount,
    String unitName
) {}

record UsdaFoodDetail(
    Long fdcId,
    String description,
    String dataType,
    UsdaFoodCategory foodCategory,
    List<UsdaFoodNutrient> foodNutrients
) {}

record UsdaFoodCategory(
    Integer id,
    String code,
    String description
) {}

record UsdaFoodNutrient(
    Double amount, 
    UsdaNutrient nutrient
) {}

record UsdaNutrient(
    String number, 
    String name, 
    String unitName
) {}