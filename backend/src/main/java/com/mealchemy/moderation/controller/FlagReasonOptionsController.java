package com.mealchemy.moderation.controller;

// import classes
import com.mealchemy.moderation.dto.FlagReasonOptionsResponse;
import com.mealchemy.moderation.service.FlagReasonOptionsService;
 
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
@RequestMapping("/flagreasons")
@Tag(name = "Flag Options", description = "Lookup values for reasons a recipe could be flagged in the global vault")
public class FlagReasonOptionsController {
    
    private final FlagReasonOptionsService flagReasonOptions;

    public FlagReasonOptionsController(FlagReasonOptionsService flagReasonOptions) {
        this.flagReasonOptions = flagReasonOptions;
    }

    // swagger comments
    @Operation(summary = "Get all flag reason options", description = "Returns the full set of flag reason options available for a recipe in the global vault.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Flag reason options retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = FlagReasonOptionsResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("/all")
    public List<FlagReasonOptionsResponse> getAllFlagReasonOptions() {
        return flagReasonOptions.getAllFlagReasonOptions();
    }
}
