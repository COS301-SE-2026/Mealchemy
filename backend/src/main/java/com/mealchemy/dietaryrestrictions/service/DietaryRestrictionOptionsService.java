package com.mealchemy.dietaryrestrictions.service;

// import classes
import com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse;
import com.mealchemy.dietaryrestrictions.repository.DietaryRestrictionOptionsRepository;

// import libraries
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class DietaryRestrictionOptionsService {
    
    private final DietaryRestrictionOptionsRepository dietaryRestrictionOptionsRepository;

    public DietaryRestrictionOptionsService(DietaryRestrictionOptionsRepository dietaryRestrictionOptionsRepository) {
        this.dietaryRestrictionOptionsRepository = dietaryRestrictionOptionsRepository;
    }

    // GET - all dietary restrictions available
    public List<DietaryRestrictionOptionsResponse> getAllDietaryRestrictionOptions() {
        return dietaryRestrictionOptionsRepository.getAllDietaryRestrictionOptions();
    }


    // for user preferences - get all valid dietary restrictions
    public List<String> getValidDietaryRestrictionOptions() {
        return dietaryRestrictionOptionsRepository.getAllDietaryRestrictionOptionsValues();
    }
}
