package com.mealchemy.preference.service;
//models
import com.mealchemy.preference.model.UserPreferences;
//repositories
import com.mealchemy.preference.repository.UserPreferencesRepository;
//dtos
import com.mealchemy.preference.dto.PreferenceRequest;
import com.mealchemy.preference.dto.PreferenceResponse;
//services
import com.mealchemy.dietaryrestrictions.service.DietaryRestrictionOptionsService;
import com.mealchemy.allergens.service.AllergenOptionsService;
import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;
import com.mealchemy.nutritionalgoals.service.NutritionalGoalOptionsService;
import com.mealchemy.ingredient.service.IngredientCatalogueService;


import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database
import java.util.List;


import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PreferenceService {

    private final UserPreferencesRepository userPreferencesRepository;
    private final DietaryRestrictionOptionsService dietaryRestrictionOptionsService;
    private final AllergenOptionsService allergenOptionsService;
    private final FlavourProfileOptionsService flavourProfileOptionsService;
    private final NutritionalGoalOptionsService nutritionalGoalOptionsService;
    private final IngredientCatalogueService ingredientCatalogueService;


    public PreferenceService(UserPreferencesRepository userPreferencesRepository, DietaryRestrictionOptionsService dietaryRestrictionOptionsService, AllergenOptionsService allergenOptionsService, FlavourProfileOptionsService flavourProfileOptionsService, NutritionalGoalOptionsService nutritionalGoalOptionsService, IngredientCatalogueService ingredientCatalogueService) {
        this.userPreferencesRepository = userPreferencesRepository;
        this.dietaryRestrictionOptionsService = dietaryRestrictionOptionsService;
        this.allergenOptionsService = allergenOptionsService;
        this.flavourProfileOptionsService = flavourProfileOptionsService;
        this.nutritionalGoalOptionsService = nutritionalGoalOptionsService;
        this.ingredientCatalogueService = ingredientCatalogueService;
    }

    // GET request - Logic to get user preferences
    public PreferenceResponse preferences(Integer userId) { //return logged in users preferences
        UserPreferences userPreferences = userPreferencesRepository.findByUserId(userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Preferences not found")); //need to send correct error code

        return new PreferenceResponse(userPreferences.getDietaryRestrictions(), userPreferences.getAllergies(), userPreferences.getDislikedIngredients(), userPreferences.getFlavourProfile(), userPreferences.getNutritionalGoals());
    }

    @Transactional
    public PreferenceResponse updatePreferences(Integer userId, PreferenceRequest request) {
        UserPreferences userPreferences = userPreferencesRepository.findByUserId(userId)
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Preferences not found"));

        // check dietary restrictions against valid options
        List<String> validDietaryRestrictionOptions = dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions();
        List<String> invalidDietaryRestrictions = request.dietaryRestrictions().stream()
                                                                               .filter(restriction -> !validDietaryRestrictionOptions.contains(restriction)) // if current restriction item being streamed in is'nt a valid option, add it to invalid list
                                                                               .toList();

        if (!invalidDietaryRestrictions.isEmpty()) { //some invalid dietary restriction was passed in
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid dietary restriction item");
        }

        // check allergens against valid options
        List<String> validAllergenOptions = allergenOptionsService.getValidAllergenOptions();
        List<String> invalidAllergens = request.allergies().stream()
                                                           .filter(allergen -> !validAllergenOptions.contains(allergen)) // if current allergen item being streamed in is'nt a valid option, add it to invalid list
                                                           .toList();

        if (!invalidAllergens.isEmpty()) { //some invalid allergen was passed in
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid allergen item");
        }

        // check flavour profile from cuisine type values
        List<String> validFlavourProfiles = flavourProfileOptionsService.getValidCuisineTypes();
        List<String> invalidFlavourProfiles = request.flavourProfile().stream()
                                                                      .filter(profile -> !validFlavourProfiles.contains(profile)) // if current allergen item being streamed in is'nt a valid option, add it to invalid list
                                                                      .toList();

        if (!invalidFlavourProfiles.isEmpty()) { //some invalid cusine type was passed in
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid flavour profile item");
        }

        // check nutritional goals against valid options
        List<String> validNutritionalGoals = nutritionalGoalOptionsService.getValidNutritionalGoalOptions();
        List<String> invalidNutritionalGoals = request.nutritionalGoals().stream()
                                                                         .filter(goal -> !validNutritionalGoals.contains(goal)) // if current nutritionl goal item being streamed in is'nt a valid option, add it to invalid list
                                                                         .toList();

        if (!invalidNutritionalGoals.isEmpty()) { //some invalid equipment was passed in
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid nutritional goal item");
        }

        // check disliked ingredients are valid from the catalogue
        List<String> existingIngredients = ingredientCatalogueService.findExistingIngredientNames(request.dislikedIngredients());
        List<String> invalidIngredients = request.dislikedIngredients().stream()
                                                                       .filter(ingredient -> !existingIngredients.contains(ingredient)) // if current nutritionl goal item being streamed in is'nt a valid option, add it to invalid list
                                                                       .toList();

        if (!invalidIngredients.isEmpty()) { //some invalid equipment was passed in
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid disliked ingredient item");
        }

        userPreferences.setDietaryRestrictions(request.dietaryRestrictions());
        userPreferences.setAllergies(request.allergies());
        userPreferences.setDislikedIngredients(request.dislikedIngredients());
        userPreferences.setFlavourProfile(request.flavourProfile());
        userPreferences.setNutritionalGoals(request.nutritionalGoals());
        userPreferencesRepository.save(userPreferences);

        return new PreferenceResponse(userPreferences.getDietaryRestrictions(), userPreferences.getAllergies(), userPreferences.getDislikedIngredients(), userPreferences.getFlavourProfile(), userPreferences.getNutritionalGoals());
    }

}