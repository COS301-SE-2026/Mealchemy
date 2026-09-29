package com.mealchemy.mealprep.service;

import com.mealchemy.engine.dto.EnrichedRecommendationItem;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;
import com.mealchemy.engine.dto.PantryEntryRequest;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.mealprep.dto.*;
import com.mealchemy.mealprep.model.MealPlan;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.model.MealPlanRecommendationSignal;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.mealprep.repository.MealPlanRecommendationSignalRepository;
import com.mealchemy.mealprep.repository.MealPlanRepository;
import com.mealchemy.preference.model.UserPreferences;
import com.mealchemy.preference.repository.UserPreferencesRepository;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class MealPlanRecommendationServiceTest {

    private static final Integer USER_ID = 1;
    private static final Integer PLAN_ID = 10;
    private static final Integer VAULT_ID = 20;
    private static final Integer RECIPE_ID = 100;

    @Mock private RecommendationService recommendationService;
    @Mock private PantryProjectionService pantryProjectionService;
    @Mock private UserPreferencesRepository userPreferencesRepository;
    @Mock private MealPlanRepository mealPlanRepository;
    @Mock private VaultRepository vaultRepository;
    @Mock private MealPlanService mealPlanService;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private MealPlanRecommendationSignalRepository signalRepository;

    @InjectMocks
    private MealPlanRecommendationService mealPlanRecommendationService;

    private MealPlan plan;
    private Vault privateVault;
    private UserPreferences preferences;

    @BeforeEach
    void setUp() {
        plan = new MealPlan();
        ReflectionTestUtils.setField(plan, "vaultId", VAULT_ID);

        privateVault = new Vault();
        ReflectionTestUtils.setField(privateVault, "vaultId", VAULT_ID);
        privateVault.setVaultType(VaultType.PRIVATE);

        preferences = new UserPreferences();
        preferences.setUserId(USER_ID);
        preferences.setNutritionalGoals(List.of());

        lenient().when(mealPlanRepository.findById(PLAN_ID)).thenReturn(Optional.of(plan));
        lenient().when(vaultRepository.findById(VAULT_ID)).thenReturn(Optional.of(privateVault));
        lenient().when(userPreferencesRepository.findByUserId(USER_ID)).thenReturn(Optional.of(preferences));
    }

    private EnrichedRecommendationItem pickFor(Integer recipeId) {
        RecipeResponse recipe = new RecipeResponse(recipeId, USER_ID, "Test Recipe", "desc", "ITALIAN",
            10, 10, 2, null, null, null, true, null, null, null);
        return new EnrichedRecommendationItem(recipeId, "ITALIAN", new BigDecimal("0.8"),
            new SignalScoresResponse(0.5, 0.5, 0.5, 0.5, 0.5), 0, List.of(), List.of(), recipe);
    }

    // ========== Vault gate ==========

    @Test
    void getDayRecommendations_sharedVault_throwsForbidden() {
        // Arrange
        Vault sharedVault = new Vault();
        ReflectionTestUtils.setField(sharedVault, "vaultId", VAULT_ID);
        sharedVault.setVaultType(VaultType.SHARED);
        when(vaultRepository.findById(VAULT_ID)).thenReturn(Optional.of(sharedVault));

        // Act
        DayRecommendationRequest request = new DayRecommendationRequest(MealSlot.DINNER, 3, null);

        // Assert
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
            () -> mealPlanRecommendationService.getDayRecommendations(USER_ID, PLAN_ID, LocalDate.now(), request));
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
    }

    @Test
    void getDayRecommendations_planNotFound_throwsNotFound() {
        // Arrange
        when(mealPlanRepository.findById(PLAN_ID)).thenReturn(Optional.empty());

        // Act
        DayRecommendationRequest request = new DayRecommendationRequest(MealSlot.DINNER, 3, null);

        // Assert
        assertThrows(ResponseStatusException.class,
            () -> mealPlanRecommendationService.getDayRecommendations(USER_ID, PLAN_ID, LocalDate.now(), request));
    }

    // ========== getDayRecommendations ==========

    @Test
    void getDayRecommendations_invalidCount_throwsBadRequest() {
        // Arrange/Act
        DayRecommendationRequest request = new DayRecommendationRequest(MealSlot.DINNER, 0, null);

        // Assert
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
            () -> mealPlanRecommendationService.getDayRecommendations(USER_ID, PLAN_ID, LocalDate.now(), request));
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
    }

    @Test
    void getDayRecommendations_delegatesToRecommendationServiceWithProjectedPantry() {
        // Arrange
        List<PantryEntryRequest> projectedPantry = List.of();
        when(pantryProjectionService.buildProjectedPantry(eq(USER_ID), eq(PLAN_ID), any(LocalDate.class))).thenReturn(projectedPantry);

        // Act
        EnrichedRecommendationResponse engineResponse = new EnrichedRecommendationResponse(List.of(pickFor(RECIPE_ID)), Map.of(), 1, 1);
        when(recommendationService.getRecommendations(eq(USER_ID), eq(3), eq(List.of()), isNull(), eq(projectedPantry), isNull()))
            .thenReturn(engineResponse);

        // Assert
        DayRecommendationRequest request = new DayRecommendationRequest(MealSlot.DINNER, 3, null);
        DayRecommendationResponse response = mealPlanRecommendationService.getDayRecommendations(USER_ID, PLAN_ID, LocalDate.of(2026, 10, 1), request);

        assertEquals(1, response.recommendations().size());
        assertEquals(MealSlot.DINNER, response.mealSlot());
    }

    // ========== mapGoalsToRequiredTags ==========

    @Test
    void mapGoalsToRequiredTags_noGoals_returnsNull() {
        // Act/Assert
        assertNull(mealPlanRecommendationService.mapGoalsToRequiredTags(USER_ID));
    }

    @Test
    void mapGoalsToRequiredTags_mealPrepGoal_returnsMealPrepTag() {
        // Arrange
        preferences.setNutritionalGoals(List.of("MEAL_PREP"));
        
        // Act/Assert
        assertEquals(List.of("MEAL_PREP"), mealPlanRecommendationService.mapGoalsToRequiredTags(USER_ID));
    }

    // ========== generate ==========

    @Test
    void generate_startAfterEnd_throwsBadRequest() {
        // Arrange
        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            LocalDate.of(2026, 10, 5), LocalDate.of(2026, 10, 1),
            List.of(MealSlot.DINNER), Map.of(MealSlot.DINNER, LocalTime.of(18, 0)), false, null);

        // Act/Assert
        assertThrows(ResponseStatusException.class, () -> mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request));
    }

    @Test
    void generate_manualEntryPresent_addedToSkippedDates() {
        // Arrange
        LocalDate date = LocalDate.of(2026, 10, 1);
        MealSlot slot = MealSlot.DINNER;
        MealPlanEntry manual = new MealPlanEntry();
        manual.setSource(MealPlanEntrySource.MANUAL);

        when(pantryProjectionService.buildProjectedPantry(eq(USER_ID), eq(PLAN_ID), eq(date))).thenReturn(List.of());
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(PLAN_ID, date, slot)).thenReturn(Optional.of(manual));

        // Act
        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            date, date, List.of(slot), Map.of(slot, LocalTime.of(18, 0)), false, null);

        GenerateRecommendationsResponse response = mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request);

        // Assert
        assertTrue(response.generatedEntries().isEmpty());
        assertEquals(1, response.skippedDates().size());
        assertEquals(GenerateRecommendationsResponse.SkippedDate.Reason.MANUAL_ENTRY_PRESENT, response.skippedDates().get(0).reason());
        verifyNoInteractions(recommendationService);
    }

    @Test
    void generate_noCandidates_addedToSkippedDates() {
        // Arrange
        LocalDate date = LocalDate.of(2026, 10, 1);
        MealSlot slot = MealSlot.DINNER;

        when(pantryProjectionService.buildProjectedPantry(eq(USER_ID), eq(PLAN_ID), eq(date))).thenReturn(List.of());
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(PLAN_ID, date, slot)).thenReturn(Optional.empty());
        when(recommendationService.getRecommendations(eq(USER_ID), eq(1), eq(List.of()), isNull(), eq(List.of()), isNull()))
            .thenReturn(EnrichedRecommendationResponse.empty());

        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            date, date, List.of(slot), Map.of(slot, LocalTime.of(18, 0)), false, null);
                
        // Act
        GenerateRecommendationsResponse response = mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request);

        // Assert
        assertEquals(GenerateRecommendationsResponse.SkippedDate.Reason.NO_CANDIDATES_AFTER_PROJECTION, response.skippedDates().get(0).reason());
    }

    @Test
    void generate_happyPath_addsEntryAndPersistsSignal() {
        // Arrange
        LocalDate date = LocalDate.of(2026, 10, 1);
        MealSlot slot = MealSlot.DINNER;
        LocalTime slotTime = LocalTime.of(18, 0);

        when(pantryProjectionService.buildProjectedPantry(eq(USER_ID), eq(PLAN_ID), eq(date))).thenReturn(List.of());
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(PLAN_ID, date, slot)).thenReturn(Optional.empty());
        when(recommendationService.getRecommendations(eq(USER_ID), eq(1), eq(List.of()), isNull(), eq(List.of()), isNull()))
            .thenReturn(new EnrichedRecommendationResponse(List.of(pickFor(RECIPE_ID)), Map.of(), 1, 1));

        MealPlanEntryResponse entryResponse = new MealPlanEntryResponse(55, PLAN_ID, RECIPE_ID, date, slot, slotTime,
            null, null, MealPlanEntrySource.RECOMMENDED, USER_ID, null);
        when(mealPlanService.addEntry(PLAN_ID, USER_ID, date, slotTime, slot, null, null, RECIPE_ID, MealPlanEntrySource.RECOMMENDED, true))
            .thenReturn(entryResponse);

        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            date, date, List.of(slot), Map.of(slot, slotTime), false, null);

        // Act
        GenerateRecommendationsResponse response = mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request);

        // Assert
        assertEquals(1, response.generatedEntries().size());
        assertTrue(response.skippedDates().isEmpty());
        verify(signalRepository).save(any(MealPlanRecommendationSignal.class));
    }

    @Test
    void generate_overwriteRecommended_deletesOldSignalFirst() {
        // Arrange
        LocalDate date = LocalDate.of(2026, 10, 1);
        MealSlot slot = MealSlot.DINNER;
        LocalTime slotTime = LocalTime.of(18, 0);

        MealPlanEntry existingRecommended = new MealPlanEntry();
        existingRecommended.setSource(MealPlanEntrySource.RECOMMENDED);
        ReflectionTestUtils.setField(existingRecommended, "entryId", 999);

        MealPlanRecommendationSignal oldSignal = new MealPlanRecommendationSignal();

        when(pantryProjectionService.buildProjectedPantry(eq(USER_ID), eq(PLAN_ID), eq(date))).thenReturn(List.of());
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(PLAN_ID, date, slot)).thenReturn(Optional.of(existingRecommended));
        when(signalRepository.findByEntryId(999)).thenReturn(Optional.of(oldSignal));
        when(recommendationService.getRecommendations(eq(USER_ID), eq(1), eq(List.of()), isNull(), eq(List.of()), isNull()))
            .thenReturn(new EnrichedRecommendationResponse(List.of(pickFor(RECIPE_ID)), Map.of(), 1, 1));
        when(mealPlanService.addEntry(PLAN_ID, USER_ID, date, slotTime, slot, null, null, RECIPE_ID, MealPlanEntrySource.RECOMMENDED, true))
            .thenReturn(new MealPlanEntryResponse(1, PLAN_ID, RECIPE_ID, date, slot, slotTime, null, null, MealPlanEntrySource.RECOMMENDED, USER_ID, null));

        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            date, date, List.of(slot), Map.of(slot, slotTime), true, null);

        // Act
        mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request);

        // Assert
        verify(signalRepository).delete(oldSignal);
    }

    @Test
    void generate_recommendedEntryNoOverwrite_skippedSilently() {
        // Arrange
        LocalDate date = LocalDate.of(2026, 10, 1);
        MealSlot slot = MealSlot.DINNER;
        MealPlanEntry existingRecommended = new MealPlanEntry();
        existingRecommended.setSource(MealPlanEntrySource.RECOMMENDED);

        when(pantryProjectionService.buildProjectedPantry(eq(USER_ID), eq(PLAN_ID), eq(date))).thenReturn(List.of());
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(PLAN_ID, date, slot)).thenReturn(Optional.of(existingRecommended));

        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            date, date, List.of(slot), Map.of(slot, LocalTime.of(18, 0)), false, null);

        // Act
        GenerateRecommendationsResponse response = mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request);

        // Assert
        assertTrue(response.generatedEntries().isEmpty());
        assertTrue(response.skippedDates().isEmpty());
        verifyNoInteractions(recommendationService);
    }

    @Test
    void generate_missingSlotTime_throwsBadRequest() {
        // Arrange
        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            LocalDate.now(), LocalDate.now(), List.of(MealSlot.DINNER), Map.of(), false, null);

        // Act/Assert
        assertThrows(ResponseStatusException.class, () -> mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request));
    }

    @Test
    void generate_invalidSlotTime_throwsInvalidMealSlotTimeException() {
        // Arrange
        GenerateRecommendationsRequest request = new GenerateRecommendationsRequest(
            LocalDate.now(), LocalDate.now(), List.of(MealSlot.DINNER), Map.of(MealSlot.DINNER, LocalTime.of(3, 0)), false, null);

        // Act/Assert
        assertThrows(ResponseStatusException.class, () -> mealPlanRecommendationService.generate(USER_ID, PLAN_ID, request));
    }

    // ========== addEntryFromRecommendation ==========

    @Test
    void addEntryFromRecommendation_neverOverwrites() {
        // Arrange
        LocalDate date = LocalDate.of(2026, 10, 1);
        MealPlanEntryFromRecommendationRequest request = new MealPlanEntryFromRecommendationRequest(
            RECIPE_ID, date, MealSlot.DINNER, LocalTime.of(18, 0), null, null, "ITALIAN",
            new SignalScoresResponse(0.5, 0.5, 0.5, 0.5, 0.5));

        when(mealPlanService.addEntry(PLAN_ID, USER_ID, date, LocalTime.of(18, 0), MealSlot.DINNER, null, null, RECIPE_ID, MealPlanEntrySource.RECOMMENDED, false))
            .thenReturn(new MealPlanEntryResponse(1, PLAN_ID, RECIPE_ID, date, MealSlot.DINNER, LocalTime.of(18, 0), null, null, MealPlanEntrySource.RECOMMENDED, USER_ID, null));

        // Act
        mealPlanRecommendationService.addEntryFromRecommendation(PLAN_ID, USER_ID, request);

        // Assert
        verify(mealPlanService).addEntry(PLAN_ID, USER_ID, date, LocalTime.of(18, 0), MealSlot.DINNER, null, null, RECIPE_ID, MealPlanEntrySource.RECOMMENDED, false);
        verify(signalRepository).save(any(MealPlanRecommendationSignal.class));
    }
}