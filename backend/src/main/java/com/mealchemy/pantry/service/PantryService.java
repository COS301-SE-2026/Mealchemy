package com.mealchemy.pantry.service;
//models
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;

//repositories
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;

import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.pantry.dto.PantryIngredientRequest;
import com.mealchemy.pantry.dto.PantryIngredientResponse;
import com.mealchemy.ingredient.dto.IngredientCatalogueRequest;
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PantryService {
    
    private final PantryIngredientRepository pantryIngredientRepository;
    private final IngredientCatalogueRepository ingredientCatalogueRepository;
    private final IngredientCategoryRepository ingredientCategoryRepository;

    //constructor
    public PantryService(PantryIngredientRepository pantryIngredientRepository, IngredientCatalogueRepository ingredientCatalogue, IngredientCategory ingredientCategoryRepository) {
        this.pantryIngredientRepository = pantryIngredientRepository;
        this.ingredientCatalogue = ingredientCatalogue;
        this.ingredientCategory = ingredientCategory;
    }

    // GET request - returns all pantry items for the logged-in user
    public PantryIngredientResponse getUserPantryItems(Integer userId) {
        return pantryIngredientRepository.findPantryIngredientsByUserId(userId);   
    }

    // PUT - manual addition of ingredient to user's pantry (query to ingredient catalogue)
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
        PantryIngredient newIngredient;
        newIngredient.setUserId(request.userId());
        newIngredient.setIngredientId(request.ingId());
        newIngredient.setQuantity(request.quantity());
        newIngredient.setUnit(request.unit());
        pantryIngredientRepository.save(newIngredient);

        return new PantryIngredientRepository(pantryIngredientRepository.getPIngredientId(), 
                                            pantryIngredientRepository.getIngredientId(), 
                                            selectedIngredient.getName(), //name from catalogue
                                            category.getCategoryName(), 
                                            pantryIngredientRepository.getQuantity(),
                                            pantryIngredientRepository.getUnit(),
                                            pantryIngredientRepository.getCreatedAt(),
                                            pantryIngredientRepository.getUpdatedAt()
        )

    }
}