package com.mealchemy.recipe.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import org.springframework.context.ApplicationEventPublisher;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;

/* Import classes */
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.model.IngredientCategoryRepository;
import com.mealchemy.engine.dto.PantryEntryRequest; 

@Service
public class RecommendationService {
    private final PantryIngredientRepository pantryIngredientRepository;
    private final IngredientCatalogueRepository ingredientCatalogueRepository;
    private final IngredientCategoryRepository ingredientCategoryRepository;

    public RecommendationService(PantryIngredientRepository pantryIngredientRepository, 
        IngredientCatalogueRepository ingredientCatalogueRepository, IngredientCategoryRepository ingredientCategoryRepository)
    {
        this.pantryIngredientRepository = pantryIngredientRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.ingredientCategoryRepository = ingredientCategoryRepository;
    }
}
