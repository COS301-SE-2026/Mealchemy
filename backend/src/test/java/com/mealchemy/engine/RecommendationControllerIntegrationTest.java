package com.mealchemy.engine.integration;

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
import com.mealchemy.preference.model.UserCuisineAffinities;
import com.mealchemy.preference.repository.UserCuisineAffinitiesRepository;
import com.mealchemy.externallinks.repository.ExternalLinkRepository;

// engine client + dtos
import com.mealchemy.engine.client.EngineClient;
import com.mealchemy.engine.client.EmptyPoolException;
import com.mealchemy.engine.dto.RecommendationRequest;
import com.mealchemy.engine.dto.RecommendationResponse;
import com.mealchemy.engine.dto.RecommendationDto;
import com.mealchemy.engine.dto.SignalScoresResponse;

// shared
import com.mealchemy.shared.enums.StorageLocation;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.hamcrest.Matchers.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public class RecommendationControllerIntegrationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;

    @Autowired private UserRepository userRepository;
    @Autowired private RecipeRepository recipeRepository;
    @Autowired private RecipeTagsRepository recipeTagsRepository;
    @Autowired private TagsRepository tagsRepository;
    @Autowired private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Autowired private IngredientCategoryRepository ingredientCategoryRepository;
    @Autowired private PantryIngredientRepository pantryIngredientRepository;
    @Autowired private UserPreferencesRepository userPreferencesRepository;
    @Autowired private UserPreferenceWeightsRepository userPreferenceWeightsRepository;
    @Autowired private UserCuisineAffinitiesRepository userCuisineAffinitiesRepository;
    @Autowired private ExternalLinkRepository externalLinksRepository;

    @MockitoBean private EngineClient engineClient;

    private Integer testUserId;
    private Integer testRecipeId;

    @BeforeEach
    void setUp() {
        recipeTagsRepository.deleteAll();
        tagsRepository.deleteAll();
        pantryIngredientRepository.deleteAll();
        recipeRepository.deleteAll();
        userPreferencesRepository.deleteAll();
        userPreferenceWeightsRepository.deleteAll();
        userCuisineAffinitiesRepository.deleteAll();
        externalLinksRepository.deleteAll();
        userRepository.deleteAll();

        User user = new User();
        user.setEmail("rec-test-" + System.nanoTime() + "@example.com");
        user.setPasswordHash("dummy-hash");
        user.setRoles(List.of("USER"));
        user = userRepository.save(user);
        testUserId = user.getUserId();

        IngredientCategory category = ingredientCategoryRepository.findAll().stream()
            .filter(c -> "Legumes and Legume Products".equals(c.getCategoryName()))
            .findFirst()
            .orElseThrow(() -> new IllegalStateException("Seeded category not found"));

        IngredientCatalogue catalogue = ingredientCatalogueRepository.findAll().stream()
            .filter(i -> "Hummus, commercial".equals(i.getName()))
            .findFirst()
            .orElseThrow(() -> new IllegalStateException("Seeded ingredient not found"));

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

        Tags dietaryTag = new Tags();
        dietaryTag.setTagName("VEGAN");
        dietaryTag.setIsActive(true);
        dietaryTag.setIsDietary(true);
        dietaryTag = tagsRepository.save(dietaryTag);

        RecipeTags recipeTag = new RecipeTags();
        recipeTag.setRecipe(recipe);
        recipeTag.setTag(dietaryTag);
        recipeTagsRepository.save(recipeTag);

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

        UserCuisineAffinities affinities = new UserCuisineAffinities();
        affinities.setUserId(testUserId);
        affinities.setCuisineValue("ITALIAN");
        affinities.setAffinityScore(new BigDecimal("0.5"));
        userCuisineAffinitiesRepository.save(affinities);
    }

    private UsernamePasswordAuthenticationToken authAsTestUser() {
        return new UsernamePasswordAuthenticationToken(String.valueOf(testUserId), null, List.of());
    }

    @Test
    void getRecommendations_returns200_withEnrichedRecipeData() throws Exception {
        SignalScoresResponse scoreBreakdown = new SignalScoresResponse(0.9, 0.8, 0.5, 0.3, 1.0);
        RecommendationDto dto = RecommendationDto.from(
            testRecipeId, "MEDITERRANEAN", new BigDecimal("0.87"), scoreBreakdown, 1, List.of("parmesan")
        );
        when(engineClient.getRecommendations(any(RecommendationRequest.class)))
            .thenReturn(RecommendationResponse.from(List.of(dto), Map.of("MEDITERRANEAN", 1), 1, 1));

        mockMvc.perform(get("/discovery/recommendations").with(authentication(authAsTestUser())))
            .andExpect(status().isOk())
            .andDo(print())
            .andExpect(jsonPath("$.recommendations", hasSize(1)))
            .andExpect(jsonPath("$.recommendations[0].recipeId", is(testRecipeId)))
            .andExpect(jsonPath("$.recommendations[0].recipe.title", is("Hummus Bowl")))
            .andExpect(jsonPath("$.recommendations[0].missingIngredients[0]", is("parmesan")));
    }

    @Test
    void getRecommendations_returns200_withEmptyList_whenEnginePoolIsEmpty() throws Exception {
        when(engineClient.getRecommendations(any(RecommendationRequest.class)))
            .thenThrow(new EmptyPoolException("No recipes remain in the pool after hard-filtering."));

        mockMvc.perform(get("/discovery/recommendations").with(authentication(authAsTestUser())))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.recommendations").isEmpty())
            .andExpect(jsonPath("$.totalRecipesConsidered", is(0)));
    }

    @Test
    void getRecommendations_returns500_whenPreferencesNotInitialized() throws Exception {
        userPreferencesRepository.deleteAll();

        mockMvc.perform(get("/discovery/recommendations").with(authentication(authAsTestUser())))
            .andExpect(status().isInternalServerError())
            .andExpect(jsonPath("$.message", is("User preferences not initialized.")));
    }

    @Test
    void getRecommendations_realCandidatePoolReachesEngineClient_withCorrectCuisineAndTags() throws Exception {
        when(engineClient.getRecommendations(any(RecommendationRequest.class)))
            .thenAnswer(invocation -> {
                RecommendationRequest req = invocation.getArgument(0);
                assertEqualsCandidatePoolBuiltCorrectly(req);
                return RecommendationResponse.from(List.of(), Map.of(), 0, 1);
            });

        mockMvc.perform(get("/discovery/recommendations").with(authentication(authAsTestUser())))
            .andExpect(status().isOk());
    }

    private void assertEqualsCandidatePoolBuiltCorrectly(RecommendationRequest req) {
        var candidate = req.candidatePool().stream()
            .filter(c -> c.recipeId().equals(testRecipeId))
            .findFirst()
            .orElseThrow(() -> new AssertionError("Seeded recipe missing from real candidate pool"));

        org.junit.jupiter.api.Assertions.assertEquals("MEDITERRANEAN", candidate.cuisine());
        org.junit.jupiter.api.Assertions.assertEquals(List.of("VEGAN"), candidate.dietaryTags());
        org.junit.jupiter.api.Assertions.assertEquals(1, req.userState().pantry().size());
    }
}