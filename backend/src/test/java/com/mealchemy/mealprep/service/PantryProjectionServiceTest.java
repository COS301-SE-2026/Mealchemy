package com.mealchemy.mealprep.service;

import com.mealchemy.engine.dto.PantryEntryRequest;
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class PantryProjectionServiceTest {

    private static final Integer USER_ID = 1;
    private static final Integer PLAN_ID = 10;
    private static final Integer RECIPE_ID = 100;
    private static final Integer ING_ID = 5;

    @Mock private RecommendationService recommendationService;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private RecipeIngredientRepository recipeIngredientRepository;

    @InjectMocks
    private PantryProjectionService pantryProjectionService;

    private PantryEntryRequest pantryEntry(Integer ingId, BigDecimal quantity, String unit, OffsetDateTime addedAt) {
        return new PantryEntryRequest(ingId, 1, quantity, unit, addedAt, 30, "PANTRY");
    }

    private RecipeIngredient recipeIngredient(Integer ingId, BigDecimal quantity, String unit) {
        RecipeIngredient ri = new RecipeIngredient();
        ri.setIngId(ingId);
        ri.setQuantity(quantity);
        ri.setUnit(unit);
        return ri;
    }

    private MealPlanEntry entryForRecipe(Integer recipeId) {
        MealPlanEntry entry = new MealPlanEntry();
        entry.setRecipeId(recipeId);
        return entry;
    }

    // ========== buildProjectedPantry ==========

    @Test
    void buildProjectedPantry_noPriorEntries_returnsBasePantryUnchanged() {
        // Arrange
        List<PantryEntryRequest> basePantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));
        when(recommendationService.buildPantryEntries(USER_ID)).thenReturn(basePantry);
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateLessThanOrderByEntryDateAscMealTimeAsc(PLAN_ID, LocalDate.of(2026, 10, 1)))
            .thenReturn(List.of());

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.buildProjectedPantry(USER_ID, PLAN_ID, LocalDate.of(2026, 10, 1));

        // Assert
        assertEquals(1, result.size());
        assertEquals(0, result.get(0).quantity().compareTo(new BigDecimal("500")));
    }

    @Test
    void buildProjectedPantry_appliesConsumptionForEveryPriorEntry() {
        // Arrange
        List<PantryEntryRequest> basePantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));
        when(recommendationService.buildPantryEntries(USER_ID)).thenReturn(basePantry);

        MealPlanEntry entry1 = entryForRecipe(RECIPE_ID);
        MealPlanEntry entry2 = entryForRecipe(RECIPE_ID);
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateLessThanOrderByEntryDateAscMealTimeAsc(PLAN_ID, LocalDate.of(2026, 10, 3)))
            .thenReturn(List.of(entry1, entry2));

        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID))
            .thenReturn(List.of(recipeIngredient(ING_ID, new BigDecimal("100"), "g")));

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.buildProjectedPantry(USER_ID, PLAN_ID, LocalDate.of(2026, 10, 3));

        // Assert
        assertEquals(0, result.get(0).quantity().compareTo(new BigDecimal("300")));
    }

    // ========== applyConsumption ==========

    @Test
    void applyConsumption_recipeHasNoIngredients_returnsPantryUnchanged() {
        // Arrange
        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID)).thenReturn(List.of());
        List<PantryEntryRequest> pantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        // Assert
        assertEquals(pantry, result);
    }

    @Test
    void applyConsumption_ingredientNotInPantry_isSkippedWithoutError() {
        // Arrange
        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID))
            .thenReturn(List.of(recipeIngredient(999, new BigDecimal("100"), "g")));
        List<PantryEntryRequest> pantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        // Assert
        assertEquals(0, result.get(0).quantity().compareTo(new BigDecimal("500")));
    }

    @Test
    void applyConsumption_singleRow_deductsExactly() {
        // Arrange
        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID))
            .thenReturn(List.of(recipeIngredient(ING_ID, new BigDecimal("150"), "g")));
        List<PantryEntryRequest> pantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        // Assert
        assertEquals(0, result.get(0).quantity().compareTo(new BigDecimal("350")));
    }

    @Test
    void applyConsumption_insufficientStock_flooredAtZero() {
        // Arrange
        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID))
            .thenReturn(List.of(recipeIngredient(ING_ID, new BigDecimal("900"), "g")));
        List<PantryEntryRequest> pantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        // Assert
        assertEquals(0, result.get(0).quantity().compareTo(BigDecimal.ZERO));
    }

    @Test
    void applyConsumption_splitAcrossTwoRows_depletesOldestFirst() {
        // Arrange
        OffsetDateTime older = OffsetDateTime.now().minusDays(5);
        OffsetDateTime newer = OffsetDateTime.now();

        PantryEntryRequest oldRow = pantryEntry(ING_ID, new BigDecimal("100"), "g", older);
        PantryEntryRequest newRow = pantryEntry(ING_ID, new BigDecimal("200"), "g", newer);

        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID))
            .thenReturn(List.of(recipeIngredient(ING_ID, new BigDecimal("150"), "g")));

        List<PantryEntryRequest> pantry = List.of(newRow, oldRow);

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        //Assert
        PantryEntryRequest resultOld = result.stream().filter(r -> r.addedAt().equals(older)).findFirst().orElseThrow();
        PantryEntryRequest resultNew = result.stream().filter(r -> r.addedAt().equals(newer)).findFirst().orElseThrow();

        assertEquals(0, resultOld.quantity().compareTo(BigDecimal.ZERO));
        assertEquals(0, resultNew.quantity().compareTo(new BigDecimal("150")));
    }

    @Test
    void applyConsumption_incompatibleUnit_leavesRowUntouched() {
        // Arrange
        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID))
            .thenReturn(List.of(recipeIngredient(ING_ID, new BigDecimal("100"), "ml")));
        List<PantryEntryRequest> pantry = List.of(pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()));

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        // Assert
        assertEquals(0, result.get(0).quantity().compareTo(new BigDecimal("500")));
    }

    @Test
    void applyConsumption_multipleIngredients_eachDeductedIndependently() {
        // Arrange
        Integer secondIngId = 6;
        when(recipeIngredientRepository.findByRecipe_RecipeId(RECIPE_ID)).thenReturn(List.of(
            recipeIngredient(ING_ID, new BigDecimal("100"), "g"),
            recipeIngredient(secondIngId, new BigDecimal("50"), "g")
        ));

        List<PantryEntryRequest> pantry = List.of(
            pantryEntry(ING_ID, new BigDecimal("500"), "g", OffsetDateTime.now()),
            pantryEntry(secondIngId, new BigDecimal("80"), "g", OffsetDateTime.now())
        );

        // Act
        List<PantryEntryRequest> result = pantryProjectionService.applyConsumption(pantry, RECIPE_ID);

        // Assert
        PantryEntryRequest resultFirst = result.stream().filter(r -> r.ingId().equals(ING_ID)).findFirst().orElseThrow();
        PantryEntryRequest resultSecond = result.stream().filter(r -> r.ingId().equals(secondIngId)).findFirst().orElseThrow();

        assertEquals(0, resultFirst.quantity().compareTo(new BigDecimal("400")));
        assertEquals(0, resultSecond.quantity().compareTo(new BigDecimal("30")));
    }
}