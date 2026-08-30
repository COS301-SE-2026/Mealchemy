package com.mealchemy.allergens.service;

// import classes
import com.mealchemy.allergens.model.AllergenOptions;
import com.mealchemy.allergens.dto.AllergenOptionsResponse;
import com.mealchemy.allergens.repository.AllergenOptionsRepository;

// import libraries
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;

@Service
public class AllergenOptionsService {
    
    private final AllergenOptionsRepository allergenOptionsRepository;

    public AllergenOptionsService(AllergenOptionsRepository allergenOptionsRepository) {
        this.allergenOptionsRepository = allergenOptionsRepository;
    }

    // GET - all allergens available
    public List<AllergenOptionsResponse> getAllAllergenOptions() {
        return allergenOptionsRepository.getAllAllergenOptions();
    }


    // for user profile - get all valid allergens
    public List<String> getValidAllergenOptions() {
        return allergenOptionsRepository.getAllAllergenValues();
    }
}
