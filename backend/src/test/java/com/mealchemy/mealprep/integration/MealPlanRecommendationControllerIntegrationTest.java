package com.mealchemy.mealprep.integration;

// models
import com.mealchemy.auth.model.User;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.tags.model.RecipeTags;
import com.mealchemy.tags.model.Tags;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.model.UserPreferenceWeights;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.mealprep.model.MealPlan;
import com.mealchemy.mealprep.model.MealPlanEntry;

// repositories
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.tags.repository.RecipeTagsRepository;
import com.mealchemy.tags.repository.TagsRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.mealprep.repository.MealPlanRepository;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.mealprep.repository.MealPlanRecommendationSignalRepository;
import com.mealchemy.externallinks.repository.ExternalLinkRepository;

// engine client + dtos
import com.mealchemy.engine.client.EngineClient;
import com.mealchemy.engine.dto.RecommendationRequest;
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.engine.dto.RecommendationDto;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.engine.dto.SignalHighlightResponse;

// shared
import com.mealchemy.shared.enums.StorageLocation;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.MealPlanEntrySource;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class MealPlanRecommendationControllerIntegrationTest {

    @Autowired private MockMvc mockMvc;

    @Autowired private UserRepository userRepository;
    @Autowired private RecipeRepository recipeRepository;
    @Autowired private RecipeTagsRepository recipeTagsRepository;
    @Autowired private TagsRepository tagsRepository;
    @Autowired private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Autowired private IngredientCategoryRepository ingredientCategoryRepository;
    @Autowired private PantryIngredientRepository pantryIngredientRepository;
    @Autowired private UserPreferencesRepository userPreferencesRepository;
    @Autowired private UserPreferenceWeightsRepository userPreferenceWeightsRepository;
    @Autowired private VaultRepository vaultRepository;
    @Autowired private MealPlanRepository mealPlanRepository;
    @Autowired private MealPlanEntryRepository mealPlanEntryRepository;
    @Autowired private MealPlanRecommendationSignalRepository signalRepository;
    @Autowired private ExternalLinkRepository externalLinksRepository;

    @MockitoBean private EngineClient engineClient;

    private Integer testUserId;
    private Integer testRecipeId;
    private Integer privatePlanId;
    private Integer sharedPlanId;

    @BeforeEach
    void setUp() {
        mealPlanEntryRepository.deleteAll();
        mealPlanRepository.deleteAll();
        vaultRepository.deleteAll();
        recipeTagsRepository.deleteAll();
        tagsRepository.deleteAll();
        pantryIngredientRepository.deleteAll();
        recipeRepository.deleteAll();
        userPreferencesRepository.deleteAll();
        userPreferenceWeightsRepository.deleteAll();
        externalLinksRepository.deleteAll();
        userRepository.deleteAll();

        User user = new User();
        user.setEmail("mealplan-rec-test-" + System.nanoTime() + "@example.com");
        user.setPasswordHash("dummy-hash");
        user.setRoles(List.of("USER"));
        user = userRepository.save(user);
        testUserId = user.getUserId();

        IngredientCategory category = ingredientCategoryRepository.findAll().stream()
            .filter(c -> "Legumes and Legume Products".equals(c.getCategoryName()))
            .findFirst().orElseThrow(() -> new IllegalStateException("Seeded category not found"));

        IngredientCatalogue catalogue = ingredientCatalogueRepository.findAll().stream()
            .filter(i -> "Hummus, commercial".equals(i.getName()))
            .findFirst().orElseThrow(() -> new IllegalStateException("Seeded ingredient not found"));

        RecipeIngredient ingredient = new RecipeIngredient();
        ingredient.setIngId(catalogue.getIngId());
        ingredient.setQuantity(new BigDecimal("100"));
        ingredient.setUnit("g");
        ingredient.setSortOrder(1);

        Recipe recipe = new Recipe();
        recipe.setOwnerId(testUserId);
        recipe.setTitle("Hummus Bowl");
        recipe.setDescription("A tasty bowl.");
        recipe.setCuisineType("MEDITERRANEAN");
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(0);
        recipe.setServingSize(2);
        recipe.setIsCommunityPublished(true);
        ingredient.setRecipe(recipe);
        recipe.setIngredients(List.of(ingredient));
        recipe = recipeRepository.save(recipe);
        testRecipeId = recipe.getRecipeId();

        PantryIngredient pantryItem = new PantryIngredient();
        pantryItem.setUserId(testUserId);
        pantryItem.setIngredientId(catalogue.getIngId());
        pantryItem.setQuantity(new BigDecimal("200"));
        pantryItem.setUnit("g");
        pantryItem.setStorageLocation(StorageLocation.FRIDGE);
        pantryIngredientRepository.save(pantryItem);

        UserPreferences preferences = new UserPreferences();
        preferences.setUserId(testUserId);
        preferences.setAllergies(List.of());
        preferences.setDislikedIngredients(List.of());
        preferences.setDietaryRestrictions(List.of());
        preferences.setNutritionalGoals(List.of());
        userPreferencesRepository.save(preferences);

        UserPreferenceWeights weights = new UserPreferenceWeights();
        weights.setUserId(testUserId);
        weights.setPantryMatch(new BigDecimal("0.30"));
        weights.setCuisine(new BigDecimal("0.20"));
        weights.setNutrition(new BigDecimal("0.20"));
        weights.setFreshness(new BigDecimal("0.15"));
        weights.setNovelty(new BigDecimal("0.15"));
        weights.setStateVersion(1);
        userPreferenceWeightsRepository.save(weights);

        Vault privateVault = new Vault();
        privateVault.setOwnerId(testUserId);
        privateVault.setVaultType(VaultType.PRIVATE);
        privateVault.setName("My Vault");
        privateVault = vaultRepository.save(privateVault);

        Vault sharedVault = new Vault();
        sharedVault.setOwnerId(testUserId);
        sharedVault.setVaultType(VaultType.SHARED);
        sharedVault.setName("Shared Vault");
        sharedVault = vaultRepository.save(sharedVault);

        MealPlan privatePlan = new MealPlan();
        privatePlan.setVaultId(privateVault.getVaultId());
        privatePlan.setCreatedBy(testUserId);
        privatePlan = mealPlanRepository.save(privatePlan);
        privatePlanId = privatePlan.getPlanId();

        MealPlan sharedPlan = new MealPlan();
        sharedPlan.setVaultId(sharedVault.getVaultId());
        sharedPlan.setCreatedBy(testUserId);
        sharedPlan = mealPlanRepository.save(sharedPlan);
        sharedPlanId = sharedPlan.getPlanId();
    }

    private UsernamePasswordAuthenticationToken authAsTestUser() {
        return new UsernamePasswordAuthenticationToken(String.valueOf(testUserId), null, List.of());
    }

    private RecommendationResponse engineResponseFor(Integer recipeId) {
        SignalScoresResponse scoreBreakdown = new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0);
        RecommendationDto dto = RecommendationDto.from(
            recipeId, "MEDITERRANEAN", new BigDecimal("0.87"), scoreBreakdown, 1, List.of("parmesan"),
            List.of(new SignalHighlightResponse("pantry_match", 90, "Matched 8 of 9 ingredients you already have on hand."))
        );
        return RecommendationResponse.from(List.of(dto), Map.of("MEDITERRANEAN", 1), 1, 1);
    }

    @Test
    void getDayRecommendations_returns200_onPrivateVaultPlan() throws Exception {
        when(engineClient.getRecommendations(any(RecommendationRequest.class))).thenReturn(engineResponseFor(testRecipeId));

        mockMvc.perform(post("/api/meal-plans/{planId}/days/{date}/recommendations", privatePlanId, "2026-10-01")
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"mealSlot\":\"DINNER\",\"count\":3}"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations", hasSize(1)))
            .andExpect(jsonPath("$.recommendations[0].recipeId", is(testRecipeId)));
    }

    @Test
    void getDayRecommendations_returns403_onSharedVaultPlan() throws Exception {
        mockMvc.perform(post("/api/meal-plans/{planId}/days/{date}/recommendations", sharedPlanId, "2026-10-01")
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"mealSlot\":\"DINNER\",\"count\":3}"))
            .andExpect(status().isForbidden());
    }

    @Test
    void getDayRecommendations_returns404_whenPlanDoesNotExist() throws Exception {
        mockMvc.perform(post("/api/meal-plans/{planId}/days/{date}/recommendations", 999999, "2026-10-01")
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"mealSlot\":\"DINNER\",\"count\":3}"))
            .andExpect(status().isNotFound());
    }

    @Test
    void generate_realFlow_createsEntryAndPersistsSignal() throws Exception {
        when(engineClient.getRecommendations(any(RecommendationRequest.class))).thenReturn(engineResponseFor(testRecipeId));

        String body = "{\"startDate\":\"2026-10-01\",\"endDate\":\"2026-10-01\",\"mealSlots\":[\"DINNER\"],"
            + "\"slotTimes\":{\"DINNER\":\"18:00:00\"},\"overwriteRecommended\":false}";

        mockMvc.perform(post("/api/meal-plans/{planId}/recommendations/generate", privatePlanId)
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.generatedEntries", hasSize(1)))
            .andExpect(jsonPath("$.generatedEntries[0].recipeId", is(testRecipeId)))
            .andExpect(jsonPath("$.generatedEntries[0].source", is("RECOMMENDED")))
            .andExpect(jsonPath("$.skippedDates").isEmpty())
            .andExpect(jsonPath("$.generatedEntries[0].recipe.title", is("Hummus Bowl")));

        List<MealPlanEntry> entries = mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateBetweenOrderByEntryDateAscMealTimeAsc(
            privatePlanId, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 1));
        org.junit.jupiter.api.Assertions.assertEquals(1, entries.size());
        org.junit.jupiter.api.Assertions.assertTrue(signalRepository.findByEntryId(entries.get(0).getEntryId()).isPresent());
    }

    @Test
    void generate_skipsSlotWithExistingManualEntry() throws Exception {
        MealPlan plan = mealPlanRepository.findById(privatePlanId).orElseThrow();
        MealPlanEntry manual = new MealPlanEntry();
        manual.setPlan(plan);
        manual.setRecipeId(testRecipeId);
        manual.setEntryDate(LocalDate.of(2026, 10, 1));
        manual.setMealSlot(MealSlot.DINNER);
        manual.setMealTime(LocalTime.of(19, 0));
        manual.setSource(MealPlanEntrySource.MANUAL);
        manual.setAddedBy(testUserId);
        mealPlanEntryRepository.save(manual);

        String body = "{\"startDate\":\"2026-10-01\",\"endDate\":\"2026-10-01\",\"mealSlots\":[\"DINNER\"],"
            + "\"slotTimes\":{\"DINNER\":\"18:00:00\"},\"overwriteRecommended\":false}";

        mockMvc.perform(post("/api/meal-plans/{planId}/recommendations/generate", privatePlanId)
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.generatedEntries").isEmpty())
            .andExpect(jsonPath("$.skippedDates[0].reason", is("MANUAL_ENTRY_PRESENT")));
    }

    @Test
    void addEntryFromRecommendation_realFlow_createsEntryAndSignal() throws Exception {
        String body = "{\"recipeId\":" + testRecipeId + ",\"entryDate\":\"2026-10-01\",\"mealSlot\":\"DINNER\",\"mealTime\":\"18:00:00\","
            + "\"cuisineType\":\"MEDITERRANEAN\",\"scoreBreakdown\":{\"pantryMatch\":0.9,\"cuisine\":0.8,\"nutrition\":0.5,\"freshness\":0.3,\"novelty\":1.0}}";

        mockMvc.perform(post("/api/meal-plans/{planId}/entries/from-recommendation", privatePlanId)
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recipeId", is(testRecipeId)))
            .andExpect(jsonPath("$.source", is("RECOMMENDED")))
            .andExpect(jsonPath("$.recipe.title", is("Hummus Bowl")));

        List<MealPlanEntry> entries = mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateBetweenOrderByEntryDateAscMealTimeAsc(
            privatePlanId, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 1));
        org.junit.jupiter.api.Assertions.assertEquals(1, entries.size());
        org.junit.jupiter.api.Assertions.assertTrue(signalRepository.findByEntryId(entries.get(0).getEntryId()).isPresent());
    }

    @Test
    void addEntryFromRecommendation_returns409_whenSlotAlreadyOccupied() throws Exception {
        MealPlan plan = mealPlanRepository.findById(privatePlanId).orElseThrow();
        MealPlanEntry existing = new MealPlanEntry();
        existing.setPlan(plan);
        existing.setRecipeId(testRecipeId);
        existing.setEntryDate(LocalDate.of(2026, 10, 1));
        existing.setMealSlot(MealSlot.DINNER);
        existing.setMealTime(LocalTime.of(18, 0));
        existing.setSource(MealPlanEntrySource.MANUAL);
        existing.setAddedBy(testUserId);
        mealPlanEntryRepository.save(existing);

        String body = "{\"recipeId\":" + testRecipeId + ",\"entryDate\":\"2026-10-01\",\"mealSlot\":\"DINNER\",\"mealTime\":\"18:00:00\","
            + "\"cuisineType\":\"MEDITERRANEAN\",\"scoreBreakdown\":{\"pantryMatch\":0.9,\"cuisine\":0.8,\"nutrition\":0.5,\"freshness\":0.3,\"novelty\":1.0}}";

        mockMvc.perform(post("/api/meal-plans/{planId}/entries/from-recommendation", privatePlanId)
                .with(authentication(authAsTestUser()))
                .contentType(MediaType.APPLICATION_JSON)
                .content(body))
            .andExpect(status().isConflict());
    }
}