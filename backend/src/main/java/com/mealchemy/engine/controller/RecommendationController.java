package com.mealchemy.engine.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;

/* Import classes */
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.engine.dto.RecommendationResponse;

@RestController
@RequestMapping("/discovery")
public class RecommendationController {
    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService)
    {
        this.recommendationService = recommendationService;
    }

    /* Mapping functions */

    // Get
    @GetMapping("/recommendations")
    public RecommendationResponse getRecommendations(@AuthenticationPrincipal String userId, 
    @RequestParam(required = false) Integer batchSize,
    @RequestParam(required = false) List<Integer> excludeRecipeIds,
    @RequestParam(required = false) Integer seed)
    {
        return recommendationService.getRecommendations(Integer.parseInt(userId), batchSize, excludeRecipeIds, seed);
    }
}
