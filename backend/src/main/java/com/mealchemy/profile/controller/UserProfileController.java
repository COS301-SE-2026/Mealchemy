package com.mealchemy.profile.controller;

// import dtos
import com.mealchemy.profile.dto.*;
// import services
import com.mealchemy.profile.service.*;
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
@RequestMapping("/user/profile") 
@Tag(name = "User Profile", description = "The authenticated user's display profile and settings")
public class UserProfileController {

    private final UserProfileService userProfileService;

    public UserProfileController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    // swagger comments
    @Operation(summary = "Get the user's profile", description = "Returns the authenticated user's display name, avatar, preferred unit, equipment list, and last updated timestamp.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Profile retrieved successfully", content = @Content(schema = @Schema(implementation = UserProfileResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<UserProfileResponse> getUserProfileDetails(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(userProfileService.getUserProfile(Integer.parseInt(userId)));
    }


    @Operation(summary = "Update the user's profile", description = "Replaces the authenticated user's display name, avatar, preferred unit, equipment list. All fields are required on every request.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Profile updated successfully", content = @Content(schema = @Schema(implementation = UserProfileResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed: a required field is missing, displayName is blank or exceeds 80 characters, preferredUnit is not a valid enum value (metric/imperial), or equipment contains a value not in the valid options list", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("")
    public ResponseEntity<UserProfileResponse> updateUserProfileDetails(@AuthenticationPrincipal String userId, @RequestBody UserProfileUpdateRequest request) {
        return ResponseEntity.ok(userProfileService.updateUserProfile(Integer.parseInt(userId), request));
    }
    
}