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

@RestController
@RequestMapping("/api/units-of-measurement") 
public class UnitOfMeasurementController {

    private final UnitOfMeasurementService unitOfMeasurementService;

    public UnitOfMeasurementController(UnitOfMeasurementService unitOfMeasurementService) {
        this.unitOfMeasurementService = unitOfMeasurementService;
    }

    
    // get mapping - get all units of measurement for frontend to display

    @GetMapping("")
    public ResponseEntity<List<UnitOfMeasurementResponse>> getAllUnitOfMeasurements() {
        return ResponseEntity.ok(unitOfMeasurementService.getAllUnits());
    }
}
