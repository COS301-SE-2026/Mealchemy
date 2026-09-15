package com.mealchemy.moderation.service;

//models
import com.mealchemy.moderation.model.FlaggedRecipe;
import com.mealchemy.moderation.model.FlagReasonOptions;
import com.mealchemy.recipe.model.Recipe;

//repositories
import com.mealchemy.moderation.repository.FlaggedRecipeRepository;
import com.mealchemy.moderation.repository.FlagReasonOptionsRepository;
import com.mealchemy.recipe.repository.RecipeRepository;

//dtos
import com.mealchemy.moderation.dto.FlaggedRecipeDetailResponse;
import com.mealchemy.moderation.dto.FlaggedRecipeResponse;
import com.mealchemy.moderation.dto.FlagRequest;
import com.mealchemy.recipe.dto.RecipeResponse;

//enums
import com.mealchemy.shared.enums.FlagStatus;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//for concurent saves
import org.springframework.dao.DataIntegrityViolationException;

import java.util.List;
import java.util.ArrayList;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class FlagService {

    private final FlaggedRecipeRepository flaggedRecipeRepository;
    private final FlagReasonOptionsRepository flagReasonOptionsRepository;
    private final RecipeRepository recipeRepository;
    private final AdminService adminService;

    //constructor
    public FlagService(FlaggedRecipeRepository flaggedRecipeRepository, FlagReasonOptionsRepository flagReasonOptionsRepository, RecipeRepository recipeRepository, AdminService adminService) {
        this.flaggedRecipeRepository = flaggedRecipeRepository;
        this.flagReasonOptionsRepository = flagReasonOptionsRepository;
        this.recipeRepository = recipeRepository;
        this.adminService = adminService;
    }

    // ========== Helper function to build response ==========

    private FlaggedRecipeResponse toResponse(FlaggedRecipe flaggedRecipe) {
        Recipe recipe = recipeRepository.findById(flaggedRecipe.getRecipeId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Recipe referrenced by flag no longer exists."));

        FlagReasonOptions reasonOption = flagReasonOptionsRepository.findByValue(flaggedRecipe.getReason())
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Flag reason value is no longer valid."));

        return new FlaggedRecipeResponse(
                flaggedRecipe.getFlaggedId(),
                flaggedRecipe.getRecipeId(),
                recipe.getTitle(),
                recipe.getPhotoUrl(),
                flaggedRecipe.getFlaggedByUserId(),
                reasonOption.getValue(),
                reasonOption.getLabel(),
                flaggedRecipe.getStatus(),
                flaggedRecipe.getFlaggedAt()
        );
    }


    // ========== Admin facing ==========

    // GET - get all recipes with the specific status flag (default to PENDING is status is empty)
    public List<FlaggedRecipeResponse> getFlags(FlagStatus status) {
        if (status == null) {
            status = FlagStatus.PENDING;
        }

        // finding all the recipes with the status
        List<FlaggedRecipe> flaggedRecipes = flaggedRecipeRepository.findByStatus(status);

        // resulting list to append to
        List<FlaggedRecipeResponse> result = new ArrayList<>();

        for (FlaggedRecipe flaggedRecipe : flaggedRecipes) {
            result.add(toResponse(flaggedRecipe));
        }

        return result;
    }


    // GET - detailed response of a specific flagged recipe
    public FlaggedRecipeDetailResponse getFlagDetail(Integer flaggedId) {
        // find flagged recipe
        FlaggedRecipe flaggedRecipe = flaggedRecipeRepository.findById(flaggedId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flag not found."));

        FlaggedRecipeResponse flagSummary = toResponse(flaggedRecipe);

        // actual recipe
        Recipe recipe = recipeRepository.findById(flaggedRecipe.getRecipeId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Recipe referenced by flag no longer exists."));

        // recipe response 
        RecipeResponse recipeResponse = new RecipeResponse(
            recipe.getRecipeId(),
            recipe.getOwnerId(),
            recipe.getTitle(),
            recipe.getDescription(),
            recipe.getCuisineType(),
            recipe.getPrepTimeMins(),
            recipe.getServingSize(),
            recipe.getPhotoUrl(),
            recipe.getVideoUrl(),
            recipe.getExternalUrl(),
            recipe.getIsCommunityPublished(),
            recipe.getCreatedAt(),
            recipe.getUpdatedAt(),
            recipe.getParentRecipeId()
        );

        // build detailed response
        return new FlaggedRecipeDetailResponse(
                flagSummary.flaggedId(),
                flagSummary.recipeId(),
                flagSummary.recipeTitle(),
                flagSummary.recipePhotoUrl(),
                flagSummary.flaggedByUserId(),
                flagSummary.reasonValue(),
                flagSummary.reasonLabel(),
                flagSummary.status(),
                flagSummary.flaggedAt(),
                recipeResponse
            );
    }

    // PUT - dismiss flag (recipe is fine to stay in the global vault)
    @Transactional
    public FlaggedRecipeResponse dismissFlag(Integer flaggedId, Integer adminUserId) {
        // verify admin
        adminService.requireAdmin(adminUserId);

        FlaggedRecipe flaggedRecipe = flaggedRecipeRepository.findById(flaggedId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flag not found."));

        // find all flags for this specific recipe that have the same reason as the flag you are dealing with - therefore reslove all at the same time
        List<FlaggedRecipe> sameRecipeAndReason = flaggedRecipeRepository.findByRecipeIdAndReasonAndStatus(flaggedRecipe.getRecipeId(), flaggedRecipe.getReason(), FlagStatus.PENDING);

        sameRecipeAndReason.forEach(f -> f.setStatus(FlagStatus.REVIEWED));
        flaggedRecipeRepository.saveAll(sameRecipeAndReason);

        return toResponse(flaggedRecipe);
    }

    // PUT - remove flagged recipe from global vault (Updates recipe's isCommunity published to false)
    @Transactional
    public FlaggedRecipeResponse removeFlaggedRecipe(Integer flaggedId, Integer adminUserId) {
        // verify admin
        adminService.requireAdmin(adminUserId);

        FlaggedRecipe flaggedRecipe = flaggedRecipeRepository.findById(flaggedId)
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Flag not found."));

        Recipe recipeToRemove = recipeRepository.findById(flaggedRecipe.getRecipeId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Recipe referrenced by flag no longer exists."));

        recipeToRemove.setIsCommunityPublished(false);

        // find all flags for this specific recipe that have the same reason as the flag you are dealing with - therefore reslove all at the same time
        List<FlaggedRecipe> sameRecipeAndReason = flaggedRecipeRepository.findByRecipeIdAndReasonAndStatus(flaggedRecipe.getRecipeId(), flaggedRecipe.getReason(), FlagStatus.PENDING);

        sameRecipeAndReason.forEach(f -> f.setStatus(FlagStatus.REMOVED));
        flaggedRecipeRepository.saveAll(sameRecipeAndReason);

        return toResponse(flaggedRecipe);
    }


    // ========== User facing ==========

    // POST - creates a new flag for an existing recipe in the global vault
    @Transactional
    public FlaggedRecipeResponse createFlag(Integer recipeId, FlagRequest request, Integer userId) {
        // check if recipe exists
        Recipe recipe = recipeRepository.findById(recipeId).filter(Recipe::getIsCommunityPublished)
                                                           .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
        
        // check if request reason is valid
        if (!flagReasonOptionsRepository.existsByValue(request.reasonValue())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid reason value.");
        }

        // check duplicate pending - so user can't flag the same recip twice while it is still pending
        if (flaggedRecipeRepository.existsByRecipeIdAndUserIdAndStatus(recipeId, userId, FlagStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "You already have a pending flag on this recipe.");
        }


        // create flagged recipe
        FlaggedRecipe newFlaggedRecipe = new FlaggedRecipe();
        newFlaggedRecipe.setRecipeId(recipeId);
        newFlaggedRecipe.setFlaggedByUserId(userId);
        newFlaggedRecipe.setReason(request.reasonValue());
        newFlaggedRecipe.setStatus(FlagStatus.PENDING);

        // for concurrency - if flagged at same time
        try {
            flaggedRecipeRepository.save(newFlaggedRecipe);
        }
        catch (DataIntegrityViolationException e) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "You already have a pending flag on this recipe.");
        }

        return toResponse(newFlaggedRecipe);

    }

}
