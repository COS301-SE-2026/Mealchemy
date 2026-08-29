package com.mealchemy.ingredient.external;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.stereotype.Component;

@Component
public class NutritionDataAdapter implements NutritionDataProvider {
    private static final int NCODE_ENERGY_KCAL = 1008;
    private static final int NCODE_PROTEIN_G = 203;
    private static final int NCODE_FAT_G = 204;
    private static final int NCODE_CARBS_G = 205;
    private static final int NCODE_FIBRE_G = 291;
    private static final int NCODE_SODIUM_MG = 307;

    private static final String SOURCE_API_NAME = "USDA";

    private final UsdaApiClient usdaApiClient;

    public NutritionDataAdapter(UsdaApiClient usdaApiClient) {
        this.usdaApiClient = usdaApiClient;
    }

    @Override
    public List<ExternalIngredientItemResponse> findExternalIngredient(String name) {
        UsdaSearchResponse response = usdaApiClient.searchFoods(name);

        return response.foods().stream().map(this::translateSearchFood)
                                        .toList();
    }

    @Override
    public ExternalIngredientItemResponse getExternalIngredientDetails(String sourceId) {
        UsdaFoodDetail foodDetails = usdaApiClient.getFoodDetails(sourceId);
        
        return translateFoodDetails(foodDetails);
    }

    // ========== helper functions ==========

    // translate USDA response shape to Mealchemy shape

    private ExternalIngredientItemResponse translateSearchFood(UsdaSearchFood food) {
        List<UsdaShortNutrient> nutritionalVals = food.foodNutrients();

        return new ExternalIngredientItemResponse(
            food.description(), // name
            null, //need to find category name in another step
            toCalories(findAmountByNumber(nutritionalVals, NCODE_ENERGY_KCAL)),
            toBigDecimal(findAmountByNumber(nutritionalVals, NCODE_PROTEIN_G)),
            toBigDecimal(findAmountByNumber(nutritionalVals, NCODE_CARBS_G)),
            toBigDecimal(findAmountByNumber(nutritionalVals, NCODE_FAT_G)),
            toBigDecimal(findAmountByNumber(nutritionalVals, NCODE_FIBRE_G)),
            toBigDecimal(findAmountByNumber(nutritionalVals, NCODE_SODIUM_MG)),
            SOURCE_API_NAME,
            String.valueOf(food.fdcId())
        );
    }
    

    private ExternalIngredientItemResponse translateFoodDetails(UsdaFoodDetail foodDetail) {
        List<UsdaFoodNutrient> nutritionalVals = foodDetail.foodNutrients();

        String categoryName = null; 

        if(foodDetail.foodCategory() != null) {
            categoryName = foodDetail.foodCategory().description();
        }
        
        return new ExternalIngredientItemResponse(
            foodDetail.description(), // name
            categoryName, //need to find category name in another step
            toCalories(findAmountByNumber(nutritionalVals, String.valueOf(NCODE_ENERGY_KCAL))),
            toBigDecimal(findAmountByNumber(nutritionalVals, String.valueOf(NCODE_PROTEIN_G))),
            toBigDecimal(findAmountByNumber(nutritionalVals, String.valueOf(NCODE_CARBS_G))),
            toBigDecimal(findAmountByNumber(nutritionalVals, String.valueOf(NCODE_FAT_G))),
            toBigDecimal(findAmountByNumber(nutritionalVals, String.valueOf(NCODE_FIBRE_G))),
            toBigDecimal(findAmountByNumber(nutritionalVals, String.valueOf(NCODE_SODIUM_MG))),
            SOURCE_API_NAME,
            String.valueOf(foodDetail.fdcId())
        );
    }


    // lookup helpers to extract nutritional values and map to the correct data type

    private Double findAmountByNumber(List<UsdaShortNutrient> nutritionalVals, int number) {
        
        return nutritionalVals.stream().filter(n -> n.number() != null && n.number() == number)
                                       .map(UsdaShortNutrient::amount)
                                       .findFirst()
                                       .orElse(null);
    }

    private Double findAmountByNumber(List<UsdaFoodNutrient> nutritionalVals, String number) {
        
        return nutritionalVals.stream().filter(n -> n.nutrient() != null && number.equals(n.nutrient().number()))
                                       .map(UsdaFoodNutrient::amount)
                                       .findFirst()
                                       .orElse(null);
    }

    // helpers to convert to needed data types

    private Integer toCalories(Double amount) {
        if (amount != null) {
            return (int) Math.round(amount);
        }

        // if amount is null
        return null;
    }

    private BigDecimal toBigDecimal(Double amount) {
        if (amount != null) {
            return BigDecimal.valueOf(amount);
        }

        // if amount is null
        return null;
    }

}