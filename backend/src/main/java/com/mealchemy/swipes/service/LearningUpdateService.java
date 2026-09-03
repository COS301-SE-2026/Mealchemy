package com.mealchemy.swipes.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;
import java.math.BigDecimal;
import java.util.stream.Collectors;
import org.springframework.transaction.annotation.Propagation;

/* Import classes */
import com.mealchemy.preference.model.UserPreferenceWeights;
import com.mealchemy.preference.model.UserCuisineAffinities;
import com.mealchemy.engine.dto.SwipeUpdateDto;
import com.mealchemy.swipes.model.Swipe;
import com.mealchemy.engine.dto.PreferenceWeightsRequest;
import com.mealchemy.engine.dto.LearningUpdateResponse;
import com.mealchemy.engine.dto.LearningUpdateRequest;
import com.mealchemy.engine.dto.LearningUpdateResult;
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
import com.mealchemy.preference.repository.UserCuisineAffinitiesRepository;
import com.mealchemy.swipes.repository.SwipeRepository;
import com.mealchemy.engine.client.EngineClient;

@Service
public class LearningUpdateService {
    private final UserPreferenceWeightsRepository userPreferenceWeightsRepository;

    private final UserCuisineAffinitiesRepository userCuisineAffinitiesRepository;

    private final EngineClient engineClient;

    private final SwipeRepository swipeRepository;

    public LearningUpdateService(UserPreferenceWeightsRepository userPreferenceWeightsRepository, 
        UserCuisineAffinitiesRepository userCuisineAffinitiesRepository, EngineClient engineClient, SwipeRepository swipeRepository)
    {
        this.userPreferenceWeightsRepository = userPreferenceWeightsRepository;
        this.userCuisineAffinitiesRepository = userCuisineAffinitiesRepository;
        this.engineClient = engineClient;
        this.swipeRepository = swipeRepository;
    }

    @Transactional
    public LearningUpdateResult applyLearningUpdate(Integer userId, List<SwipeUpdateDto> swipes) {
        UserPreferenceWeights currentWeights = userPreferenceWeightsRepository.findByUserId(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Preference weights not found"));

        List<UserCuisineAffinities> currentAffinities = userCuisineAffinitiesRepository.findAllByUserId(userId);

        LearningUpdateResponse engineResponse = engineClient.updateLearning(
            buildLearningUpdateRequest(currentWeights, currentAffinities, swipes, currentWeights.getStateVersion())
        );

        int updatedRows = userPreferenceWeightsRepository.updateWeightsIfVersionMatches(
            userId,
            engineResponse.preferenceWeights().pantryMatch(),
            engineResponse.preferenceWeights().cuisine(),
            engineResponse.preferenceWeights().nutrition(),
            engineResponse.preferenceWeights().freshness(),
            engineResponse.preferenceWeights().novelty(),
            currentWeights.getStateVersion()
        );

        if (updatedRows == 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "state_version mismatch");
        }

        engineResponse.cuisineAffinities().forEach((cuisine, score) -> {
            UserCuisineAffinities affinity = userCuisineAffinitiesRepository
                .findByUserIdAndCuisineValue(userId, cuisine)
                .orElseGet(() -> {
                    UserCuisineAffinities fresh = new UserCuisineAffinities();
                    fresh.setUserId(userId);
                    fresh.setCuisineValue(cuisine);
                    return fresh;
                });
            affinity.setAffinityScore(score);
            userCuisineAffinitiesRepository.save(affinity);
        });

        return new LearningUpdateResult(currentWeights.getStateVersion() + 1, engineResponse.preferenceWeights(), engineResponse.cuisineAffinities());
    }

    private LearningUpdateRequest buildLearningUpdateRequest(UserPreferenceWeights currentWeights, List<UserCuisineAffinities> currentAffinities, 
        List<SwipeUpdateDto> swipes, Integer stateVersion)
    {
        PreferenceWeightsRequest weightsRequest = new PreferenceWeightsRequest(
            currentWeights.getPantryMatch(),
            currentWeights.getCuisine(),
            currentWeights.getNutrition(),
            currentWeights.getFreshness(),
            currentWeights.getNovelty()
        );

        Map<String, BigDecimal> affinitiesMap = currentAffinities.stream()
            .collect(Collectors.toMap(
                UserCuisineAffinities::getCuisineValue,
                UserCuisineAffinities::getAffinityScore
            ));

        return new LearningUpdateRequest(weightsRequest, affinitiesMap, swipes, stateVersion);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void flushSwipes(Integer userId) {
        List<Swipe> unflushedSwipes = swipeRepository.findByUserIdAndFlushedFalse(userId);

        if (unflushedSwipes.isEmpty()) {
            return;
        }

        List<SwipeUpdateDto> swipeDtos = unflushedSwipes.stream()
            .map(swipe -> new SwipeUpdateDto(
                swipe.getRecipeId(),
                swipe.getCuisineValue(),
                swipe.getAction(),
                swipe.getWeightsSnapshot(),
                null,
                swipe.getSwipedAt()
            ))
            .collect(Collectors.toList());

        applyLearningUpdate(userId, swipeDtos);

        unflushedSwipes.forEach(swipe -> swipe.setFlushed(true));
        swipeRepository.saveAll(unflushedSwipes);
    }
}
