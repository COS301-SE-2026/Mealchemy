package com.mealchemy.ingredient.controller;

// import dtos
import com.mealchemy.ingredient.dto.*;
// import services
import com.mealchemy.ingredient.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

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
@RequestMapping("/api/ingredient-catalogue") 
@Tag(name = "Ingredient Catalogue", description = "Search and manage the shared ingredient catalogue")
public class IngredientCatalogueController {

    private final IngredientCatalogueService ingredientCatalogueService;

    public IngredientCatalogueController(IngredientCatalogueService ingredientCatalogueService) {
        this.ingredientCatalogueService = ingredientCatalogueService;
    }

    // swagger comments
    @Operation(summary = "Get the full ingredient catalogue", description = "Returns every ingredient currently in the shared catalogue.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Catalogue retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = IngredientCatalogueResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<List<IngredientCatalogueResponse>> getIngredientCatalogue(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(ingredientCatalogueService.getIngredientCatalogue());
    }

    
    @Operation(summary = "Search the ingredient catalogue by name", description = "Searches the local catalogue first - if no local match is found, it falls back to an external nutrition data provider (USDA).")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Search complete (local or external results)", content = @Content(array = @ArraySchema(schema = @Schema(implementation = IngredientSearchResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/search")
    public ResponseEntity<List<IngredientSearchResponse>> searchIngredientCatalogueByName(@AuthenticationPrincipal String userId, @RequestParam("q") String query) {
        return ResponseEntity.ok(ingredientCatalogueService.getIngredientByName(query));
    }


    @Operation(summary = "Save an external ingredient into the catalogue", description = "Persists an ingredient sourceId from and external nutrition provider into the shared catalogue. " + "If the provider gave no category, returns 422 with the pending ingredient details so the frontend can prompt the user to select a category and retry.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Ingredient saved to the catalogue successfully", content = @Content(schema = @Schema(implementation = IngredientCatalogueResponse.class))),
        @ApiResponse(responseCode = "400", description = "Supplied categoryId does not exist", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "422", description = "External provider gave no category for this ingredient - caller must resubmit with a categoryId", content = @Content(schema = @Schema(implementation = IngredientPendingResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PostMapping("/add-external")
    public ResponseEntity<?> addExternalIngredient(@AuthenticationPrincipal String userId, @Valid @RequestBody AddExternalIngredientToCatalogueRequest request) {
        try {
            IngredientCatalogueResponse saved = ingredientCatalogueService.saveExternalIngredientToCatalogue(request.sourceId(), request.categoryId());
            return ResponseEntity.ok(saved);
        }
        catch (CategoryRequiredException e) {
            IngredientPendingResponse pending = new IngredientPendingResponse(e.getSourceId(), e.getName());
            return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(pending);
        }
    }
}