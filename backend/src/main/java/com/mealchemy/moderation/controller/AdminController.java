package com.mealchemy.moderation.controller;

// import classes
import com.mealchemy.moderation.dto.FlaggedRecipeResponse;
import com.mealchemy.moderation.dto.FlaggedRecipeDetailResponse;
import com.mealchemy.moderation.dto.UserSummaryResponse;
import com.mealchemy.moderation.service.FlagService;
import com.mealchemy.moderation.service.AdminService;

import com.mealchemy.shared.enums.FlagStatus;
 
// import libraries
import org.springframework.web.bind.annotation.*;
import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;

// swagger 
import com.mealchemy.shared.dto.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/admin")
@Tag(name = "Admin", description = "Admin review of flagged recipes and promotion of users to admin.")
public class AdminController {
    
    private final FlagService flag;
    private final AdminService admin;

    public AdminController(AdminService admin, FlagService flag) {
        this.admin = admin;
        this.flag = flag;
    }

    // ========== Dealing with flagged recipes ==========

    // swagger comments
    // get all flagged recipes with the passed in status
    @Operation(summary = "List flagged recipes", description = "Returns flagged recipes for admin review, filterable by status (defaults to PENDING if not status is supplied).")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Flags retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = FlaggedRecipeResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "User is not an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Admin user not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/flags")
    public ResponseEntity<List<FlaggedRecipeResponse>> getFlaggedWithStatus(@AuthenticationPrincipal String adminUserId, @RequestParam(required = false) FlagStatus status) {
        return ResponseEntity.ok(flag.getFlags(status, Integer.parseInt(adminUserId)));
    }


    // get a specific flagged recipes details
    @Operation(summary = "List flagged recipe details", description = "Returns a single flagged recipe's full detail, for admin review.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Flag detail retrieved successfully", content = @Content(schema = @Schema(implementation = FlaggedRecipeDetailResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "User is not an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Flag not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/flags/{flaggedId}")
    public ResponseEntity<FlaggedRecipeDetailResponse> getFlaggedRecipeDetails(@AuthenticationPrincipal String adminUserId, @PathVariable Integer flaggedId) {
        return ResponseEntity.ok(flag.getFlagDetail(flaggedId, Integer.parseInt(adminUserId)));
    }


    // dismiss a flagged recipe (can stay in global vault)
    @Operation(summary = "Dismiss a flag", description = "Marks a flag as REVIEWED - the recipe stays pblished in the global vault. Also resolves every other pending flag on the same recipe with the same reason category.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Flag dismissed successfully", content = @Content(schema = @Schema(implementation = FlaggedRecipeResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "User is not an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Flag not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/flags/{flaggedId}/dismiss")
    public ResponseEntity<FlaggedRecipeResponse> dismissFlaggedRecipe(@AuthenticationPrincipal String adminUserId, @PathVariable Integer flaggedId) {
        return ResponseEntity.ok(flag.dismissFlag(flaggedId, Integer.parseInt(adminUserId)));
    }


    // remove a flagged recipe from global vault (isCommunityPublished = false)
    @Operation(summary = "Remove a flagged recipe from the global vault", description = "Unpublishes the flagged recipe from the global vault and marks the flag as REMOVED.Also resolves every other pending flag on the same recipe with the same reason category.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Recipe removed from the global vault successfully", content = @Content(schema = @Schema(implementation = FlaggedRecipeResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "User is not an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Flag not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/flags/{flaggedId}/recipe")
    public ResponseEntity<FlaggedRecipeResponse> removeFlaggedRecipe(@AuthenticationPrincipal String adminUserId, @PathVariable Integer flaggedId) {
        return ResponseEntity.ok(flag.removeFlaggedRecipe(flaggedId, Integer.parseInt(adminUserId)));
    }


    // ========== Managing Admin Users ==========

    // get user by email
    @Operation(summary = "Find a user by email", description = "Looks up a user by email address, for an admin selecting who to promote to an admin.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User found successfully", content = @Content(schema = @Schema(implementation = UserSummaryResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "User is not an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/users")
    public ResponseEntity<UserSummaryResponse> findSpecificUser(@AuthenticationPrincipal String adminUserId, @RequestParam String email) {
        return ResponseEntity.ok(admin.findUserByEmail(email, Integer.parseInt(adminUserId)));
    }


    // promote selected user to admin
    @Operation(summary = "Promote a user to admin", description = "Adds the ADMIN role to the target user's roles.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "User promoted to admin successfully", content = @Content(schema = @Schema(implementation = UserSummaryResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "403", description = "User is not an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "User is already an admin", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/users/{userId}/promote")
    public ResponseEntity<UserSummaryResponse> promoteUserToAdmin(@AuthenticationPrincipal String adminUserId, @PathVariable Integer userId) {
        return ResponseEntity.ok(admin.promoteToAdmin(userId, Integer.parseInt(adminUserId)));
    }
}
