package com.mealchemy.dietaryrestrictions.controller;

// import classes
import com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse;
import com.mealchemy.dietaryrestrictions.service.DietaryRestrictionOptionsService;
 
// import libraries
import org.springframework.web.bind.annotation.*;
import java.util.*;


@RestController
@RequestMapping("/dietaryrestrictions")
public class DietaryRestrictionOptionsController {
    
    private final DietaryRestrictionOptionsService dietaryRestrictionOptionsService;

    public DietaryRestrictionOptionsController(DietaryRestrictionOptionsService dietaryRestrictionOptionsService) {
        this.dietaryRestrictionOptionsService = dietaryRestrictionOptionsService;
    }

    // Get
    @GetMapping("/all")
    public List<DietaryRestrictionOptionsResponse> getAllDietaryRestrictionOptions() {
        return dietaryRestrictionOptionsService.getAllDietaryRestrictionOptions();
    }
}
