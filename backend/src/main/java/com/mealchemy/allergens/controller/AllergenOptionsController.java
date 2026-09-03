package com.mealchemy.allergens.controller;

// import classes
import com.mealchemy.allergens.dto.AllergenOptionsResponse;
import com.mealchemy.allergens.service.AllergenOptionsService;
 
// import libraries
import org.springframework.web.bind.annotation.*;
import java.util.*;

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
@RequestMapping("/allergies")
@Tag(name = "Allergen Options", description = "Lookup values for allergen options")
public class AllergenOptionsController {
    
    private final AllergenOptionsService allergenOptionsService;

    public AllergenOptionsController(AllergenOptionsService allergenOptionsService) {
        this.allergenOptionsService = allergenOptionsService;
    }

    // Get
    // swagger comments
    @Operation(summary = "Get all allergen options", description = "Returns the full set of allergen options available for user preferences.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Allergen options retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = AllergenOptionsResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/all")
    public List<AllergenOptionsResponse> getAllAllergens() {
        return allergenOptionsService.getAllAllergenOptions();
    }
}
