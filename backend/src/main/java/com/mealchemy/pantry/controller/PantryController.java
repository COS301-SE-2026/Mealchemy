package com.mealchemy.pantry.controller;

// import dtos
import com.mealchemy.pantry.dto.*;
// import services
import com.mealchemy.pantry.service.*;
// for jwt token
import org.springframework.security.core.annotation.AuthenticationPrincipal;

import java.util.List;
import org.springframework.http.ResponseEntity;
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
@RequestMapping("/api/pantry") 
@Tag(name = "Pantry", description = "The authenticated user's pantry ingredients")
public class PantryController {

    private final PantryService pantryService;

    public PantryController(PantryService pantryService) {
        this.pantryService = pantryService;
    }

    // swagger comments
    @Operation(summary = "Get the user's pantry items", description = "Returns all pantry ingredients for the authenticated user, converted to their preferred unit.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pantry items retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = PantryIngredientResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<List<PantryIngredientResponse>> getUsersPantry(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(pantryService.getUserPantryItems(Integer.parseInt(userId)));
    }


    @Operation(summary = "Add a pantry ingredient", description = "Adds an ingredient from the catalogue to the authenticated user's pantry with a quantity and unit.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pantry ingredient added successfully", content = @Content(schema = @Schema(implementation = PantryIngredientResponse.class))),
        @ApiResponse(responseCode = "400", description = "Validation failed (e.g. invalid quantity or unit)", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Ingredient or category not found in the catalogue, or user profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    // user manually adds a new ingredient
    @PostMapping("")
    public ResponseEntity<PantryIngredientResponse> addPantryIngredientManually(@AuthenticationPrincipal String userId, @RequestBody PantryIngredientRequest request) {
        return ResponseEntity.ok(pantryService.addIngredientManually(Integer.parseInt(userId), request));
    }
    

    @Operation(summary = "Update a pantry ingredient", description = "Updates the quanitity and/or unit of a pantry ingredient owned by the authenticated user. If the new quantity is zero or less, the ingredient is deleted instead and 204 is returned.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pantry ingredient updated successfully", content = @Content(schema = @Schema(implementation = PantryIngredientResponse.class))),
        @ApiResponse(responseCode = "204", description = "Quantity was zero or less - ingredient was deleted instead of updated"),
        @ApiResponse(responseCode = "400", description = "Validation failed (e.g. invalid quantity or unit)", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pantry ingredient not found, not owned by authenticated user, or referenced catalogue ingredient/category/profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @PutMapping("/{id}")
    public ResponseEntity<PantryIngredientResponse> updatePantryIngredientManually(@AuthenticationPrincipal String userId, @PathVariable Integer id, @RequestBody PantryIngredientRequest request) {
        return pantryService.updateIngredientManually(Integer.parseInt(userId), id, request).map(ResponseEntity::ok)
                                                                                            .orElse(ResponseEntity.noContent().build());
    }

    @Operation(summary = "Delete a pantry ingredient", description = "Deletes a pantry ingredient owned by the authenticated user.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Pantry inredient deleted successfully"),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "Pantry ingredient not found, or not owned by the authenticated user", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> removePantryIngredientManually(@AuthenticationPrincipal String userId, @PathVariable Integer id) {
        pantryService.removePantryIngredient(Integer.parseInt(userId), id);
        return ResponseEntity.noContent().build();
    }


    @Operation(summary = "Search the user's pantry by ingredient name", description = "Searches the authenticated user's pantry items by name, converted to their preferred unit.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Search completed successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = PantryIngredientResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/search")
    public ResponseEntity<List<PantryIngredientResponse>> searchPantryItem(@AuthenticationPrincipal String userId, @RequestParam("q") String query) {
        return ResponseEntity.ok(pantryService.findPantryIngredientsByName(Integer.parseInt(userId), query));
    }
}