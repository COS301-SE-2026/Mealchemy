
Preferenceweightsservice · JAVA
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
}