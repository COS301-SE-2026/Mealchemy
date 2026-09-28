// unit testing for MealPrepService

package com.mealchemy.mealprep;

// libraries 
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import org.mockito.ArgumentCaptor;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.never;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.inOrder;
import org.mockito.InOrder;
import static org.mockito.Mockito.lenient;

import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.Optional;

//dtos
import com.mealchemy.mealprep.dto.MealPlanRequest;
import com.mealchemy.mealprep.dto.MealPlanResponse;
import com.mealchemy.mealprep.dto.MealPlanEntryRequest;
import com.mealchemy.mealprep.dto.MealPlanEntryResponse;

// models
import com.mealchemy.mealprep.model.MealPlan;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.recipe.model.Recipe;

// repositories
import com.mealchemy.mealprep.repository.MealPlanRepository;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

// services
import com.mealchemy.mealprep.service.MealPlanService;
import com.mealchemy.mealprep.service.MealPlanLearningSignalService;

// enums
import com.mealchemy.shared.enums.VaultMemberRole;
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.MealSlot;

// exception
import com.mealchemy.mealprep.exception.InvalidMealSlotTimeException;

import java.time.LocalDate;
import java.time.LocalTime;


@ExtendWith(MockitoExtension.class)
public class MealPlanServiceTest {
    // @Mock - create fake version of dependency
    @Mock private MealPlanRepository mealPlanRepository;
    @Mock private MealPlanEntryRepository mealPlanEntryRepository;
    @Mock private VaultRepository vaultRepository;
    @Mock private VaultMemberRepository vaultMemberRepository;
    @Mock private VaultFolderRecipeRepository vaultFolderRecipeRepository;
    @Mock private MealPlanLearningSignalService mealPlanLearningSignalService;
    @Mock private RecipeRepository recipeRepository;
    
    @InjectMocks 
    private MealPlanService mealPlanService;

    private Vault vault;
    private VaultMember editorMembership;
    private VaultMember viewerMembership;
    private MealPlan plan;
    private MealPlanEntry recommendedEntry;
    private MealPlanEntry manualEntry; 

    @BeforeEach
    void setUp() {
        // vault owner be userId = 1
        vault = new Vault();
        vault.setOwnerId(1);
        ReflectionTestUtils.setField(vault, "vaultId", 10);

        // editor in shared vault
        editorMembership = new VaultMember();
        editorMembership.setRole(VaultMemberRole.EDITOR);

        // viewer in shared vault
        viewerMembership = new VaultMember();
        viewerMembership.setRole(VaultMemberRole.VIEWER);

        plan = new MealPlan();
        plan.setVaultId(10);
        plan.setCreatedBy(1);
        ReflectionTestUtils.setField(plan, "planId", 100);

        recommendedEntry = new MealPlanEntry();
        recommendedEntry.setPlan(plan);
        recommendedEntry.setRecipeId(50);
        recommendedEntry.setEntryDate(LocalDate.of(2026, 10, 1));
        recommendedEntry.setMealSlot(MealSlot.DINNER);
        recommendedEntry.setMealTime(LocalTime.of(18, 0));
        recommendedEntry.setSource(MealPlanEntrySource.RECOMMENDED);
        recommendedEntry.setAddedBy(1);
        ReflectionTestUtils.setField(recommendedEntry, "entryId", 20);

        manualEntry = new MealPlanEntry();
        manualEntry.setPlan(plan);
        manualEntry.setRecipeId(51);
        manualEntry.setEntryDate(LocalDate.of(2026, 10, 2));
        manualEntry.setMealSlot(MealSlot.LUNCH);
        manualEntry.setMealTime(LocalTime.of(12, 30));
        manualEntry.setSource(MealPlanEntrySource.MANUAL);
        manualEntry.setAddedBy(1);
        ReflectionTestUtils.setField(manualEntry, "entryId", 21);

        lenient().when(recipeRepository.findById(50)).thenReturn(Optional.of(recipe(50, 1, true)));
    }

    private Recipe recipe(int id, int ownerId, boolean published) {
        Recipe r = new Recipe();
        ReflectionTestUtils.setField(r, "recipeId", id);
        r.setOwnerId(ownerId);
        r.setTitle("Recipe " + id);
        r.setDescription("desc");
        r.setCuisineType("ITALIAN");
        r.setPrepTimeMins(10);
        r.setCookingTimeMins(10);
        r.setServingSize(2);
        r.setIsCommunityPublished(published);
        r.setIngredients(List.of());
        return r;
    }

    @Test
    void getOrCreatePlan_whenVaultNotFound_throwsNotFound() {
        // Arrange 
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.getOrCreatePlan(99, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void getOrCreatePlan_userNotOwnerOrMember_throwsNotFound() {
        // Arrange 
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(10, 99)).thenReturn(false);

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.getOrCreatePlan(10, 99)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void getOrCreatePlan_planDoesNotExistYet_createsAndReturns() {
        // Arrange 
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(10, 1)).thenReturn(true);
        when(mealPlanRepository.findByVaultId(10)).thenReturn(Optional.empty());
        
        MealPlan savedPlan = new MealPlan();
        savedPlan.setVaultId(10);
        savedPlan.setCreatedBy(1);
        ReflectionTestUtils.setField(savedPlan, "planId", 100);
        when(mealPlanRepository.save(any(MealPlan.class))).thenReturn(savedPlan);

        // Act
        MealPlanResponse  response = mealPlanService.getOrCreatePlan(10, 1);

        // Assert
        assertEquals(10, response.vaultId());
        assertEquals(1, response.createdBy());
        assertEquals(100, response.planId());
        verify(mealPlanRepository).save(any(MealPlan.class));
    }

    //get entires
    @Test
    void getEntries_planNotFound_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(5)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.getEntries(5, 1, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 7))
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void getEntries_includesRecipeDetails_andNullWhenRecipeMissing() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(10, 1)).thenReturn(true);
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateBetweenOrderByEntryDateAscMealTimeAsc(100, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 7)))
            .thenReturn(List.of(recommendedEntry, manualEntry));

        Recipe recipe = new Recipe();
        ReflectionTestUtils.setField(recipe, "recipeId", 50);
        recipe.setOwnerId(1);
        recipe.setTitle("Hummus Bowl");
        recipe.setDescription("A tasty bowl.");
        recipe.setCuisineType("MEDITERRANEAN");
        recipe.setPrepTimeMins(10);
        recipe.setCookingTimeMins(0);
        recipe.setServingSize(2);
        recipe.setIsCommunityPublished(true);
        recipe.setIngredients(List.of());
        when(recipeRepository.findAllById(any())).thenReturn(List.of(recipe));

        // Act
        List<MealPlanEntryResponse> response = mealPlanService.getEntries(100, 1, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 7));

        // Assert
        assertEquals("Hummus Bowl", response.get(0).recipe().title());
        assertNull(response.get(1).recipe());
    }

    @Test
    void getEntries_userNotOwnerOrMember_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(10, 99)).thenReturn(false);

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.getEntries(100, 99, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 7))
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void getEntries_planDoesNotExistYet_createsAndReturns() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(10, 1)).thenReturn(true);
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateBetweenOrderByEntryDateAscMealTimeAsc(100, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 7))).thenReturn(List.of(recommendedEntry, manualEntry));

        // Act
        List<MealPlanEntryResponse> response = mealPlanService.getEntries(100, 1, LocalDate.of(2026, 10, 1), LocalDate.of(2026, 10, 7));

        // Assert
        assertEquals(2, response.size());
        assertEquals(20, response.get(0).entryId());
        assertEquals(recommendedEntry.getRecipeId(), response.get(0).recipeId());
        assertEquals(MealSlot.DINNER, response.get(0).mealSlot());
        assertEquals(MealPlanEntrySource.RECOMMENDED, response.get(0).source());
    }

    // add entry
    @Test
    void addEntry_planNotFound_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, false)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void addEntry_userIsEditor_createsEntry() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultIdAndUser_UserId(10, 2)).thenReturn(Optional.of(editorMembership));
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 1), MealSlot.DINNER)).thenReturn(Optional.empty());

        ArgumentCaptor<MealPlanEntry> captor = ArgumentCaptor.forClass(MealPlanEntry.class);
        when(mealPlanEntryRepository.save(captor.capture())).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        mealPlanService.addEntry(100, 2, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, false);

        // Assert
        assertEquals(2, captor.getValue().getAddedBy());
    }

    @Test
    void addEntry_userNotAMember_throwsForbidden() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultIdAndUser_UserId(10, 99)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.addEntry(100, 99, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, false)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void addEntry_userIsViewer_throwsForbidden() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultIdAndUser_UserId(10, 3)).thenReturn(Optional.of(viewerMembership));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.addEntry(100, 3, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, false)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test 
    void addEntry_slotEmpty_createsEntry() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 1), MealSlot.DINNER)).thenReturn(Optional.empty());

        ArgumentCaptor<MealPlanEntry> captor = ArgumentCaptor.forClass(MealPlanEntry.class);
        when(mealPlanEntryRepository.save(captor.capture())).thenAnswer(invocation -> invocation.getArgument(0));

        // Act 
        MealPlanEntryResponse response = mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, false);

        // Assert
        MealPlanEntry saved = captor.getValue();
        assertEquals(50, saved.getRecipeId());
        assertEquals(MealSlot.DINNER, saved.getMealSlot());
        assertEquals(LocalTime.of(18, 0), saved.getMealTime());
        assertEquals("title", saved.getTitle());
        assertEquals(MealPlanEntrySource.MANUAL, saved.getSource());
        assertEquals(1, saved.getAddedBy());
        verify(mealPlanEntryRepository, never()).delete(any(MealPlanEntry.class));
    }

    @Test 
    void addEntry_slotOccupied_noOverwrite_throwsConflict() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 1), MealSlot.DINNER)).thenReturn(Optional.of(recommendedEntry));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, false)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).delete(any(MealPlanEntry.class));
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test 
    void addEntry_slotOccupied_withOverwrite_deleteOldSaveNew() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 1), MealSlot.DINNER)).thenReturn(Optional.of(recommendedEntry));
        when(mealPlanEntryRepository.save(any(MealPlanEntry.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "title", "note", 50, MealPlanEntrySource.MANUAL, true);

        // Assert
        verify(mealPlanEntryRepository).delete(recommendedEntry);
        verify(mealPlanEntryRepository).save(any(MealPlanEntry.class));
        verify(mealPlanLearningSignalService, never()).recordSkippedIfRecommended(any());
    }

    @Test
    void addEntry_recipeNotFound_throwsNotFound() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(recipeRepository.findById(999)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
            () -> mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "t", "n", 999, MealPlanEntrySource.MANUAL, false));

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void addEntry_recipeNotAccessible_throwsNotFound() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(recipeRepository.findById(77)).thenReturn(Optional.of(recipe(77, 99, false)));
        when(vaultFolderRecipeRepository.findByRecipe_RecipeId(77)).thenReturn(List.of());

        // Act
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
            () -> mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "t", "n", 77, MealPlanEntrySource.MANUAL, false));

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void addEntry_recipeInVaultUserBelongsTo_succeeds() {
        // Arrange
        Vault otherVault = new Vault();
        otherVault.setOwnerId(99);
        ReflectionTestUtils.setField(otherVault, "vaultId", 11);
        VaultFolder folder = new VaultFolder();
        folder.setVault(otherVault);
        VaultFolderRecipe placement = new VaultFolderRecipe();
        placement.setFolder(folder);

        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(recipeRepository.findById(78)).thenReturn(Optional.of(recipe(78, 99, false)));
        when(vaultFolderRecipeRepository.findByRecipe_RecipeId(78)).thenReturn(List.of(placement));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(11, 1)).thenReturn(true);
        when(mealPlanEntryRepository.save(any(MealPlanEntry.class))).thenAnswer(inv -> inv.getArgument(0));

        // Act
        mealPlanService.addEntry(100, 1, LocalDate.of(2026, 10, 1), LocalTime.of(18, 0), MealSlot.DINNER, "t", "n", 78, MealPlanEntrySource.MANUAL, false);

        // Assert
        verify(mealPlanEntryRepository).save(any(MealPlanEntry.class));
    }

    // create manual
    @Test
    void createManualEntry_savesAsManual() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 1), MealSlot.DINNER)).thenReturn(Optional.empty());

        ArgumentCaptor<MealPlanEntry> captor = ArgumentCaptor.forClass(MealPlanEntry.class);
        when(mealPlanEntryRepository.save(captor.capture())).thenAnswer(invocation -> invocation.getArgument(0));

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            50,
            LocalDate.of(2026, 10, 1),
            MealSlot.DINNER,
            LocalTime.of(18, 0),
            "title", 
            "note"
        );

        // Act 
        mealPlanService.createManualEntry(100, 1, request);

        // Assert
        MealPlanEntry saved = captor.getValue();
        assertEquals(MealPlanEntrySource.MANUAL, saved.getSource());
        assertEquals(1, saved.getAddedBy());
    }

    
    // update entry
    @Test
    void updateEntry_recommendedEntry_firesSkipSignalAndBecomesManual() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(20, 100)).thenReturn(Optional.of(recommendedEntry));
        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 3), MealSlot.DINNER)).thenReturn(Optional.empty());
        when(mealPlanEntryRepository.save(any(MealPlanEntry.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            60,
            LocalDate.of(2026, 10, 3),
            MealSlot.DINNER,
            LocalTime.of(19, 0),
            "new title",
            "new note"
        );

        // Act
        MealPlanEntryResponse response = mealPlanService.updateEntry(100, 20, 1, request);

        // Assert
        InOrder order = inOrder(mealPlanLearningSignalService, mealPlanEntryRepository);
        order.verify(mealPlanLearningSignalService).recordSkippedIfRecommended(20);
        order.verify(mealPlanEntryRepository).save(recommendedEntry);

        // Assert
        assertEquals(60, recommendedEntry.getRecipeId());
        assertEquals(LocalDate.of(2026, 10, 3), recommendedEntry.getEntryDate());
        assertEquals(LocalTime.of(19, 0), recommendedEntry.getMealTime());
        assertEquals("new title", recommendedEntry.getTitle());
        assertEquals("new note", recommendedEntry.getNote());
        assertEquals(MealPlanEntrySource.MANUAL, recommendedEntry.getSource());
        assertEquals(MealPlanEntrySource.MANUAL, response.source());
    }

    @Test
    void updateEntry_manualEntrySameSlot_noConflictAndNoSkipSignal() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(21, 100)).thenReturn(Optional.of(manualEntry));

        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 2), MealSlot.LUNCH)).thenReturn(Optional.of(manualEntry));
        when(mealPlanEntryRepository.save(any(MealPlanEntry.class))).thenAnswer(invocation -> invocation.getArgument(0));

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            51,
            LocalDate.of(2026, 10, 2),
            MealSlot.LUNCH,
            LocalTime.of(13, 0),
            "edited",
            "edited note"
        );

        // Act
        mealPlanService.updateEntry(100, 21, 1, request);

        // Assert
        assertEquals(LocalTime.of(13, 0), manualEntry.getMealTime());
        assertEquals("edited", manualEntry.getTitle());
        verify(mealPlanLearningSignalService, never()).recordSkippedIfRecommended(any());
        verify(mealPlanEntryRepository).save(manualEntry);
    }

    @Test
    void updateEntry_planNotFound_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.empty());

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            50,
            LocalDate.of(2026, 10, 1),
            MealSlot.DINNER,
            LocalTime.of(18, 0),
            "title", 
            "note"
        );

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.updateEntry(100, 50, 1, request)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updateEntry_userIsViewer_throwsForbidden() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultIdAndUser_UserId(10, 3)).thenReturn(Optional.of(viewerMembership));

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            50,
            LocalDate.of(2026, 10, 1),
            MealSlot.DINNER,
            LocalTime.of(18, 0),
            "title", 
            "note"
        );

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.updateEntry(100, 50, 3, request)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void updateEntry_entryNotFound_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(999, 100)).thenReturn(Optional.empty());

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            50,
            LocalDate.of(2026, 10, 1),
            MealSlot.DINNER,
            LocalTime.of(18, 0),
            "title", 
            "note"
        );

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.updateEntry(100, 999, 1, request)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updateEntry_invalidMealTime_throwsInvalidMealSlotException() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(20, 100)).thenReturn(Optional.of(recommendedEntry));

        // BREAKFAST 05:00-11:00
        MealPlanEntryRequest request = new MealPlanEntryRequest(
            50,
            LocalDate.of(2026, 10, 1),
            MealSlot.BREAKFAST,
            LocalTime.of(20, 0),
            "title", 
            "note"
        );

        // Act and Assert
        assertThrows(
            InvalidMealSlotTimeException.class, 
            () -> mealPlanService.updateEntry(100, 20, 1, request) 
        );

        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void updateEntry_collidesWithExistingEntry_throwsConflict() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(20, 100)).thenReturn(Optional.of(recommendedEntry));

        MealPlanEntryRequest request = new MealPlanEntryRequest(
            50,
            LocalDate.of(2026, 10, 2),
            MealSlot.LUNCH,
            LocalTime.of(12, 30),
            "title", 
            "note"
        );

        when(mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(100, LocalDate.of(2026, 10, 2), MealSlot.LUNCH)).thenReturn(Optional.of(manualEntry));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.updateEntry(100, 20, 1, request)
        );

        // Assert
        assertEquals(HttpStatus.CONFLICT, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
    }

    @Test
    void updateEntry_changedToInaccessibleRecipe_throwsNotFound() {
        // Arrange
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(20, 100)).thenReturn(Optional.of(recommendedEntry));
        when(recipeRepository.findById(77)).thenReturn(Optional.of(recipe(77, 99, false)));

        MealPlanEntryRequest request = new MealPlanEntryRequest(77, LocalDate.of(2026, 10, 1), MealSlot.DINNER, LocalTime.of(18, 0), "t", "n");

        // Act
        ResponseStatusException ex = assertThrows(ResponseStatusException.class,
            () -> mealPlanService.updateEntry(100, 20, 1, request));

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).save(any(MealPlanEntry.class));
        verify(mealPlanLearningSignalService, never()).recordSkippedIfRecommended(any());
    }

    // remove entry
    @Test
    void removeEntry_planNotFound_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.removeEntry(100, 20, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void removeEntry_userIsViewer_throwsForbidden() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultIdAndUser_UserId(10, 3)).thenReturn(Optional.of(viewerMembership));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.removeEntry(100, 50, 3)
        );

        // Assert
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        verify(mealPlanEntryRepository, never()).delete(any(MealPlanEntry.class));
    }

    @Test
    void removeEntry_entryNotFound_throwsNotFound() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(999, 100)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> mealPlanService.removeEntry(100, 999, 1)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void removeEntry_recommendedEntry_firesSkipSignalBeforeDelete() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(20, 100)).thenReturn(Optional.of(recommendedEntry));

        // Act
        mealPlanService.removeEntry(100, 20, 1);

        // Assert
        InOrder order = inOrder(mealPlanLearningSignalService, mealPlanEntryRepository);
        order.verify(mealPlanLearningSignalService).recordSkippedIfRecommended(20);
        order.verify(mealPlanEntryRepository).delete(recommendedEntry);
    }

    @Test
    void removeEntry_manualEntry_doesNotFireSkipSignal() {
        // Arrange 
        when(mealPlanRepository.findById(100)).thenReturn(Optional.of(plan));
        when(vaultRepository.findById(10)).thenReturn(Optional.of(vault));
        when(mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(21, 100)).thenReturn(Optional.of(manualEntry));

        // Act
        mealPlanService.removeEntry(100, 21, 1);

        // Assert
        verify(mealPlanLearningSignalService, never()).recordSkippedIfRecommended(any());
        verify(mealPlanEntryRepository).delete(manualEntry);
    }
}