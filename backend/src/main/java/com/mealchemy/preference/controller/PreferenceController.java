package com.mealchemy.preference.controller;

// import dtos
import com.mealchemy.preference.dto.*;
// import services
import com.mealchemy.preference.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// swagger 
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;


@RestController
@RequestMapping("/user/preferences") 
@Tag(name = "User Preferences", description = "The authenticated user's dietary preferences, restrictions, and goals")
public class PreferenceController {

    private final PreferenceService preferenceService;
    private final PreferenceWeightsService preferenceWeightsService;

    public PreferenceController(PreferenceService preferenceService, PreferenceWeightsService preferenceWeightsService) {
        this.preferenceService = preferenceService;
        this.preferenceWeightsService = preferenceWeightsService;
    }

    // swagger comments
    @Operation(summary = "Get the user's preferences", description = "Returns the authenticated user's dietary restrictions, allergies, disliked ingredients, flavour profile, and nutritional goals.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Preferences retrieved successfully", content = @Content(schema = @Schema(implementation = PreferenceResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Preferences not found for this user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<PreferenceResponse> getUserPreferences(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(preferenceService.preferences(Integer.parseInt(userId)));
    }

    @Operation(summary = "Update the user's preferences", description = "Replaces the authenticated user's dietary restrictions, allergies, disliked ingredients, flavour profile, and nutritional goals. Every value is validated against the corresponding lookup list before saving.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Preferences updated successfully", content = @Content(schema = @Schema(implementation = PreferenceResponse.class))),
        @ApiResponse(responseCode = "400", description = "One or more values are invalid: dietary restrictions, allergen, flavour profile, and nutritional goals must match a valid lookup options - disliked ingredients must exist in the ingredient catalogue", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Preferences not found for this user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("")
    public ResponseEntity<PreferenceResponse> updateUserPreferences(@AuthenticationPrincipal String userId, @RequestBody PreferenceRequest request) {
        return ResponseEntity.ok(preferenceService.updatePreferences(Integer.parseInt(userId), request));
    }
    
    @Operation(summary = "Get the user's recommendation weights", description = "Returns the authenticated user's five recommendation weights (pantry match, cuisine, nutrition, freshness, novelty). If the user has no weights yet, the defaults (0.40 / 0.25 / 0.10 / 0.15 / 0.10) are created and returned.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Weights retrieved successfully", content = @Content(schema = @Schema(implementation = UserPreferenceWeightsResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/weights")
    public ResponseEntity<UserPreferenceWeightsResponse> getUserPreferenceWeights(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(preferenceWeightsService.getWeights(Integer.parseInt(userId)));
    }
 
    @Operation(summary = "Update the user's recommendation weights", description = "Saves the authenticated user's five recommendation weights, creating them if they don't exist yet. Every weight is required, must be between 0 and 1, and the five must sum to 1.0 (within 0.001).")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Weights updated successfully", content = @Content(schema = @Schema(implementation = UserPreferenceWeightsResponse.class))),
        @ApiResponse(responseCode = "400", description = "A weight is missing, outside the range 0 to 1, or the weights do not sum to 1.0", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/weights")
    public ResponseEntity<UserPreferenceWeightsResponse> updateUserPreferenceWeights(@AuthenticationPrincipal String userId, @RequestBody UserPreferenceWeightsRequest request) {
        return ResponseEntity.ok(preferenceWeightsService.updateWeights(Integer.parseInt(userId), request));
    }
}