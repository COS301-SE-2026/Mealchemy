// target interface class
package com.mealchemy.ingredient.external;

import java.util.List;

public interface NutritionDataProvider {
    List<ExternalIngredientItemResponse> findExternalIngredient(String name);

    ExternalIngredientItemResponse getExternalIngredientDetails(String sourceId);
}
