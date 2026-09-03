package com.mealchemy.nutritionalgoals.controller;

// import classes
import com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse;
import com.mealchemy.nutritionalgoals.service.NutritionalGoalOptionsService;
 
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
@RequestMapping("/nutritionalgoals")
@Tag(name = "Nutritional Goal Options", description = "Lookup values for nutritional goal options")
public class NutritionalGoalOptionsController {
    
    private final NutritionalGoalOptionsService nutritionalGoalOptionsService;

    public NutritionalGoalOptionsController(NutritionalGoalOptionsService nutritionalGoalOptionsService) {
        this.nutritionalGoalOptionsService = nutritionalGoalOptionsService;
    }

    // swagger comments
    @Operation(summary = "Get all nutritional goal options", description = "Returns the full set of nutritional goal options available for user profiles.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Nutritional goal options retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = NutritionalGoalOptionsResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/all")
    public List<NutritionalGoalOptionsResponse> getAllNutritionalGoalOptions() {
        return nutritionalGoalOptionsService.getAllNutritionalGoalOptions();
    }
}
