package com.mealchemy.category.service;

// model
import com.mealchemy.category.model.IngredientCategory;
// repository
import com.mealchemy.category.repository.IngredientCategoryRepository;
// dto
import com.mealchemy.category.dto.IngredientCategoryResponse;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service 
public class IngredientCategoryService {

    private final IngredientCategoryRepository ingredientCategoryRepository;
    
    public IngredientCategoryService(IngredientCategoryRepository ingredientCategoryRepository) {
        this.ingredientCategoryRepository = ingredientCategoryRepository;
    }

    // GET - all IngredientCategory available
    public List<IngredientCategoryResponse> getAllIngredientCategoryOptions() {
        List<IngredientCategory> allCategories = ingredientCategoryRepository.findAll();

        return allCategories.stream()
                            .map(category -> new IngredientCategoryResponse(
                                category.getCategoryId(),
                                category.getCategoryName()
                            ))
                            .collect(Collectors.toList());
    }
}