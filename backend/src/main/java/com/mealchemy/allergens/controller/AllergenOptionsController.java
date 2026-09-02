package com.mealchemy.allergens.controller;

// import classes
import com.mealchemy.allergens.dto.AllergenOptionsResponse;
import com.mealchemy.allergens.service.AllergenOptionsService;
 
// import libraries
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;


@RestController
@RequestMapping("/allergies")
public class AllergenOptionsController {
    
    private final AllergenOptionsService allergenOptionsService;

    public AllergenOptionsController(AllergenOptionsService allergenOptionsService) {
        this.allergenOptionsService = allergenOptionsService;
    }

    // Get
    @GetMapping("/all")
    public List<AllergenOptionsResponse> getAllAllergens() {
        return allergenOptionsService.getAllAllergenOptions();
    }
}
