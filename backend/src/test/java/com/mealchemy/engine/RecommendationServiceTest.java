package com.mealchemy.engine;

// service under test
import com.mealchemy.engine.service.RecommendationService;

// dtos
import com.mealchemy.engine.dto.CandidatePoolEntryRequest;
import com.mealchemy.engine.dto.EnrichedRecommendationItem;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.engine.dto.IngredientRequest;
import com.mealchemy.engine.dto.RecommendationDto;
import com.mealchemy.engine.dto.RecommendationRequest;
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.engine.client.EmptyPoolException;
import com.mealchemy.engine.client.EngineClient;

// models
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

// repositories
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.preference.repository.UserCuisineAffinitiesRepository;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.tags.repository.RecipeTagsRepository;
import com.mealchemy.swipes.repository.SwipeRepository;

// nutrition
import com.mealchemy.nutritionalcalculator.service.NutritionalCalculatorService;

// shared
import com.mealchemy.shared.enums.StorageLocation;
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.swipes.dto.SwipeHistoryEntryRequest;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class RecommendationServiceTest {

    private static final Integer USER_ID = 1;

    @Mock private PantryIngredientRepository pantryIngredientRepository;
    @Mock private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Mock private IngredientCategoryRepository ingredientCategoryRepository;
    @Mock private UserCuisineAffinitiesRepository userCuisineAffinitiesRepository;
    @Mock private UserPreferencesRepository userPreferencesRepository;
    @Mock private UserPreferenceWeightsRepository userPreferenceWeightsRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private RecipeTagsRepository recipeTagsRepository;
    @Mock private EngineClient engineClient;
    @Mock private NutritionalCalculatorService nutritionalCalculatorService;
    @Mock private SwipeRepository swipeRepository;

    @InjectMocks
    private RecommendationService recommendationService;

    private UserPreferences preferences;
    private UserPreferenceWeights weights;
    private IngredientCategory category;
    private IngredientCatalogue catalogue;
    private RecipeIngredient recipeIngredient;
    private Recipe recipe;

    @BeforeEach
    void setUp() {
        preferences = new UserPreferences();
        preferences.setUserId(USER_ID);
        preferences.setAllergies(List.of());
        preferences.setDislikedIngredients(List.of());
        preferences.setDietaryRestrictions(List.of());
        preferences.setNutritionalGoals(List.of());

        weights = new UserPreferenceWeights();
        weights.setUserId(USER_ID);
        weights.setPantryMatch(new BigDecimal("0.30"));
        weights.setCuisine(new BigDecimal("0.20"));
        weights.setNutrition(new BigDecimal("0.20"));
        weights.setFreshness(new BigDecimal("0.15"));
        weights.setNovelty(new BigDecimal("0.15"));
        weights.setStateVersion(1);

        category = new IngredientCategory();
        ReflectionTestUtils.setField(category, "categoryId", 5);
        category.setCategoryName("Legumes and Legume Products");
        category.setPantryShelfLife((short) 30);
        category.setPantryFridgeLife((short) 10);

        catalogue = new IngredientCatalogue();
        ReflectionTestUtils.setField(catalogue, "ingId", 10);
        catalogue.setCategoryId(5);
        catalogue.setName("Hummus");

        recipeIngredient = new RecipeIngredient();
        recipeIngredient.setIngId(10);
        recipeIngredient.setQuantity(new BigDecimal("100"));
        recipeIngredient.setUnit("g");
        recipeIngredient.setSortOrder(1);

        recipe = new Recipe();
        ReflectionTestUtils.setField(recipe, "recipeId", 100);
        recipe.setOwnerId(USER_ID);
        recipe.setTitle("Hummus Bowl");
        recipe.setDescription("A tasty bowl.");
        recipe.setCuisineType("MEDITERRANEAN");
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(0);
        recipe.setServingSize(2);
        recipe.setIsCommunityPublished(true);
        recipe.setIngredients(List.of(recipeIngredient));

        lenient().when(userPreferencesRepository.findByUserId(USER_ID)).thenReturn(Optional.of(preferences));
        lenient().when(userPreferenceWeightsRepository.findByUserId(USER_ID)).thenReturn(Optional.of(weights));
        lenient().when(userCuisineAffinitiesRepository.findAllByUserId(USER_ID)).thenReturn(List.of());
        lenient().when(pantryIngredientRepository.findByUserId(USER_ID)).thenReturn(List.of());
        lenient().when(swipeRepository.findByUserId(USER_ID)).thenReturn(List.of());
        lenient().when(recipeRepository.findByIsCommunityPublishedTrue()).thenReturn(List.of(recipe));
        lenient().when(ingredientCatalogueRepository.findAllById(any())).thenReturn(List.of(catalogue));
        lenient().when(ingredientCategoryRepository.findAllById(any())).thenReturn(List.of(category));
        lenient().when(recipeTagsRepository.findByRecipeRecipeId(100)).thenReturn(List.of());
        lenient().when(nutritionalCalculatorService.getRecipeNutrition(anyInt(), anyInt()))
            .thenThrow(new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found or not accessible"));
    }

    // ========== Happy Path ==========

    @Test
    void getRecommendations_happyPath_enrichesRecipeDataIntoResponse() {
        // Arrange
        SignalScoresResponse scoreBreakdown = new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0);
        RecommendationDto dto = RecommendationDto.from(
            100, "MEDITERRANEAN", new BigDecimal("0.87"), scoreBreakdown, 2, List.of("parmesan", "basil")
        );
        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(dto), Map.of("MEDITERRANEAN", 1), 1, 1);

        when(engineClient.getRecommendations(any(RecommendationRequest.class))).thenReturn(engineResponse);

        // Act
        EnrichedRecommendationResponse response = recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        assertEquals(1, response.recommendations().size());
        EnrichedRecommendationItem item = response.recommendations().get(0);
        assertEquals(100, item.recipeId());
        assertEquals("Hummus Bowl", item.recipe().title());
        assertEquals(2, item.pantryGapCount());
        assertEquals(List.of("parmesan", "basil"), item.missingIngredients());
    }

    @Test
    void getRecommendations_passesBatchSizeExcludeIdsAndSeedThroughUnchanged() {
        // Arrange
        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 15, List.of(200, 201), 42);

        // Assert
        RecommendationRequest sent = captor.getValue();
        assertEquals(15, sent.batchSize());
        assertEquals(List.of(200, 201), sent.excludeRecipeIds());
        assertEquals(42, sent.seed());
    }

    @Test
    void getRecommendations_buildsIngredientRequestsFromRecipeIngredients() {
        // Arrange
        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        CandidatePoolEntryRequest candidate = captor.getValue().candidatePool().get(0);
        assertEquals(1, candidate.ingredients().size());
        IngredientRequest ingredientRequest = candidate.ingredients().get(0);
        assertEquals(10, ingredientRequest.ingId());
        assertEquals("Hummus", ingredientRequest.name());
        assertEquals(5, ingredientRequest.categoryId());
    }

    // ========== Missing Preference Rows ==========

    @Test
    void getRecommendations_whenPreferencesMissing_throwsInternalServerError() {
        // Arrange
        when(userPreferencesRepository.findByUserId(USER_ID)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recommendationService.getRecommendations(USER_ID, 10, List.of(), null)
        );

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, ex.getStatusCode());
    }

    @Test
    void getRecommendations_whenPreferenceWeightsMissing_throwsInternalServerError() {
        // Arrange
        when(userPreferenceWeightsRepository.findByUserId(USER_ID)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recommendationService.getRecommendations(USER_ID, 10, List.of(), null)
        );

        // Assert
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, ex.getStatusCode());
    }

    // ========== Empty Pool ==========

    @Test
    void getRecommendations_whenPoolEmpty_returnsEmptyEnrichedResponse() {
        // Arrange
        when(engineClient.getRecommendations(any(RecommendationRequest.class)))
            .thenThrow(new EmptyPoolException("No recipes remain in the pool after hard-filtering."));

        // Act
        EnrichedRecommendationResponse response = recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        assertTrue(response.recommendations().isEmpty());
        assertEquals(Map.of(), response.cuisineAllocation());
        assertEquals(0, response.totalCandidatesAfterFilter());
        assertEquals(0, response.totalRecipesConsidered());
    }

    // ========== Enrichment — Defensive Skip ==========

    @Test
    void getRecommendations_whenEngineReturnsUnknownRecipeId_skipsItSilently() {
        // Arrange
        SignalScoresResponse scoreBreakdown = new SignalScoresResponse(0.5, 0.5, 0.5, 0.5, 0.5);
        RecommendationDto unknownDto = RecommendationDto.from(
            999, "ITALIAN", new BigDecimal("0.5"), scoreBreakdown, 0, List.of()
        );
        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(unknownDto), Map.of(), 1, 1);

        when(engineClient.getRecommendations(any(RecommendationRequest.class))).thenReturn(engineResponse);

        // Act
        EnrichedRecommendationResponse response = recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert 
        assertTrue(response.recommendations().isEmpty());
    }

    // ========== Pantry Entries ==========

    @Test
    void getRecommendations_pantryItemWithNullStorageLocation_isExcludedFromRequest() {
        // Arrange
        PantryIngredient noLocation = new PantryIngredient();
        noLocation.setUserId(USER_ID);
        noLocation.setIngredientId(10);
        noLocation.setQuantity(new BigDecimal("200"));
        noLocation.setUnit("g");
        noLocation.setStorageLocation(null);
        ReflectionTestUtils.setField(noLocation, "createdAt", OffsetDateTime.now());

        when(pantryIngredientRepository.findByUserId(USER_ID)).thenReturn(List.of(noLocation));

        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert 
        assertTrue(captor.getValue().userState().pantry().isEmpty());
    }

    @Test
    void getRecommendations_pantryItemWithNoResolvableShelfLife_isExcludedFromRequest() {
        // Arrange 
        IngredientCategory noShelfLifeCategory = new IngredientCategory();
        ReflectionTestUtils.setField(noShelfLifeCategory, "categoryId", 5);
        noShelfLifeCategory.setCategoryName("Mystery Category");

        PantryIngredient fridgeItem = new PantryIngredient();
        fridgeItem.setUserId(USER_ID);
        fridgeItem.setIngredientId(10);
        fridgeItem.setQuantity(new BigDecimal("200"));
        fridgeItem.setUnit("g");
        fridgeItem.setStorageLocation(StorageLocation.FRIDGE);
        ReflectionTestUtils.setField(fridgeItem, "createdAt", OffsetDateTime.now());

        when(pantryIngredientRepository.findByUserId(USER_ID)).thenReturn(List.of(fridgeItem));
        when(ingredientCategoryRepository.findAllById(any())).thenReturn(List.of(noShelfLifeCategory));

        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        assertTrue(captor.getValue().userState().pantry().isEmpty());
    }

    // ========== Dietary Tags ==========

    @Test
    void getRecommendations_dietaryTagsFilteredToOnlyDietaryOnes() {
        // Arrange
        Tags dietaryTag = new Tags();
        dietaryTag.setTagName("VEGAN");
        dietaryTag.setIsActive(true);
        dietaryTag.setIsDietary(true);

        Tags nonDietaryTag = new Tags();
        nonDietaryTag.setTagName("QUICK_MEAL");
        nonDietaryTag.setIsActive(true);
        nonDietaryTag.setIsDietary(false);

        RecipeTags dietaryRecipeTag = new RecipeTags();
        dietaryRecipeTag.setTag(dietaryTag);
        RecipeTags nonDietaryRecipeTag = new RecipeTags();
        nonDietaryRecipeTag.setTag(nonDietaryTag);

        when(recipeTagsRepository.findByRecipeRecipeId(100)).thenReturn(List.of(dietaryRecipeTag, nonDietaryRecipeTag));

        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        CandidatePoolEntryRequest candidate = captor.getValue().candidatePool().get(0);
        assertEquals(List.of("VEGAN"), candidate.dietaryTags());
    }

   @Test
    void getRecommendations_dietaryTagWithNullIsDietaryFlag_treatedAsNotDietary() {
        // Arrange
        Tags tagWithNullDietaryFlag = new Tags();
        tagWithNullDietaryFlag.setTagName("VEGAN");
        tagWithNullDietaryFlag.setIsActive(true);

        RecipeTags recipeTag = new RecipeTags();
        recipeTag.setTag(tagWithNullDietaryFlag);

        when(recipeTagsRepository.findByRecipeRecipeId(100)).thenReturn(List.of(recipeTag));

        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert 
        CandidatePoolEntryRequest candidate = captor.getValue().candidatePool().get(0);
        assertTrue(candidate.dietaryTags().isEmpty());
    }

    // ========== Nutrition ==========

    @Test
    void getRecommendations_whenNutritionServiceReturns404_candidateStillBuiltWithNullNutrition() {
        // Arrange

        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        CandidatePoolEntryRequest candidate = captor.getValue().candidatePool().get(0);
        assertNull(candidate.nutrition());
    }

    // ========== Swipe History ==========

    @Test
    void getRecommendations_includesSwipeHistoryInUserState() {
        // Arrange
        Swipe swipe = new Swipe();
        swipe.setUserId(USER_ID);
        swipe.setRecipeId(50);
        swipe.setAction(SwipeAction.LIKED);
        ReflectionTestUtils.setField(swipe, "swipedAt", OffsetDateTime.parse("2026-08-01T12:00:00Z"));

        when(swipeRepository.findByUserId(USER_ID)).thenReturn(List.of(swipe));

        RecommendationResponse engineResponse = RecommendationResponse.from(List.of(), Map.of(), 0, 1);
        ArgumentCaptor<RecommendationRequest> captor = ArgumentCaptor.forClass(RecommendationRequest.class);
        when(engineClient.getRecommendations(captor.capture())).thenReturn(engineResponse);

        // Act
        recommendationService.getRecommendations(USER_ID, 10, List.of(), null);

        // Assert
        List<SwipeHistoryEntryRequest> history = captor.getValue().userState().swipeHistory();
        assertEquals(1, history.size());
        assertEquals(50, history.get(0).recipeId());
        assertEquals(SwipeAction.LIKED, history.get(0).action());
    }
}