package com.mealchemy.ingredient.service;
//models
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;

//repositories
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;

import com.mealchemy.ingredient.external.NutritionDataProvider;
import com.mealchemy.ingredient.external.ExternalIngredientItemResponse;

//dtos
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;
import com.mealchemy.ingredient.dto.IngredientSearchResponse;

import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; //need to annotate any function that makes an update to the database
import org.springframework.web.server.ResponseStatusException;

@Service
public class IngredientCatalogueService {

    private final IngredientCatalogueRepository ingredientCatalogueRepository;
    private final IngredientCategoryRepository ingredientCategoryRepository;
    private final NutritionDataProvider nutritionDataProvider; // adapter interface

    //constructor
    public IngredientCatalogueService(IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository, NutritionDataProvider nutritionDataProvider) {
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.ingredientCategoryRepository = ingredientCategoryRepository;
        this.nutritionDataProvider = nutritionDataProvider;
    }

    // GET request - return all ingredient catalogue items
    public List<IngredientCatalogueResponse> getIngredientCatalogue() {
        return ingredientCatalogueRepository.getIngredientCatalogueItems();
    }

    // GET request - search by name local ingredient catalogue first, if not found api call
    public List<IngredientSearchResponse> getIngredientByName(String name) {
        // local catalogue search first
        List<IngredientSearchResponse> localSearch = ingredientCatalogueRepository.getIngredientByName(name);

        if (!localSearch.isEmpty()) {
            return localSearch;
        }

        // api fallback if not found locally
        List<ExternalIngredientItemResponse> externalSearch = nutritionDataProvider.findExternalIngredient(name);

        return externalSearch.stream().map(r -> new IngredientSearchResponse(
                                                    null, //no ingId because it hasn't been saved to ingredient catalogue yet
                                                    r.name(),
                                                    null, //additional call to find category
                                                    r.sourceId(),
                                                    r.sourceApi()
                                            )).toList();
    }

    // GET - check all names already in catalogue
    public List<String> findExistingIngredientNames(List<String> names) {
        return ingredientCatalogueRepository.findExistingNames(names);
    }

    @Transactional
    public IngredientCatalogueResponse saveExternalIngredientToCatalogue(String sourceId, Integer categoryId) {
        ExternalIngredientItemResponse ingDetails = nutritionDataProvider.getExternalIngredientDetails(sourceId);

        IngredientCategory category = null;
        if (categoryId != null) { //frontend on second call - user has manually picked a category
            category = ingredientCategoryRepository.findById(categoryId).orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unkown categoryId"));
        }
        else {
            // id is null, therefore first attempt 
            category = findOrCreateCategory(ingDetails);
        }

        IngredientCatalogue newItem = new IngredientCatalogue();
        newItem.setName(ingDetails.name());
        newItem.setCategoryId(category.getCategoryId());
        newItem.setCalories(ingDetails.caloriesKCal());
        newItem.setProtein(ingDetails.proteinG());
        newItem.setCarbs(ingDetails.carbsG());
        newItem.setFat(ingDetails.fatG());
        newItem.setFibre(ingDetails.fibreG());
        newItem.setSodium(ingDetails.sodiumMg());
        newItem.setSourceApi(ingDetails.sourceApi());
        newItem.setSourceId(ingDetails.sourceId());

        try {
            IngredientCatalogue saved = ingredientCatalogueRepository.save(newItem);
            return new IngredientCatalogueResponse(
                saved.getIngId(),
                saved.getName(),
                category.getCategoryName()
            );
        }
        catch (DataIntegrityViolationException e) { // if 2 concurrent users insert same ingredient into catalogue at same time

            IngredientCatalogue existing = ingredientCatalogueRepository.findByName(ingDetails.name()).orElseThrow(() -> e);

            String existingCategoryName = ingredientCategoryRepository.findById(existing.getCategoryId()).map(IngredientCategory::getCategoryName)
                                                                                                        .orElse(null);

            return new IngredientCatalogueResponse(
                existing.getIngId(),
                existing.getName(),
                existingCategoryName
            );
        }
    }

    private IngredientCategory findOrCreateCategory(ExternalIngredientItemResponse ingDetails) {
        String categoryName = ingDetails.categoryName();

        // usda gave no category - controller catches and frontend must tell user to select a category
        if (categoryName == null) {
            throw new CategoryRequiredException(ingDetails.sourceId(), ingDetails.name());
        }

        List<IngredientCategory> catMatches = ingredientCategoryRepository.findByCatNameFuzzy(categoryName);

        if (!catMatches.isEmpty()) {
            return catMatches.get(0); //return first match
        }

        IngredientCategory newCategory = new IngredientCategory();
        newCategory.setCategoryName(categoryName);
        return ingredientCategoryRepository.save(newCategory);
    }
}