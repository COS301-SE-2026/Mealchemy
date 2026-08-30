package com.mealchemy.recipe.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.tags.model.RecipeTags;
import com.mealchemy.tags.model.Tags;
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
import com.mealchemy.engine.client.EmptyPoolException;
import java.math.BigDecimal;

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

    public RecommendationService(PantryIngredientRepository pantryIngredientRepository, 
        IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository,
        UserCuisineAffinitiesRepository userCuisineAffinitiesRepository, UserPreferencesRepository userPreferencesRepository,
        UserPreferenceWeightsRepository userPreferenceWeightsRepository, RecipeRepository recipeRepository, 
        RecipeTagsRepository recipeTagsRepository, EngineClient engineClient)
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
    }

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
        return pantryItems.stream().map(
            item -> {
                IngredientCatalogue catalogue = catalogueById.get(item.getIngredientId());
                IngredientCategory category = categoryById.get(catalogue.getCategoryId());

                Integer shelfLifeDays = resolveShelfLifeDays(category);

                return new PantryEntryRequest(
                    item.getIngredientId(),
                    catalogue.getCategoryId(),
                    item.getQuantity(),
                    item.getUnit(),
                    item.getCreatedAt(),
                    shelfLifeDays,
                    "FRIDGE"
                );
            }).toList();
    }

    private Integer resolveShelfLifeDays(IngredientCategory category)
    {
        Short fridge = category.getFridgeShelfLife();
        Short pantryLife = category.getPantryShelfLife();

        if(fridge != null)
        {
            return fridge.intValue();
        }
        if(pantryLife != null)
        {
            return pantryLife.intValue();
        }
        return null;
    }

    private List<CandidatePoolEntryRequest> buildCandidatePool()
    {
        List<Recipe> recipes = recipeRepository.findByIsCommunityPublishedTrue();

        return recipes.stream().map(recipe -> new CandidatePoolEntryRequest(
            recipe.getRecipeId(),
            recipe.getTitle(),
            recipe.getCuisineType(),
            buildDietaryTags(recipe),
            buildIngredients(recipe),
            null
        )).toList();
    }

    private List<String> buildDietaryTags(Recipe recipe)
    {
        List<RecipeTags> recipeTags = recipeTagsRepository.findByRecipeRecipeId(recipe.getRecipeId());

        return recipeTags.stream().map(RecipeTags::getTag).filter(Tags::getIsDietary).map(Tags::getTagName).toList();
    }

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
            buildPantryEntries(userId)
        );
    }

    public RecommendationResponse getRecommendations(Integer userId, Integer batchSize, List<Integer> excludeRecipeIds, Integer seed)
    {
        UserStateRequest userState = buildUserState(userId);

        List<CandidatePoolEntryRequest> candidatePool = buildCandidatePool();

        RecommendationRequest request = new RecommendationRequest(
            userState, 
            candidatePool, 
            batchSize, 
            excludeRecipeIds, 
            seed
        );

        try
        {
            return engineClient.getRecommendations(request);
        }
        catch(EmptyPoolException e)
        {
            return RecommendationResponse.from(List.of(), 0, true);
        }
    }
}
