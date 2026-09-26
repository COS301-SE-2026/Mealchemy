package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

/* Import classes */
import com.mealchemy.engine.dto.PantryEntryRequest;
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.shared.unitconverter.UnitConverter;

@Service
public class PantryProjectionService {
    private final RecommendationService recommendationService;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final RecipeIngredientRepository recipeIngredientRepository;

    public PantryProjectionService(RecommendationService recommendationService,
        MealPlanEntryRepository mealPlanEntryRepository, RecipeIngredientRepository recipeIngredientRepository)
    {
        this.recommendationService = recommendationService;
        this.mealPlanEntryRepository = mealPlanEntryRepository;
        this.recipeIngredientRepository = recipeIngredientRepository;
    }

    // builds a projection of the pantry after all the days before's recipe ingredients have been deducted
    public List<PantryEntryRequest> buildProjectedPantry(Integer userId, Integer planId, LocalDate beforeDate)
    {
        List<PantryEntryRequest> pantry = recommendationService.buildPantryEntries(userId);

        List<MealPlanEntry> priorEntries = mealPlanEntryRepository
            .findByPlan_PlanIdAndEntryDateLessThanOrderByEntryDateAscMealTimeAsc(planId, beforeDate);

        for (MealPlanEntry entry : priorEntries)
        {
            pantry = applyConsumption(pantry, entry.getRecipeId());
        }

        return pantry;
    }

    // Function used to "consume" ingredients and build the projection
    public List<PantryEntryRequest> applyConsumption(List<PantryEntryRequest> pantry, Integer recipeId)
    {
        List<RecipeIngredient> recipeIngredients = recipeIngredientRepository.findByRecipe_RecipeId(recipeId);
        if (recipeIngredients == null || recipeIngredients.isEmpty())
        {
            return pantry;
        }

        Map<Integer, List<PantryEntryRequest>> rowsByIngId = pantry.stream()
            .collect(Collectors.groupingBy(PantryEntryRequest::ingId, LinkedHashMap::new, Collectors.toList()));
        rowsByIngId.replaceAll((ingId, rows) -> new ArrayList<>(
            rows.stream().sorted(Comparator.comparing(PantryEntryRequest::addedAt)).toList()
        ));

        for (RecipeIngredient ri : recipeIngredients)
        {
            List<PantryEntryRequest> rows = rowsByIngId.get(ri.getIngId());
            if (rows == null || rows.isEmpty())
            {
                continue;
            }

            BigDecimal remainingNeeded = ri.getQuantity();

            for (int i = 0; i < rows.size() && remainingNeeded.compareTo(BigDecimal.ZERO) > 0; i++)
            {
                PantryEntryRequest row = rows.get(i);

                BigDecimal neededInRowUnit;
                try
                {
                    neededInRowUnit = UnitConverter.convert(remainingNeeded, ri.getUnit(), row.unit());
                }
                catch (IllegalArgumentException e)
                {
                    continue;
                }

                BigDecimal consumeFromRow = neededInRowUnit.min(row.quantity());
                BigDecimal newRowQty = row.quantity().subtract(consumeFromRow);

                rows.set(i, new PantryEntryRequest(
                    row.ingId(), row.categoryId(), newRowQty, row.unit(),
                    row.addedAt(), row.shelfLifeDays(), row.storageLocation()
                ));

                BigDecimal consumedInRecipeUnit = UnitConverter.convert(consumeFromRow, row.unit(), ri.getUnit());
                remainingNeeded = remainingNeeded.subtract(consumedInRecipeUnit);
            }
        }

        return rowsByIngId.values().stream().flatMap(List::stream).toList();
    }
}