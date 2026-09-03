package com.mealchemy.swipes.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.*;
import java.util.stream.Collectors;

/* Import classes */
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.engine.dto.SignalScoresResponse;
import com.mealchemy.swipes.dto.LikedRecipeItem;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.swipes.repository.SwipeRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.shared.enums.SwipeAction;

@Service
public class SwipeService {
    private final SwipeRepository swipeRepository;
    private final LearningUpdateService learningUpdateService;
    private final RecipeRepository recipeRepository;
    private static final Logger log = LoggerFactory.getLogger(SwipeService.class);
    private static final int BATCH_SIZE = 10;
    
    public SwipeService(SwipeRepository swipeRepository, LearningUpdateService learningUpdateService, RecipeRepository recipeRepository)
    {
        this.swipeRepository = swipeRepository;
        this.learningUpdateService = learningUpdateService;
        this.recipeRepository = recipeRepository;
    }

    @Transactional
    public Swipe recordSwipe(Integer userId, Integer recipeId, String cuisineValue, SwipeAction action, SignalScoresResponse signalScores)
    {
        Swipe swipe = new Swipe();
        swipe.setUserId(userId);
        swipe.setRecipeId(recipeId);
        swipe.setCuisineValue(cuisineValue);
        swipe.setAction(action);
        swipe.setWeightsSnapshot(signalScores);
        swipe.setFlushed(false);
        Swipe saved = swipeRepository.save(swipe);

        if (swipeRepository.countByUserIdAndFlushedFalse(userId) >= BATCH_SIZE) {
            try {
                learningUpdateService.flushSwipes(userId);
            } catch (Exception ex) {
                log.warn("Learning update flush failed for user {}, will retry on next batch trigger", userId, ex);
            }
        }

        return saved;
    }

    public List<LikedRecipeItem> getLikedRecipes(Integer userId)
    {
        List<Swipe> likedSwipes = swipeRepository.findByUserIdAndAction(userId, SwipeAction.LIKED);
 
        Map<Integer, Swipe> mostRecentByRecipeId = likedSwipes.stream()
            .collect(Collectors.toMap(
                Swipe::getRecipeId,
                s -> s,
                (existing, replacement) -> replacement.getSwipedAt().isAfter(existing.getSwipedAt()) ? replacement : existing
            ));
 
        List<Integer> recipeIds = mostRecentByRecipeId.keySet().stream().toList();
        Map<Integer, Recipe> recipeById = recipeRepository.findAllById(recipeIds).stream()
            .collect(Collectors.toMap(Recipe::getRecipeId, r -> r));
 
        return mostRecentByRecipeId.values().stream()
            .map(swipe -> {
                Recipe recipe = recipeById.get(swipe.getRecipeId());
                if (recipe == null) {
                    return null;
                }
                return new LikedRecipeItem(swipe.getRecipeId(), swipe.getCuisineValue(), swipe.getSwipedAt(), RecipeResponse.from(recipe));
            })
            .filter(Objects::nonNull)
            .sorted((a, b) -> b.likedAt().compareTo(a.likedAt()))
            .toList();
    }
}