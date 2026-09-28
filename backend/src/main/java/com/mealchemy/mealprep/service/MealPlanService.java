package com.mealchemy.mealprep.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.stream.Collectors;

/* Import classes */
import com.mealchemy.mealprep.dto.MealPlanResponse;
import com.mealchemy.mealprep.dto.MealPlanEntryRequest;
import com.mealchemy.mealprep.dto.MealPlanEntryResponse;
import com.mealchemy.mealprep.model.MealPlan;
import com.mealchemy.mealprep.model.MealPlanEntry;
import com.mealchemy.mealprep.repository.MealPlanRepository;
import com.mealchemy.mealprep.repository.MealPlanEntryRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.mealprep.exception.InvalidMealSlotTimeException;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.MealPlanEntrySource;
import com.mealchemy.shared.enums.VaultMemberRole;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;

@Service
public class MealPlanService
{
    private final MealPlanRepository mealPlanRepository;
    private final MealPlanEntryRepository mealPlanEntryRepository;
    private final VaultRepository vaultRepository; 
    private final VaultMemberRepository vaultMemberRepository; 
    private final MealPlanLearningSignalService mealPlanLearningSignalService;
    private final RecipeRepository recipeRepository;
    private final VaultFolderRecipeRepository vaultFolderRecipeRepository;

    public MealPlanService(MealPlanRepository mealPlanRepository, MealPlanEntryRepository mealPlanEntryRepository, VaultRepository vaultRepository, 
                        VaultMemberRepository vaultMemberRepository, MealPlanLearningSignalService mealPlanLearningSignalService, RecipeRepository recipeRepository,
                        VaultFolderRecipeRepository vaultFolderRecipeRepository)
    {
        this.mealPlanRepository = mealPlanRepository;
        this.mealPlanEntryRepository = mealPlanEntryRepository;
        this.vaultRepository = vaultRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.mealPlanLearningSignalService = mealPlanLearningSignalService;
        this.recipeRepository = recipeRepository;
        this.vaultFolderRecipeRepository = vaultFolderRecipeRepository;
    }

    // Get or create plan
    public MealPlanResponse getOrCreatePlan(Integer vaultId, Integer userId)
    {
        // find vault for meal plan
        Vault vault = findVaultOrThrow(vaultId);

        // all mebers can view the plan
        isOwnerOrMember(vault, userId);

        // find meal plan if exists
        MealPlan plan = mealPlanRepository.findByVaultId(vaultId).orElse(null);

        // no plan was found therefor create plan 
        if (plan == null)
        {
            MealPlan newPlan = new MealPlan();
            newPlan.setVaultId(vaultId);
            newPlan.setCreatedBy(userId);

            MealPlan saved = mealPlanRepository.save(newPlan);

            return MealPlanResponse.from(saved);
        }

        return MealPlanResponse.from(plan);
    }

    // Get meal plan entries
    public List<MealPlanEntryResponse> getEntries(Integer planId, Integer userId, LocalDate startDate, LocalDate endDate)
    {
        MealPlan plan = findPlanOrThrow(planId);

        Vault vault = findVaultOrThrow(plan.getVaultId());

        // all vault members can access
        isOwnerOrMember(vault, userId);

        // get list of entres
        List<MealPlanEntry> entries = mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateBetweenOrderByEntryDateAscMealTimeAsc(planId, startDate, endDate);

        return toResponses(entries);
    }

    // add entry 
    public MealPlanEntryResponse addEntry(Integer planId, Integer userId, LocalDate date, LocalTime mealTime, MealSlot mealSlot, String title, String note, Integer recipeId, MealPlanEntrySource source, boolean overwrite)
    {
        MealPlan plan = findPlanOrThrow(planId);
        Vault vault = findVaultOrThrow(plan.getVaultId());

        // only owner or editor can add entries
        isOwnerOrEditor(vault, userId);

        // validate mealtime against meal slots
        if (!mealSlot.allows(mealTime))
        {
            throw new InvalidMealSlotTimeException("mealTime " + mealTime + " is outside the valid range for " + mealSlot + ".");
        }

        assertRecipeAccessible(userId, recipeId);

        Optional<MealPlanEntry> existing = mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(planId, date, mealSlot);

        if (existing.isPresent())
        {
            // don't want to overwrite recommended
            if (!overwrite)
            {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "An entry already exists for " + date + " " + mealSlot + ".");
            }

            // overwrite is true therefor delete current and add replace with new
            mealPlanEntryRepository.delete(existing.get());
        }

        MealPlanEntry entry = new MealPlanEntry();
        entry.setPlan(plan);
        entry.setRecipeId(recipeId);
        entry.setEntryDate(date);
        entry.setMealSlot(mealSlot);
        entry.setMealTime(mealTime);
        entry.setTitle(title);
        entry.setNote(note);
        entry.setSource(source);
        entry.setAddedBy(userId);

        MealPlanEntry saved = mealPlanEntryRepository.save(entry);

        return toResponse(saved);
    }

    // create manual entry
    public MealPlanEntryResponse createManualEntry(Integer planId, Integer userId, MealPlanEntryRequest request)
    {
        // call addEntry above
        return addEntry(planId, userId, request.entryDate(), request.mealTime(), request.mealSlot(), request.title(), request.note(), request.recipeId(), MealPlanEntrySource.MANUAL, false);
    }

    // update entry 
    public MealPlanEntryResponse updateEntry(Integer planId, Integer entryId, Integer userId, MealPlanEntryRequest request)
    {
        MealPlan plan = findPlanOrThrow(planId);

        Vault vault = findVaultOrThrow(plan.getVaultId());

        // only owner or editor can add entries
        isOwnerOrEditor(vault, userId);

        // getting entry
        MealPlanEntry entry = mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(entryId, planId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan entry not found."));

        // validate mealtime against meal slots
        if (!request.mealSlot().allows(request.mealTime()))
        {
            throw new InvalidMealSlotTimeException("mealTime " + request.mealTime() + " is outside the valid range for " + request.mealSlot() + ".");
        }

        if (!request.recipeId().equals(entry.getRecipeId()))
        {
            assertRecipeAccessible(userId, request.recipeId());
        }

        // if there is an aleady existing meal at this time
        Optional<MealPlanEntry> existing = mealPlanEntryRepository.findByPlan_PlanIdAndEntryDateAndMealSlot(planId, request.entryDate(), request.mealSlot());

        if (existing.isPresent() && !existing.get().getEntryId().equals(entryId)) // not the same entry
        {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An entry already exists for " + request.entryDate() + " " + request.mealSlot() + ".");   
        }

        // fire skipped before update commits
        if (entry.getSource() == MealPlanEntrySource.RECOMMENDED)
        {
            mealPlanLearningSignalService.recordSkippedIfRecommended(entryId);
        }

        entry.setRecipeId(request.recipeId());
        entry.setEntryDate(request.entryDate());
        entry.setMealSlot(request.mealSlot());
        entry.setMealTime(request.mealTime());
        entry.setSource(MealPlanEntrySource.MANUAL);
        entry.setNote(request.note());
        entry.setTitle(request.title());

        MealPlanEntry saved = mealPlanEntryRepository.save(entry);

        return toResponse(saved);
    }

    // remove entry
    public void removeEntry(Integer planId, Integer entryId, Integer userId)
    {
        MealPlan plan = findPlanOrThrow(planId);

        Vault vault = findVaultOrThrow(plan.getVaultId());

        // only owner or editor can add entries
        isOwnerOrEditor(vault, userId);

        // getting entry
        MealPlanEntry entry = mealPlanEntryRepository.findByEntryIdAndPlan_PlanId(entryId, planId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan entry not found."));

        if (entry.getSource() == MealPlanEntrySource.RECOMMENDED)
        {
            mealPlanLearningSignalService.recordSkippedIfRecommended(entryId);
        }

        mealPlanEntryRepository.delete(entry);
    }


    // ========== Helpers ==========

    private MealPlan findPlanOrThrow(Integer planId)
    {
        MealPlan plan = mealPlanRepository.findById(planId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Meal plan not found."));

        return plan;
    }

    private Vault findVaultOrThrow(Integer vaultId)
    {
        Vault vault = vaultRepository.findById(vaultId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        return vault;
    }

    private void isOwnerOrMember(Vault vault, Integer userId)
    {
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);

        boolean isOwner = vault.getOwnerId().equals(userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found.");
        }
    }

    private void isOwnerOrEditor(Vault vault, Integer userId) 
    {
        boolean isOwner = vault.getOwnerId().equals(userId);

        if (isOwner)
        {
            return;
        }

        // owner returns above because owner doesn't have a role in vaultMember
        VaultMember member = vaultMemberRepository.findByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner/editor can modify the meal plan."));
        
        boolean isEditor = member.getRole().equals(VaultMemberRole.EDITOR);

        if (!isEditor)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner/editor can modify the meal plan.");
        }
    }

    private MealPlanEntryResponse toResponse(MealPlanEntry entry)
    {
        Recipe recipe = recipeRepository.findById(entry.getRecipeId()).orElse(null);
        return MealPlanEntryResponse.from(entry, recipe != null ? RecipeResponse.from(recipe) : null);
    }
    

    private List<MealPlanEntryResponse> toResponses(List<MealPlanEntry> entries)
    {
        List<Integer> recipeIds = entries.stream().map(MealPlanEntry::getRecipeId).distinct().toList();
        Map<Integer, Recipe> recipeById = recipeRepository.findAllById(recipeIds).stream()
            .collect(Collectors.toMap(Recipe::getRecipeId, r -> r));

        return entries.stream()
            .map(e -> {
                Recipe r = recipeById.get(e.getRecipeId());
                return MealPlanEntryResponse.from(e, r != null ? RecipeResponse.from(r) : null);
            })
            .toList();
    }

    private void assertRecipeAccessible(Integer userId, Integer recipeId)
    {
        Recipe recipe = recipeRepository.findById(recipeId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (recipe.getOwnerId().equals(userId) || Boolean.TRUE.equals(recipe.getIsCommunityPublished()))
        {
            return;
        }

        for (VaultFolderRecipe placement : vaultFolderRecipeRepository.findByRecipe_RecipeId(recipeId))
        {
            Vault placedIn = placement.getFolder().getVault();
            if (placedIn.getOwnerId().equals(userId)
                || vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(placedIn.getVaultId(), userId))
            {
                return;
            }
        }

        throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.");
    }
}