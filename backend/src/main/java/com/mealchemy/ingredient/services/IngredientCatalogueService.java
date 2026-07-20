package com.mealchemy.ingredient.service;
//models
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;

//repositories
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;


import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database

//dtos
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;

import java.util.List;
import java.util.Optional;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class IngredientCatalogueService {

    private final IngredientCatalogueRepository ingredientCatalogueRepository;

    //constructor
    public IngredientCatalogueService(IngredientCatalogueRepository ingredientCatalogueRepository) {
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
    }

    // GET request - return all ingredient catalogue items
    public List<IngredientCatalogueResponse> getIngredientCatalogue() {
        return ingredientCatalogueRepository.getIngredientCatalogueItems();
    }

    // GET request - search by name
    public List<IngredientCatalogueResponse> getIngredientByName(String name) {
        return ingredientCatalogueRepository.getIngredientByName(name);
    }
}