package com.mealchemy.preference.service;
 
/* Import classes */
 
//models
import com.mealchemy.preference.model.UserPreferenceWeights;
//repositories
import com.mealchemy.preference.repository.UserPreferenceWeightsRepository;
//dtos
import com.mealchemy.preference.dto.UserPreferenceWeightsRequest;
import com.mealchemy.preference.dto.UserPreferenceWeightsResponse;
 
/* Import libraries */
 
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
 
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Arrays;

@Service
public class PreferenceWeightsService {
    private static final BigDecimal DEFAULT_PANTRY_MATCH = new BigDecimal("0.40");
    private static final BigDecimal DEFAULT_CUISINE = new BigDecimal("0.25");
    private static final BigDecimal DEFAULT_NUTRITION = new BigDecimal("0.10");
    private static final BigDecimal DEFAULT_FRESHNESS = new BigDecimal("0.15");
    private static final BigDecimal DEFAULT_NOVELTY = new BigDecimal("0.10");

    private static final BigDecimal SUM_TOLERANCE = new BigDecimal("0.001");
    private static final int SCALE = 4;

    private final UserPreferenceWeightsRepository userPreferenceWeightsRepository;
 
    public PreferenceWeightsService(UserPreferenceWeightsRepository userPreferenceWeightsRepository) {
        this.userPreferenceWeightsRepository = userPreferenceWeightsRepository;
    }

    // Get request for weights, creates defaults if not set
    public UserPreferenceWeightsResponse getWeights(Integer userId) {
        UserPreferenceWeights weights = userPreferenceWeightsRepository.findByUserId(userId)
                                        .orElseGet(() -> createDefaultWeights(userId));
 
        return toResponse(weights);
    }

    // Put upsert function for weights
    public UserPreferenceWeightsResponse updateWeights(Integer userId, UserPreferenceWeightsRequest request) {
        validate(request);
 
        UserPreferenceWeights weights = userPreferenceWeightsRepository.findByUserId(userId).orElse(null);
 
        if (weights == null) {
            weights = new UserPreferenceWeights();
            weights.setUserId(userId);
            weights.setStateVersion(0);
        } else {
            int currentVersion = weights.getStateVersion() == null ? 0 : weights.getStateVersion();
            weights.setStateVersion(currentVersion + 1);
        }
 
        weights.setPantryMatch(request.pantryMatch().setScale(SCALE, RoundingMode.HALF_UP));
        weights.setCuisine(request.cuisine().setScale(SCALE, RoundingMode.HALF_UP));
        weights.setNutrition(request.nutrition().setScale(SCALE, RoundingMode.HALF_UP));
        weights.setFreshness(request.freshness().setScale(SCALE, RoundingMode.HALF_UP));
        weights.setNovelty(request.novelty().setScale(SCALE, RoundingMode.HALF_UP));
 
        UserPreferenceWeights saved;
        try {
            saved = userPreferenceWeightsRepository.save(weights);
        } catch (DataIntegrityViolationException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Could not save weights, please retry");
        }
 
        return toResponse(saved);
    }

    /* Helper functions */

    private UserPreferenceWeights createDefaultWeights(Integer userId) {
        UserPreferenceWeights weights = new UserPreferenceWeights();
        weights.setUserId(userId);
        weights.setPantryMatch(DEFAULT_PANTRY_MATCH);
        weights.setCuisine(DEFAULT_CUISINE);
        weights.setNutrition(DEFAULT_NUTRITION);
        weights.setFreshness(DEFAULT_FRESHNESS);
        weights.setNovelty(DEFAULT_NOVELTY);
        weights.setStateVersion(0);
 
        try {
            return userPreferenceWeightsRepository.save(weights);
        } catch (DataIntegrityViolationException e) {
            return userPreferenceWeightsRepository.findByUserId(userId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Could not create default weights"));
        }
    }

    private void validate(UserPreferenceWeightsRequest request) {
        BigDecimal[] values = { request.pantryMatch(), request.cuisine(), request.nutrition(), request.freshness(), request.novelty() };
 
        if (Arrays.asList(values).contains(null)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "All five weights are required");
        }
 
        BigDecimal sum = BigDecimal.ZERO;
        for (BigDecimal value : values) {
            if (value.compareTo(BigDecimal.ZERO) < 0 || value.compareTo(BigDecimal.ONE) > 0) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Each weight must be between 0 and 1");
            }
            sum = sum.add(value);
        }
 
        if (sum.subtract(BigDecimal.ONE).abs().compareTo(SUM_TOLERANCE) > 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Weights must sum to 1.0 (within 0.001)");
        }
    }
 
    private UserPreferenceWeightsResponse toResponse(UserPreferenceWeights weights) {
        return new UserPreferenceWeightsResponse(
            weights.getPantryMatch(),
            weights.getCuisine(),
            weights.getNutrition(),
            weights.getFreshness(),
            weights.getNovelty()
        );
    }
}