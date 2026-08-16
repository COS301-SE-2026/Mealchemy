package com.mealchemy.equipment.controller;

// import dtos
import com.mealchemy.equipment.dto.*;
// import services
import com.mealchemy.equipment.service.*;

import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/equipment") 
public class EquipmentController {

    private final EquipmentService equipmentService;

    public EquipmentController(EquipmentService equipmentService) {
        this.equipmentService = equipmentService;
    }

    
    // get mapping - get all equipment options for frontend to display
    @GetMapping("")
    public ResponseEntity<List<EquipmentResponse>> getAllEquipment() {
        return ResponseEntity.ok(equipmentService.getAllEquipmentOptions());
    }
}
