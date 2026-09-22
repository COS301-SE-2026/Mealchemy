package com.mealchemy.moderation.controller;

// import classes
import com.mealchemy.moderation.dto.FlaggedRecipeResponse;
import com.mealchemy.moderation.dto.FlagRequest;
import com.mealchemy.moderation.service.FlagService;
 
// import libraries
import org.springframework.web.bind.annotation.*;

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
@Tag(name = "Flag Recipe", description = "Report a community recipe in the global vault as a violation of community guidelines.")
public class FlagController {
    
    private final FlagService flag;

    public FlagController(FlagService flag) {
        this.flag = flag;
    }

    // swagger comments
    @Operation(summary = "Flag a recipe", description = "Report a community-published recipe as a violation of community guidelines, for admin review.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Flag created successfully", content = @Content(schema = @Schema(implementation = FlaggedRecipeResponse.class))),
        @ApiResponse(responseCode = "400", description = "Invalid reason value", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Recipe not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "409", description = "You already have a pending flag on this recipe", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/recipes/{recipeId}/flag")
    public ResponseEntity<FlaggedRecipeResponse> flagRecipe(@AuthenticationPrincipal String userId, @PathVariable Integer recipeId, @RequestBody @Valid FlagRequest request) {
        return ResponseEntity.ok(flag.createFlag(recipeId, request, Integer.parseInt(userId)));
    }
}
