package com.mealchemy.engine.dto;

/* Import classes */

/* Import libraries */
import jakarta.validation.constraints.*;
import java.util.*;
import com.fasterxml.jackson.annotation.JsonProperty;

public record RecommendationRequest(
    @JsonProperty("user_state") @NotNull UserStateRequest userState,
    @JsonProperty("candidate_pool") @NotNull List<CandidatePoolEntryRequest> candidatePool,
    @JsonProperty("batch_size") Integer batchSize,
    @JsonProperty("exclude_recipe_ids") List<Integer> excludeRecipeIds,
    Integer seed
)
{}
