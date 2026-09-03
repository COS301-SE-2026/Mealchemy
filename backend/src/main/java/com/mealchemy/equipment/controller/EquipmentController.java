package com.mealchemy.equipment.controller;

// import dtos
import com.mealchemy.equipment.dto.*;
// import services
import com.mealchemy.equipment.service.*;

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
@RequestMapping("/api/equipment") 
@Tag(name = "Equipment Options", description = "Lookup values for kitchen equipment options")
public class EquipmentController {

    private final EquipmentService equipmentService;

    public EquipmentController(EquipmentService equipmentService) {
        this.equipmentService = equipmentService;
    }

    
    // swagger comments
    @Operation(summary = "Get all equipment options", description = "Returns the full set of kitchen equipment options available for recipes and user profiles.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Equipment options retrieved successfully", content = @Content(array = @ArraySchema(schema = @Schema(implementation = EquipmentResponse.class)))),
        @ApiResponse(responseCode = "401", description = "No valid JWT present", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
        @ApiResponse(responseCode = "500", description = "Unexpected server error", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
    })
    @GetMapping("")
    public ResponseEntity<List<EquipmentResponse>> getAllEquipment() {
        return ResponseEntity.ok(equipmentService.getAllEquipmentOptions());
    }
}
