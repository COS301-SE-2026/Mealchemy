package com.mealchemy.nutritionalgoals.service;

// import classes
import com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse;
import com.mealchemy.nutritionalgoals.repository.NutritionalGoalOptionsRepository;

// import libraries
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class NutritionalGoalOptionsService {
    
    private final NutritionalGoalOptionsRepository nutritionalGoalOptionsRepository;

    public NutritionalGoalOptionsService(NutritionalGoalOptionsRepository nutritionalGoalOptionsRepository) {
        this.nutritionalGoalOptionsRepository = nutritionalGoalOptionsRepository;
    }

    // GET - all nutritionalgoals available
    public List<NutritionalGoalOptionsResponse> getAllNutritionalGoalOptions() {
        return nutritionalGoalOptionsRepository.getAllNutritionalGoalOptions();
    }


    // for user profile - get all valid nutritionalgoals
    public List<String> getValidNutritionalGoalOptions() {
        return nutritionalGoalOptionsRepository.getAllNutritionalGoalOptionsValues();
    }
}
