package com.mealchemy.swipes.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.swipes.service.SwipeService;
import com.mealchemy.swipes.dto.SwipeRequest;
import com.mealchemy.swipes.dto.SwipeResponse;
import com.mealchemy.swipes.dto.LikedRecipesResponse;
import com.mealchemy.swipes.model.Swipe;

/* Swagger */
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;


@RestController
@RequestMapping("/discovery")
@Tag(name = "Swipes", description = "Recipe discovery swipe recording and liked recipes")
public class SwipeController {
    private final SwipeService swipeService;

    public SwipeController(SwipeService swipeService)
    {
        this.swipeService = swipeService;
    }


    @Operation(summary = "Record a swipe", description = "Records a like/dislike swipe action against a recipe, along with the signal scores used to reach it. Every call creates a new swipe record - swipe history is append-only. Once a user's unflushed swipe count reaches the batch threshold, a learning update is triggered asynchronously to refine future recommendations.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Swipe recorded successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = ShoppingListResponse.class)))),
        @ApiResponse(responseCode = "400", description = "Validation failed on the swipe request", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/swipes")
    public SwipeResponse recordSwipe(@AuthenticationPrincipal String userId, @Valid @RequestBody SwipeRequest request)
    {
        Swipe saved = swipeService.recordSwipe(
            Integer.parseInt(userId),
            request.recipeId(),
            request.cuisineValue(),
            request.action(),
            request.signalScores()
        );
        return SwipeResponse.from(saved);
    }


    @Operation(summary = "Get liked recipes", description = "Returns every recipe the authenticated user has most recently swiped as liked, one entry per recipe (deduplicated to the most recent swipe if liked more than once), sorted most-recently-liked first.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Liked recipes retrieved successfully", content = @Content(schema = @Schema(implementation = LikedRecipesResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/liked")
    public LikedRecipesResponse getLikedRecipes(@AuthenticationPrincipal String userId)
    {
        return new LikedRecipesResponse(swipeService.getLikedRecipes(Integer.parseInt(userId)));
    }
}