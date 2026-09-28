package com.mealchemy.mealprep.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.http.ResponseEntity;
import jakarta.validation.Valid;
import java.time.LocalDate;

/* Import classes */
import com.mealchemy.mealprep.service.MealPlanRecommendationService;
import com.mealchemy.mealprep.dto.DayRecommendationRequest;
import com.mealchemy.mealprep.dto.DayRecommendationResponse;
import com.mealchemy.mealprep.dto.GenerateRecommendationsRequest;
import com.mealchemy.mealprep.dto.GenerateRecommendationsResponse;
import com.mealchemy.mealprep.dto.MealPlanEntryFromRecommendationRequest;
import com.mealchemy.mealprep.dto.MealPlanEntryResponse;

/* Swagger */
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/meal-plans/{planId}")
@Tag(name = "Meal Plan Recommendations", description = "Engine-backed recommendations for meal plan slots; day preview, bulk generate, and committing a previewed pick")
public class MealPlanRecommendationController {

    private final MealPlanRecommendationService mealPlanRecommendationService;

    public MealPlanRecommendationController(MealPlanRecommendationService mealPlanRecommendationService)
    {
        this.mealPlanRecommendationService = mealPlanRecommendationService;
    }

    @Operation(summary = "Preview recommendations for a single day/slot", description = "Returns engine recommendations for one meal slot on one date, scored against a pantry projected forward from every earlier entry in the plan. Preview only.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recommendations retrieved successfully", content = @Content(schema = @Schema(implementation = DayRecommendationResponse.class))),
        @ApiResponse(responseCode = "400", description = "Invalid count, or another validation failure on the request", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Recommendation-based meal planning is only available for private vaults", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Meal plan not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/days/{date}/recommendations")
    public ResponseEntity<DayRecommendationResponse> getDayRecommendations(
        @AuthenticationPrincipal String userId,
        @PathVariable Integer planId,
        @PathVariable LocalDate date,
        @Valid @RequestBody DayRecommendationRequest request)
    {
        return ResponseEntity.ok(mealPlanRecommendationService.getDayRecommendations(Integer.parseInt(userId), planId, date, request));
    }

    @Operation(summary = "Generate recommendations across a date range", description = "Auto-fills every requested meal slot across a date range with an engine recommendation, projecting the pantry forward one date at a time. Manual entries are never overwritten. Previously-recommended entries are left as-is unless overwriteRecommended is true.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recommendations generated successfully", content = @Content(schema = @Schema(implementation = GenerateRecommendationsResponse.class))),
        @ApiResponse(responseCode = "400", description = "startDate after endDate, a slotTime missing for a requested mealSlot, or a slotTime outside that mealSlot's valid range", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Recommendation-based meal planning is only available for private vaults", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Meal plan not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/recommendations/generate")
    public ResponseEntity<GenerateRecommendationsResponse> generate(
        @AuthenticationPrincipal String userId,
        @PathVariable Integer planId,
        @Valid @RequestBody GenerateRecommendationsRequest request)
    {
        return ResponseEntity.ok(mealPlanRecommendationService.generate(Integer.parseInt(userId), planId, request));
    }

    @Operation(summary = "Add an entry from a previewed recommendation", description = "Writes a meal plan entry from a recommendation the caller already retrieved via the day-preview endpoint, capturing its score breakdown for later learning-signal processing.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Entry created successfully", content = @Content(schema = @Schema(implementation = MealPlanEntryResponse.class))),
        @ApiResponse(responseCode = "400", description = "mealTime is outside the valid range for the given mealSlot", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "Recommendation-based meal planning is only available for private vaults, or caller cannot modify this plan", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Meal plan not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "An entry already exists for that date and meal slot", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/entries/from-recommendation")
    public ResponseEntity<MealPlanEntryResponse> addEntryFromRecommendation(
        @AuthenticationPrincipal String userId,
        @PathVariable Integer planId,
        @Valid @RequestBody MealPlanEntryFromRecommendationRequest request)
    {
        return ResponseEntity.ok(mealPlanRecommendationService.addEntryFromRecommendation(planId, Integer.parseInt(userId), request));
    }
}