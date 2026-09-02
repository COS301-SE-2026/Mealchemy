package com.mealchemy.category.controller;

// import dtos
import com.mealchemy.category.dto.*;
// import services
import com.mealchemy.category.service.*;

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
@RequestMapping("/api/categories") 
@Tag(name = "Ingredient Categories", description = "Lookup values for ingredient category options")
public class IngredientCategoryController {

    private final IngredientCategoryService ingredientCategoryService;

    public IngredientCategoryController(IngredientCategoryService ingredientCategoryService) {
        this.ingredientCategoryService = ingredientCategoryService;
    }

    // swagger comments
    @Operation(summary = "Get all ingredient category options", description = "Returns the full set of ingredient categories available for tagging pantry items and ingredients.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Categories retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = IngredientCategoryResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    // get mapping - get all ingredient categories options for frontend to display
    @GetMapping("")
    public ResponseEntity<List<IngredientCategoryResponse>> getAllIngredientCategories() {
        return ResponseEntity.ok(ingredientCategoryService.getAllIngredientCategoryOptions());
    }
}
