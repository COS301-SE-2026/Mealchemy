package com.mealchemy.ingredient.external;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.InjectMocks;

import java.util.List;
import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NutritionDataAdapterTest {
    // @Mock - create fake version of dependency
    @Mock private UsdaApiClient usdaApiClient;

    private NutritionDataAdapter nutritionDataAdapter;

    @BeforeEach
    void setUp() {
        nutritionDataAdapter = new NutritionDataAdapter(usdaApiClient);
    }    

    // ========== search - find external ingredient  ==========
    @Test 
    void findExternalIngredient_translateNutitionValues() {
        // Arrange
        // nutritional info pf Kimchi
        List<UsdaShortNutrient> nutrients = List.of(
            new UsdaShortNutrient(1008, "Energy", 15.0, "KCAL"),
            new UsdaShortNutrient(203, "Protein", 1.1, "G"),
            new UsdaShortNutrient(204, "Total lipid (fat)", 0.5, "G"),
            new UsdaShortNutrient(205, "Carbohydrate, by difference", 2.0, "G"),
            new UsdaShortNutrient(291, "Fibre, total dietary", 1.2, "G"),
            new UsdaShortNutrient(307, "Sodium, Na", 480.0, "MG")
        );

        UsdaSearchFood food = new UsdaSearchFood(2710077L, "Kimchi", "Branded", nutrients);

        when(usdaApiClient.searchFoods("Kimchi")).thenReturn(new UsdaSearchResponse(List.of(food)));

        // Act
        List<ExternalIngredientItemResponse> results = nutritionDataAdapter.findExternalIngredient("Kimchi");

        assertEquals(1, results.size());
        ExternalIngredientItemResponse externalIngredient = results.get(0);
        assertEquals("Kimchi", externalIngredient.name());
        assertNull(externalIngredient.categoryName()); // when doesn't provide category
        // comparing reslut nutrition vals
        assertEquals(15, externalIngredient.caloriesKCal());
        assertEquals(0, BigDecimal.valueOf(1.1).compareTo(externalIngredient.proteinG()));
        assertEquals(0, BigDecimal.valueOf(0.5).compareTo(externalIngredient.fatG()));
        assertEquals(0, BigDecimal.valueOf(2.0).compareTo(externalIngredient.carbsG()));
        assertEquals(0, BigDecimal.valueOf(1.2).compareTo(externalIngredient.fibreG()));
        assertEquals(0, BigDecimal.valueOf(480.0).compareTo(externalIngredient.sodiumMg()));
        assertEquals("USDA", externalIngredient.sourceApi());
        assertEquals("2710077", externalIngredient.sourceId());
    }


    @Test 
    void findExternalIngredient_nutritionValueMissing_putAsNUll() {
        // Arrange
        // nutritional info pf Kimchi
        List<UsdaShortNutrient> nutrients = List.of(
            new UsdaShortNutrient(1008, "Energy", 120.0, "KCAL")
        );

        UsdaSearchFood food = new UsdaSearchFood(1234L, "food item", "Foundation", nutrients);

        when(usdaApiClient.searchFoods("food item")).thenReturn(new UsdaSearchResponse(List.of(food)));

        // Act
        ExternalIngredientItemResponse externalIngredient = nutritionDataAdapter.findExternalIngredient("food item").get(0);

        // comparing reslut nutrition vals
        assertEquals(120, externalIngredient.caloriesKCal());
        assertNull(externalIngredient.proteinG());
        assertNull(externalIngredient.fatG());
        assertNull(externalIngredient.carbsG());
        assertNull(externalIngredient.fibreG());
        assertNull(externalIngredient.sodiumMg());
    }

    @Test 
    void findExternalIngredient_multipleOptions_translateEach() {
        // Arrange
        // nutritional info 
        UsdaSearchFood food1 = new UsdaSearchFood(123L, "Food 1", "Branded", List.of(new UsdaShortNutrient(1008, "Energy", 15.0, "KCAL")));
        UsdaSearchFood food2 = new UsdaSearchFood(456L, "Food 2", "Branded", List.of(new UsdaShortNutrient(1008, "Energy", 27.0, "KCAL")));

        when(usdaApiClient.searchFoods("Food")).thenReturn(new UsdaSearchResponse(List.of(food1, food2)));

        // Act
        List<ExternalIngredientItemResponse> results = nutritionDataAdapter.findExternalIngredient("food");

        // Assert 
        assertEquals(2, results.size());
        //food 1
        assertEquals("Food 1", results.get(0).name());
        assertEquals(15, results.get(0).caloriesKCal());
        //food 2
        assertEquals("Food 2", results.get(1).name());
        assertEquals(27, results.get(1).caloriesKCal());
    }

    @Test 
    void findExternalIngredient_caloriesRoundToWhole() {
        // Arrange
        // nutritional info 
        UsdaSearchFood food1 = new UsdaSearchFood(123L, "Round food", "Branded", List.of(new UsdaShortNutrient(1008, "Energy", 15.5, "KCAL")));

        when(usdaApiClient.searchFoods("Round")).thenReturn(new UsdaSearchResponse(List.of(food1)));

        // Act
        ExternalIngredientItemResponse results = nutritionDataAdapter.findExternalIngredient("Round").get(0);

        // Assert 
        assertEquals(16, results.caloriesKCal());
   
    }


    // ========== search - find ingredient details  ==========

    @Test 
    void getExternalIngredientDetails_translateWithCategory() {
        // Arrange
        // nutritional info pf Kimchi
        List<UsdaFoodNutrient> nutrients = List.of(
            new UsdaFoodNutrient(15.0, new UsdaNutrient("1008", "Energy", "KCAL")), 
            new UsdaFoodNutrient(1.2, new UsdaNutrient("203", "Protein", "G"))
        );

        UsdaFoodCategory category = new UsdaFoodCategory(11, "1100", "Vegetables and Vegetable Products");

        UsdaFoodDetail detail = new UsdaFoodDetail(2710077L, "Kimchi", "Foundation", category, nutrients);

        when(usdaApiClient.getFoodDetails("2710077")).thenReturn(detail);

        // Act
        ExternalIngredientItemResponse result = nutritionDataAdapter.getExternalIngredientDetails("2710077");

        assertEquals("Kimchi", result.name());
        assertEquals("Vegetables and Vegetable Products", result.categoryName());
        assertEquals(15, result.caloriesKCal());
        assertEquals(0, BigDecimal.valueOf(1.2).compareTo(result.proteinG()));
        assertEquals("USDA", result.sourceApi());
        assertEquals("2710077", result.sourceId());
    }

    @Test 
    void getExternalIngredientDetails_translateWithNoFoodCategory() {
        // Arrange
        // nutritional info pf Kimchi
        List<UsdaFoodNutrient> nutrients = List.of(
            new UsdaFoodNutrient(250.0, new UsdaNutrient("1008", "Energy", "KCAL")), 
            new UsdaFoodNutrient(1.2, new UsdaNutrient("203", "Protein", "G"))
        );

        UsdaFoodDetail detail = new UsdaFoodDetail(12345L, "Snack", "Foundation", null, nutrients);

        when(usdaApiClient.getFoodDetails("12345")).thenReturn(detail);

        // Act
        ExternalIngredientItemResponse result = nutritionDataAdapter.getExternalIngredientDetails("12345");

        assertNull(result.categoryName());
        assertEquals(250, result.caloriesKCal());
    }

    @Test 
    void getExternalIngredientDetails_matchesNutrientNumberAsString() {
        // Arrange
        // nutritional info
        List<UsdaFoodNutrient> nutrients = List.of(
            new UsdaFoodNutrient(18.0, new UsdaNutrient("307", "Sodium, Na", "MG")) 
        );

        UsdaFoodDetail detail = new UsdaFoodDetail(12345L, "Salty Snack", "Branded", null, nutrients);

        when(usdaApiClient.getFoodDetails("12345")).thenReturn(detail);

        // Act
        ExternalIngredientItemResponse result = nutritionDataAdapter.getExternalIngredientDetails("12345");

        assertEquals(0, BigDecimal.valueOf(18.0).compareTo(result.sodiumMg()));
        assertNull(result.categoryName());
    }

}