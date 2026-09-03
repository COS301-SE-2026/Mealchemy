package com.mealchemy.engine.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;

/* Import classes */
import com.mealchemy.engine.service.RecommendationService;
import com.mealchemy.engine.dto.EnrichedRecommendationResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;


@RestController
@RequestMapping("/discovery")
@Tag(name = "Recommendations", description = "Personalised recipe recommendations from the discovery engine")
public class RecommendationController {
    private final RecommendationService recommendationService;

    public RecommendationController(RecommendationService recommendationService)
    {
        this.recommendationService = recommendationService;
    }

    /* Mapping functions */

    // Get
    @Operation(summary = "Get personalized recipe recommendations", description = "Builds the authenticated user's current state (preferences, pantry, swipe history, cuisine affinities) and candidate pool of community-published recipes, then requests a scored, ranked batch of recommendations from the discovery engine. If the candidate pool is empty, returns an empty response rather than an error.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recommendations retrieved successfully (may be empty if no candidates are available)", content = @Content(schema = @Schema(implementation = EnrichedRecommendationResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error, including user preferences/weights not initialized, or a failure communicating with the recommendation engine", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/recommendations")
    public EnrichedRecommendationResponse getRecommendations(@AuthenticationPrincipal String userId, 
    @RequestParam(required = false) Integer batchSize,
    @RequestParam(required = false) List<Integer> excludeRecipeIds,
    @RequestParam(required = false) Integer seed)
    {
        return recommendationService.getRecommendations(Integer.parseInt(userId), batchSize, excludeRecipeIds, seed);
    }
}
