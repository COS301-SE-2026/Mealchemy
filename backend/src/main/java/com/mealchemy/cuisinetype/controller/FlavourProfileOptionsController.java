package com.mealchemy.cuisinetype.controller;

/* Import libraries */

import org.springframework.web.bind.annotation.*;
import java.util.*;

/* Import classes */

import com.mealchemy.cuisinetype.dto.FlavourProfileOptionsResponse;
import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;

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
@RequestMapping("/flavourprofileoptions")
@Tag(name = "Flavour Profile Options", description = "Lookup values for cuisine/flavour profile options")
public class FlavourProfileOptionsController {
    
    private final FlavourProfileOptionsService flavourProfileOptionsService;

    public FlavourProfileOptionsController(FlavourProfileOptionsService flavourProfileOptionsService)
    {
        this.flavourProfileOptionsService = flavourProfileOptionsService;
    }

    // swagger comments
    @Operation(summary = "Get all flavour profile options", description = "Returns the full set of cuisine/flavour profile options available for recipes and user preferences.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Flavour profile options retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = FlavourProfileOptionsResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/all")
    public List<FlavourProfileOptionsResponse> getAllCuisineTypes()
    {
        return flavourProfileOptionsService.getAllCuisineTypes();
    }
}
