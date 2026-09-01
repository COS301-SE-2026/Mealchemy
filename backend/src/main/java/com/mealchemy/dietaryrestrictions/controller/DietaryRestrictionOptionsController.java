package com.mealchemy.dietaryrestrictions.controller;

// import classes
import com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse;
import com.mealchemy.dietaryrestrictions.service.DietaryRestrictionOptionsService;
 
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
@RequestMapping("/dietaryrestrictions")
@Tag(name = "Dietary Restriction Options", description = "Lookup values for dietary restriction options")
public class DietaryRestrictionOptionsController {
    
    private final DietaryRestrictionOptionsService dietaryRestrictionOptionsService;

    public DietaryRestrictionOptionsController(DietaryRestrictionOptionsService dietaryRestrictionOptionsService) {
        this.dietaryRestrictionOptionsService = dietaryRestrictionOptionsService;
    }

    // swagger comments
    @Operation(summary = "Get all dietary restriction options", description = "Returns the full set of dietary restriction options available for recipes and user preferences.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Dietary restriction options retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = DietaryRestrictionOptionsResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/all")
    public List<DietaryRestrictionOptionsResponse> getAllDietaryRestrictionOptions() {
        return dietaryRestrictionOptionsService.getAllDietaryRestrictionOptions();
    }
}
