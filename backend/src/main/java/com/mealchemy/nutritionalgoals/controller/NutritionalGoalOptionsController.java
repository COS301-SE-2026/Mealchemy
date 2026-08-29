package com.mealchemy.nutritionalgoals.controller;

// import classes
import com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse;
import com.mealchemy.nutritionalgoals.service.NutritionalGoalOptionsService;
 
// import libraries
import org.springframework.web.bind.annotation.*;
import java.util.*;


@RestController
@RequestMapping("/nutritionalgoals")
public class NutritionalGoalOptionsController {
    
    private final NutritionalGoalOptionsService nutritionalGoalOptionsService;

    public NutritionalGoalOptionsController(NutritionalGoalOptionsService nutritionalGoalOptionsService) {
        this.nutritionalGoalOptionsService = nutritionalGoalOptionsService;
    }

    // Get
    @GetMapping("/all")
    public List<NutritionalGoalOptionsResponse> getAllNutritionalGoalOptions() {
        return nutritionalGoalOptionsService.getAllNutritionalGoalOptions();
    }
}
