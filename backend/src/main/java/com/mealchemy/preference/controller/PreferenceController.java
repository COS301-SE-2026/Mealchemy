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

    public PreferenceController(PreferenceService preferenceService) {
        this.preferenceService = preferenceService;
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
    
}