package com.mealchemy.pantry.service;
//models
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.profile.model.UserProfile;

//repositories
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.profile.repository.UserProfileRepository;


import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.pantry.dto.PantryIngredientRequest;
import com.mealchemy.pantry.dto.PantryIngredientResponse;

//shared unit conversion
import com.mealchemy.shared.unitconverter.UnitConverter;
import com.mealchemy.shared.enums.PreferredUnit;

import java.util.List;
import java.util.Optional;
import java.math.BigDecimal;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PantryService {
    
    private final PantryIngredientRepository pantryIngredientRepository;
    private final IngredientCatalogueRepository ingredientCatalogueRepository;
    private final IngredientCategoryRepository ingredientCategoryRepository;
    private final UserProfileRepository userProfileRepository;

    //constructor
    public PantryService(PantryIngredientRepository pantryIngredientRepository, IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository, UserProfileRepository userProfileRepository) {
        this.pantryIngredientRepository = pantryIngredientRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.ingredientCategoryRepository = ingredientCategoryRepository;
        this.userProfileRepository = userProfileRepository;
    }

    // GET request - returns all pantry items for the logged-in user
    public List<PantryIngredientResponse> getUserPantryItems(Integer userId) {
        PreferredUnit preferredUnit = getPreferredUnit(userId);
        List<PantryIngredientResponse> results = pantryIngredientRepository.findPantryIngredientsByUserId(userId);
        return convertIngredientResponses(results, preferredUnit); 
    }

    // POST - manual addition of ingredient to user's pantry (query to ingredient catalogue)
    @Transactional
    public PantryIngredientResponse addIngredientManually(Integer userId, PantryIngredientRequest request) {
        
        //frontend will select an ingredient from the ingredient catalogue (for now, later if db miss query USDA api)
        //that ingredient has an ingId 
        //user must input a numerical quantity and select a unit from the dropdown

        // find exact ingredient in the catalogue
        IngredientCatalogue selectedIngredient = ingredientCatalogueRepository.findById(request.ingId())
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found"));

        // find ingredient category
        IngredientCategory category = ingredientCategoryRepository.findById(selectedIngredient.getCategoryId())
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));

        UnitConverter.NormalisedQuantity normalised = UnitConverter.normaliseIngredient(request.quantity(), request.unit());

        // create new PantryIngredient
        PantryIngredient newIngredient = new PantryIngredient();
        newIngredient.setUserId(userId);
        newIngredient.setIngredientId(request.ingId());
        newIngredient.setQuantity(normalised.quantity());
        newIngredient.setUnit(normalised.unit());
        newIngredient.setStorageLocation(request.storageLocation());

        PantryIngredient saved = pantryIngredientRepository.save(newIngredient);

        PreferredUnit preferredUnit = getPreferredUnit(userId);
        UnitConverter.NormalisedQuantity display = UnitConverter.convertToUsersPreferredUnit(saved.getQuantity(), saved.getUnit(), preferredUnit);


        return new PantryIngredientResponse(saved.getPIngredientId(), //must call methods on OBJECT not repository
                                            saved.getIngredientId(), 
                                            selectedIngredient.getName(), //name from catalogue
                                            category.getCategoryName(), 
                                            display.quantity(),
                                            display.unit(),
                                            saved.getStorageLocation(),
                                            saved.getCreatedAt(),
                                            saved.getUpdatedAt()
        );

    }


    // PUT - manual update of a pantry ingredient when it has been selected
    @Transactional
    public Optional<PantryIngredientResponse> updateIngredientManually(Integer userId, Integer pIngredientId, PantryIngredientRequest request) {
        PantryIngredient selectedPantryIngredient = pantryIngredientRepository.findById(pIngredientId)
                                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found in pantry"));

        // check if selected belongs to logged in user
        if (!selectedPantryIngredient.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not own this ingredient");
        }

        if (request.quantity().compareTo(BigDecimal.ZERO) <= 0) {
            pantryIngredientRepository.delete(selectedPantryIngredient);
            return Optional.empty();
        }

        // normalise quantity and unit to canonical before saving
        UnitConverter.NormalisedQuantity normalised = UnitConverter.normaliseIngredient(request.quantity(), request.unit());

        // assuming all 3 parameters are sent in everytime, even if only 1 changes - we don't set the id because it will change the ingredient
        selectedPantryIngredient.setQuantity(normalised.quantity());
        selectedPantryIngredient.setUnit(normalised.unit());
        selectedPantryIngredient.setStorageLocation(request.storageLocation());

        PantryIngredient saved = pantryIngredientRepository.save(selectedPantryIngredient);


        // find exact ingredient in the catalogue - needed in response body
        IngredientCatalogue selectedIngredient = ingredientCatalogueRepository.findById(saved.getIngredientId())
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found"));

        // find ingredient category - needed in response body
        IngredientCategory category = ingredientCategoryRepository.findById(selectedIngredient.getCategoryId())
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));


        // show response with users preferred unit
        PreferredUnit preferredUnit = getPreferredUnit(userId);
        UnitConverter.NormalisedQuantity display = UnitConverter.convertToUsersPreferredUnit(saved.getQuantity(), saved.getUnit(), preferredUnit);

        return Optional.of(new PantryIngredientResponse(saved.getPIngredientId(), //must call methods on OBJECT not repository
                                            saved.getIngredientId(), 
                                            selectedIngredient.getName(), //name from catalogue
                                            category.getCategoryName(), 
                                            display.quantity(),
                                            display.unit(),
                                            saved.getStorageLocation(),
                                            saved.getCreatedAt(),
                                            saved.getUpdatedAt()
        ));

    }


    // DELETE selected ingredient from users pantry
    @Transactional
    public void removePantryIngredient(Integer userId, Integer pIngredientId) {
        // check if row exists
        PantryIngredient selectedPantryIngredient = pantryIngredientRepository.findById(pIngredientId)
                                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found in pantry"));

        // check if selected belongs to logged in user
        if (!selectedPantryIngredient.getUserId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not own this ingredient");
        }

        pantryIngredientRepository.delete(selectedPantryIngredient);

    }


    // GET - search for ingreient by name - convert to preferred unit
    public List<PantryIngredientResponse> findPantryIngredientsByName(Integer userId, String ingredientName) { //might update when full USDA is implemented
        PreferredUnit preferredUnit = getPreferredUnit(userId);
        List<PantryIngredientResponse> results = pantryIngredientRepository.getIngredientByName(userId, ingredientName);
        return convertIngredientResponses(results, preferredUnit); 
    }

    // ========== Helpers ==========

    private PreferredUnit getPreferredUnit(Integer userId) {
        // finding users preferred unit of measurement
        return userProfileRepository.findByUserId(userId).map(UserProfile::getPreferredUnit)
                                                         .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found"));
    }

    
    // converting to users preferred unit for a singular pantry ingredient
    private PantryIngredientResponse convertIngredientResponseToPreferredUnit(PantryIngredientResponse response, PreferredUnit preferredUnit) {
        UnitConverter.NormalisedQuantity display = UnitConverter.convertToUsersPreferredUnit(response.quantity(), response.unit(), preferredUnit);

        return new PantryIngredientResponse(
                    response.pIngredientId(), //must call methods on OBJECT not repository
                    response.ingId(), 
                    response.name(), //name from catalogue
                    response.category(), 
                    display.quantity(),
                    display.unit(),
                    response.storageLocation(),
                    response.createdAt(),
                    response.updatedAt()
            );
    }

    // converting to users preferred unit for a list of pantry ingredients
    private List<PantryIngredientResponse> convertIngredientResponses(List<PantryIngredientResponse> responses, PreferredUnit preferredUnit) {
       return responses.stream().map(response -> convertIngredientResponseToPreferredUnit(response, preferredUnit))
                                .toList();
    }
}