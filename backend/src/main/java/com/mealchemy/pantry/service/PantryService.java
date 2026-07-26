package com.mealchemy.pantry.service;
//models
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;

//repositories
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;


import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.pantry.dto.PantryIngredientRequest;
import com.mealchemy.pantry.dto.PantryIngredientResponse;
// import com.mealchemy.ingredient.dto.IngredientCatalogueRequest;
// import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;

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

    //constructor
    public PantryService(PantryIngredientRepository pantryIngredientRepository, IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository) {
        this.pantryIngredientRepository = pantryIngredientRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.ingredientCategoryRepository = ingredientCategoryRepository;
    }

    // GET request - returns all pantry items for the logged-in user
    public List<PantryIngredientResponse> getUserPantryItems(Integer userId) {
        return pantryIngredientRepository.findPantryIngredientsByUserId(userId);   
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

        // create new PantryIngredient
        PantryIngredient newIngredient = new PantryIngredient();
        newIngredient.setUserId(userId);
        newIngredient.setIngredientId(request.ingId());
        newIngredient.setQuantity(request.quantity());
        newIngredient.setUnit(request.unit());

        PantryIngredient saved = pantryIngredientRepository.save(newIngredient);

        return new PantryIngredientResponse(saved.getPIngredientId(), //must call methods on OBJECT not repository
                                            saved.getIngredientId(), 
                                            selectedIngredient.getName(), //name from catalogue
                                            category.getCategoryName(), 
                                            saved.getQuantity(),
                                            saved.getUnit(),
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

        // assuming all 3 parameters are sent in everytime, even if only 1 changes - we don't set the id because it will change the ingredient
        selectedPantryIngredient.setQuantity(request.quantity());
        selectedPantryIngredient.setUnit(request.unit());

        PantryIngredient saved = pantryIngredientRepository.save(selectedPantryIngredient);


        // find exact ingredient in the catalogue - needed in response body
        IngredientCatalogue selectedIngredient = ingredientCatalogueRepository.findById(saved.getIngredientId())
                                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found"));

        // find ingredient category - needed in response body
        IngredientCategory category = ingredientCategoryRepository.findById(selectedIngredient.getCategoryId())
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found"));

        return Optional.of(new PantryIngredientResponse(saved.getPIngredientId(), //must call methods on OBJECT not repository
                                            saved.getIngredientId(), 
                                            selectedIngredient.getName(), //name from catalogue
                                            category.getCategoryName(), 
                                            saved.getQuantity(),
                                            saved.getUnit(),
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


    // GET - search for ingreient by name
    public List<PantryIngredientResponse> findPantryIngredientsByName(Integer userId, String ingredientName) { //might update when full USDA is implemented
        // personal query
        return pantryIngredientRepository.getIngredientByName(userId, ingredientName);    
    }

}