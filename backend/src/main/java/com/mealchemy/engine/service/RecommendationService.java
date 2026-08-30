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
import com.mealchemy.engine.dto.CandidatePoolEntryRequest;

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

    private List<PantryEntryRequest> buildPantryEntries(Integer userId)
    {
        List<PantryIngredient> pantryItems = pantryIngredientRepository.findByUserId(userId);

        // Resolve categoryId per ingredient
        List<Integer> ingIds = pantryItems.stream().map(PantryIngredient::getIngredientId).distinct().toList();
        Map<Integer, IngredientCatalogue> catalogueById = ingredientCatalogueRepository.findAllById(ingIds).stream().collect(Collectors.toMap(IngredientCatalogue::getIngId, ic -> ic));

        // Resolve shelf life per category
        List<Integer> categoryIds = catalogueById().values().stream().map(IngredientCatalogue::getCategoryId).distinct().toList();
        Map<Integer, IngredientCategory> categoryById = ingredientCategoryRepository.findAllById(categoryIds).stream().collect(Collectors.toMap(IngredientCategory::getCategoryId, c -> c));

        // Map each pantry item
        return pantryItems.stream().map(
            item -> {
                IngredientCatalogue catalogue = catalogueById.get(item.getIngredientId());
                IngredientCategory category = categoryById.get(catalogue.getCategoryId());

                Integer shelfLifeDays = resolveShelfLifeDays(category);

                return new PantryEntryRequest(
                    item.getIngredientId(),
                    catalogue.getCategoryId(),
                    item.getQuantity(),
                    item.getUnit(),
                    item.getCreatedAt(),
                    shelfLifeDays,
                    "FRIDGE"
                );
            }).toList();
    }

    private Integer resolveShelfLifeDays(IngredientCategory category)
    {
        Short fridge = category.getFridgeShelfLife();
        Short pantryLife = category.getPantryShelfLife();

        if(fridge != null)
        {
            return fridge.intValue();
        }
        if(pantryLife != null)
        {
            return pantryLife.intValue();
        }
        return null;
    }

    private List<CandidatePoolEntryRequest> buildCandidatePool()
    {
        List<Recipe> recipes = recipeRepository.findByIsCommunityPublishes();

        return recipes.stream().map(recipe -> new CandidatePoolEntryRequest(
            recipe.getRecipeId(),
            recipe.getTitle(),
            recipe.getCuisineType(),
            buildDietaryTags(recipe),
            buildIngredients(recipe),
            null
        )).toList();
    }

    private List<String> buildDietaryTags(Recipe recipe)
    {
        List<RecipeTags> recipeTags = recipeTagsRepository.findByRecipeRecipeId(recipe.getRecipeId());

        return recipeTags.stream().map(RecipeTags::getTag).filter(Tags::getIsDietary).map(Tags::getTagName).toList();
    }
}
