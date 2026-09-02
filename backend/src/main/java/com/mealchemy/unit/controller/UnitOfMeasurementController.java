package com.mealchemy.unit.controller;

// import dtos
import com.mealchemy.unit.dto.*;
// import services
import com.mealchemy.unit.service.*;
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
@RequestMapping("/api/units-of-measurement") 
@Tag(name = "Units of Measurement", description = "Available measurement units, filtered to the authenticated user's preferred measurement system (metric/imperial).")
public class UnitOfMeasurementController {

    private final UnitOfMeasurementService unitOfMeasurementService;

    public UnitOfMeasurementController(UnitOfMeasurementService unitOfMeasurementService) {
        this.unitOfMeasurementService = unitOfMeasurementService;
    }

    
    // get mapping - get all units of measurement for frontend to display
    @Operation(summary = "Get units of measurement for the user", description = "Returns units matching the authenticated user's preferred measurement system (metric/imperial), plus any general-purpose units.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Units retrieved successfully", @Content(array = @ArraySchema(schema = @Schema(implementation = UnitOfMeasurementResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "404", description = "User profile not found", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<List<UnitOfMeasurementResponse>> getAllUnitsOfMeasurementForUser(@AuthenticationPrincipal String userId) {
        return ResponseEntity.ok(unitOfMeasurementService.getUnitsForUser(Integer.parseInt(userId)));
    }
}
