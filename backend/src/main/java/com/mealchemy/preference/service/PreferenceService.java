package com.mealchemy.preference.service;
//models
import com.mealchemy.preference.model.UserPreferences;
//repositories
import com.mealchemy.preference.repository.UserPreferencesRepository;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.preference.dto.PreferenceRequest;
import com.mealchemy.preference.dto.PreferenceResponse;


import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PreferenceService {

    private final UserPreferencesRepository userPreferencesRepository;

    public PreferenceService(UserPreferencesRepository userPreferencesRepository) {
        this.userPreferencesRepository = userPreferencesRepository;

    }

    // GET request - Logic to get user preferences
    public PreferenceResponse preferences(Integer userId) { //return logged in users preferences
        UserPreferences userPreferences = userPreferencesRepository.findByUserId(userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Preferences not found")); //need to send correct error code

        return new PreferenceResponse(userPreferences.getDietaryRestrictions(), userPreferences.getAllergies(), userPreferences.getDislikedIngredients(), userPreferences.getFlavourProfile());
    }

    @Transactional
    public PreferenceResponse updatePreferences(Integer userId, PreferenceRequest request) {
        UserPreferences userPreferences = userPreferencesRepository.findByUserId(userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Preferences not found"));
        userPreferences.setDietaryRestrictions(request.dietaryRestrictions());
        userPreferences.setAllergies(request.allergies());
        userPreferences.setDislikedIngredients(request.dislikedIngredients());
        userPreferences.setFlavourProfile(request.flavourProfile());
        userPreferencesRepository.save(userPreferences);

        return new PreferenceResponse(userPreferences.getDietaryRestrictions(), userPreferences.getAllergies(), userPreferences.getDislikedIngredients(), userPreferences.getFlavourProfile());
    }

}