package com.mealchemy.engine.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;
import java.math.BigDecimal;

/* Import classes */
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.tags.model.RecipeTags;
import com.mealchemy.tags.model.Tags;
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.model.UserPreferenceWeights;
import com.mealchemy.preference.model.UserCuisineAffinities;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.preference.repository.UserCuisineAffinitiesRepository;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.tags.repository.RecipeTagsRepository;
import com.mealchemy.engine.client.EngineClient;
import com.mealchemy.engine.dto.PantryEntryRequest; 
import com.mealchemy.engine.dto.CandidatePoolEntryRequest;
import com.mealchemy.engine.dto.IngredientRequest;
import com.mealchemy.engine.dto.UserStateRequest;
import com.mealchemy.engine.dto.PreferenceWeightsRequest;
import com.mealchemy.engine.dto.RecommendationRequest;
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.engine.dto.EnrichedRecommendationItem;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.swipes.dto.SwipeHistoryEntryRequest;
import com.mealchemy.engine.client.EmptyPoolException;
import com.mealchemy.shared.enums.StorageLocation;
import com.mealchemy.nutritionalcalculator.service.NutritionalCalculatorService;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionResponse;
import com.mealchemy.nutritionalcalculator.dto.RecipeNutritionValues;
import com.mealchemy.engine.dto.NutritionRequest;
import com.mealchemy.swipes.repository.SwipeRepository;

@Service
public class RecommendationService {
    private final PantryIngredientRepository pantryIngredientRepository;
    private final IngredientCatalogueRepository ingredientCatalogueRepository;
    private final IngredientCategoryRepository ingredientCategoryRepository;
    private final UserCuisineAffinitiesRepository userCuisineAffinitiesRepository;
    private final UserPreferencesRepository userPreferencesRepository;
    private final UserPreferenceWeightsRepository userPreferenceWeightsRepository;
    private final RecipeRepository recipeRepository;
    private final RecipeTagsRepository recipeTagsRepository;
    private final EngineClient engineClient;
    private final NutritionalCalculatorService nutritionalCalculatorService;
    private final SwipeRepository swipeRepository;

    private record CandidatePoolResult(
        List<CandidatePoolEntryRequest> pool,
        Map<Integer, Recipe> recipeById
    ){}

    public RecommendationService(PantryIngredientRepository pantryIngredientRepository, 
        IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository,
        UserCuisineAffinitiesRepository userCuisineAffinitiesRepository, UserPreferencesRepository userPreferencesRepository,
        UserPreferenceWeightsRepository userPreferenceWeightsRepository, RecipeRepository recipeRepository, 
        RecipeTagsRepository recipeTagsRepository, EngineClient engineClient, NutritionalCalculatorService nutritionalCalculatorService,
        SwipeRepository swipeRepository)
    {
        this.pantryIngredientRepository = pantryIngredientRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.ingredientCategoryRepository = ingredientCategoryRepository;
        this.userCuisineAffinitiesRepository = userCuisineAffinitiesRepository;
        this.userPreferencesRepository = userPreferencesRepository;
        this.userPreferenceWeightsRepository = userPreferenceWeightsRepository;
        this.recipeRepository = recipeRepository;
        this.recipeTagsRepository = recipeTagsRepository;
        this.engineClient = engineClient;
        this.nutritionalCalculatorService = nutritionalCalculatorService;
        this.swipeRepository = swipeRepository;
    }

    // Helper function to build the pantry entries object
    private List<PantryEntryRequest> buildPantryEntries(Integer userId)
    {
        List<PantryIngredient> pantryItems = pantryIngredientRepository.findByUserId(userId);

        // Resolve categoryId per ingredient
        List<Integer> ingIds = pantryItems.stream().map(PantryIngredient::getIngredientId).distinct().toList();
        Map<Integer, IngredientCatalogue> catalogueById = ingredientCatalogueRepository.findAllById(ingIds).stream().collect(Collectors.toMap(IngredientCatalogue::getIngId, ic -> ic));

        // Resolve shelf life per category
        List<Integer> categoryIds = catalogueById.values().stream().map(IngredientCatalogue::getCategoryId).distinct().toList();
        Map<Integer, IngredientCategory> categoryById = ingredientCategoryRepository.findAllById(categoryIds).stream().collect(Collectors.toMap(IngredientCategory::getCategoryId, c -> c));

        // Map each pantry item
        return pantryItems.stream()
        .map(item -> {
            IngredientCatalogue catalogue = catalogueById.get(item.getIngredientId());
            IngredientCategory category = categoryById.get(catalogue.getCategoryId());
            StorageLocation storageLocation = item.getStorageLocation();

            if (storageLocation == null) return null;

            Integer shelfLifeDays = resolveShelfLifeDays(category, storageLocation);
            if (shelfLifeDays == null) return null;

            return new PantryEntryRequest(
                item.getIngredientId(),
                catalogue.getCategoryId(),
                item.getQuantity(),
                item.getUnit(),
                item.getCreatedAt(),
                shelfLifeDays,
                storageLocation.name()
            );
        })
        .filter(Objects::nonNull)
        .toList();
    }

    // Helper function to resolve ingredient's shelf life
    private Integer resolveShelfLifeDays(IngredientCategory category, StorageLocation storageLocation)
    {
        Integer fridge = category.getFridgeShelfLife() != null ? category.getFridgeShelfLife().intValue() : null;
        Integer pantry = category.getPantryShelfLife() != null ? category.getPantryShelfLife().intValue() : null;

        return switch (storageLocation) {
            case FRIDGE -> fridge != null ? fridge : pantry;
            case PANTRY -> pantry != null ? pantry : fridge;
        };
    }

    // Helper function to build the candidate pool
    private CandidatePoolResult buildCandidatePool(Integer userId)
    {
        List<Recipe> recipes = recipeRepository.findByIsCommunityPublishedTrue();

        Map<Integer, Recipe> recipeById = recipes.stream()
            .collect(Collectors.toMap(Recipe::getRecipeId, r -> r));

        List<CandidatePoolEntryRequest> pool = recipes.stream().map(recipe -> new CandidatePoolEntryRequest(
            recipe.getRecipeId(),
            recipe.getTitle(),
            recipe.getCuisineType(),
            buildDietaryTags(recipe),
            buildIngredients(recipe),
            buildNutrition(userId, recipe.getRecipeId())
        )).toList();

        return new CandidatePoolResult(pool, recipeById);
    }

    // Helper function to build the butrition request object
    private NutritionRequest buildNutrition(Integer userId, Integer recipeId)
    {
        try {
            RecipeNutritionResponse nutrition = nutritionalCalculatorService.getRecipeNutrition(userId, recipeId);
            RecipeNutritionValues totals = nutrition.totals();
            return new NutritionRequest(
                totals.caloriesKcal() != null ? totals.caloriesKcal().intValue() : null,
                totals.proteinG(),
                totals.carbsG(),
                totals.fatG()
            );
        } catch (ResponseStatusException e) {
        return null;
        }
    }

    // Helper function to build the dietary tags object
    private List<String> buildDietaryTags(Recipe recipe)
    {
        List<RecipeTags> recipeTags = recipeTagsRepository.findByRecipeRecipeId(recipe.getRecipeId());

        return recipeTags.stream()
            .map(RecipeTags::getTag)
            .filter(tag -> Boolean.TRUE.equals(tag.getIsDietary()))
            .map(Tags::getTagName)
            .toList();    
    }

    // Helper function to build ingredients object
    private List<IngredientRequest> buildIngredients(Recipe recipe)
    {
        List<RecipeIngredient> recipeIngredients = recipe.getIngredients();

        List<Integer> ingIds = recipeIngredients.stream().map(RecipeIngredient::getIngId).distinct().toList();

        Map<Integer, IngredientCatalogue> catalogueById = ingredientCatalogueRepository.findAllById(ingIds).stream().collect(Collectors.toMap(IngredientCatalogue::getIngId, ic -> ic));

        return recipeIngredients.stream().map(ri -> {
            IngredientCatalogue catalogue = catalogueById.get(ri.getIngId());
            return new IngredientRequest(
                ri.getIngId(),
                catalogue.getCategoryId(),
                catalogue.getName(),
                ri.getQuantity(),
                ri.getUnit()
            );
        }).toList();
    }

    // Helper function to build the user state object
    private UserStateRequest buildUserState(Integer userId)
    {
        UserPreferences preferences = userPreferencesRepository.findByUserId(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "User preferences not initialized."));

        UserPreferenceWeights weights = userPreferenceWeightsRepository.findByUserId(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "User preference weights not initialized."));

        List<UserCuisineAffinities> affinities = userCuisineAffinitiesRepository.findAllByUserId(userId);
        Map<String, BigDecimal> cuisineAffinityMap = affinities.stream().collect(Collectors.toMap(UserCuisineAffinities::getCuisineValue, UserCuisineAffinities::getAffinityScore));

        PreferenceWeightsRequest weightsRequest = new PreferenceWeightsRequest(
            weights.getPantryMatch(),
            weights.getCuisine(),
            weights.getNutrition(),
            weights.getFreshness(),
            weights.getNovelty()
        );

        return new UserStateRequest(
            userId,
            preferences.getAllergies(),
            preferences.getDislikedIngredients(),
            preferences.getDietaryRestrictions(),
            preferences.getNutritionalGoals(),
            weightsRequest,
            cuisineAffinityMap,
            buildPantryEntries(userId),
            buildSwipeHistory(userId)
        );
    }

    // get all recommended recipes 
    public EnrichedRecommendationResponse getRecommendations(Integer userId, Integer batchSize, List<Integer> excludeRecipeIds, Integer seed)
    {
        UserStateRequest userState = buildUserState(userId);

        CandidatePoolResult candidatePoolResult = buildCandidatePool(userId);

        RecommendationRequest request = new RecommendationRequest(
            userState,
            candidatePoolResult.pool(),
            batchSize,
            excludeRecipeIds,
            seed
        );

        RecommendationResponse engineResponse;
        try
        {
            engineResponse = engineClient.getRecommendations(request);
        }
        catch (EmptyPoolException e)
        {
            return EnrichedRecommendationResponse.empty();
        }

        List<EnrichedRecommendationItem> enrichedItems = engineResponse.recommendations().stream()
            .map(item -> {
                Recipe recipe = candidatePoolResult.recipeById().get(item.recipeId());
                if (recipe == null)
                {
                    return null;
                }
                return new EnrichedRecommendationItem(
                    item.recipeId(),
                    item.cuisineType(),
                    item.score(),
                    item.scoreBreakdown(),
                    item.pantryGapCount(),
                    item.missingIngredients(),
                    RecipeResponse.from(recipe)
                );
            })
            .filter(Objects::nonNull)
            .toList();

        return new EnrichedRecommendationResponse(
            enrichedItems,
            engineResponse.cuisineAllocation(),
            engineResponse.totalCandidatesAfterFilter(),
            engineResponse.totalRecipesConsidered()
        );
    }

    // Helper function to build the swipe history object
    private List<SwipeHistoryEntryRequest> buildSwipeHistory(Integer userId)
    {
        return swipeRepository.findByUserId(userId).stream()
            .map(swipe -> new SwipeHistoryEntryRequest(
                swipe.getRecipeId(),
                swipe.getAction(),
                swipe.getSwipedAt()
            ))
            .toList();
    }
}
