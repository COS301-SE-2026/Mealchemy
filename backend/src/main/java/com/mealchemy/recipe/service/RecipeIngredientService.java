package com.mealchemy.recipe.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeIngredientResponse;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.profile.repository.UserProfileRepository;
import com.mealchemy.profile.model.UserProfile;
import com.mealchemy.shared.enums.PreferredUnit;
import com.mealchemy.shared.unitconverter.UnitConverter;

@Service
public class RecipeIngredientService 
{
    private final RecipeIngredientRepository recipeIngredientRepository;

    private final RecipeRepository recipeRepository;

    private final IngredientCatalogueRepository ingredientCatalogueRepository;

    private final UserProfileRepository userProfileRepository;

    public RecipeIngredientService(RecipeIngredientRepository recipeIngredientRepository, RecipeRepository recipeRepository, IngredientCatalogueRepository ingredientCatalogueRepository, UserProfileRepository userProfileRepository)
    {
        this.recipeIngredientRepository = recipeIngredientRepository;
        this.recipeRepository = recipeRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.userProfileRepository = userProfileRepository;
    }

    // Retrieve all ingredients relating to a specific recipe
    public List<RecipeIngredientResponse> getAllIngredientsByRecipeId(Integer recipeId, Integer userId)
    {
        PreferredUnit preferredUnit = userProfileRepository.findByUserId(userId).map(UserProfile::getPreferredUnit)
                                                                               .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found."));


        List<RecipeIngredient> recipeIngredients = recipeIngredientRepository.findByRecipe_RecipeId(recipeId);

        List<Integer> ingIds = recipeIngredients.stream().map(RecipeIngredient::getIngId).distinct().toList();

        Map<Integer, String> ingredientNamesById = ingredientCatalogueRepository.findAllById(ingIds).stream()
        .collect(Collectors.toMap(IngredientCatalogue::getIngId, IngredientCatalogue::getName));

        return recipeIngredients.stream().map(ri -> {
            UnitConverter.NormalisedQuantity displayQuantity = UnitConverter.convertToUsersPreferredUnit(ri.getQuantity(), ri.getUnit(), preferredUnit);

            return RecipeIngredientResponse.from(ri, ingredientNamesById.getOrDefault(ri.getIngId(), "Unknown Ingredient"), displayQuantity);
        })
        .collect(Collectors.toList());
    }

    // Create a new ingredient for a specific recipe
    public RecipeIngredientResponse createRecipeIngredient(RecipeIngredientRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients.");
        }

        IngredientCatalogue ingredientCatalogue = ingredientCatalogueRepository.findById(request.ingId())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "The ingredient you want to add does not exist."));

        RecipeIngredient recipeIngredientForReturn = mapRequestToEntity(request, recipeToCheck);

        RecipeIngredient saved = recipeIngredientRepository.save(recipeIngredientForReturn);
        
        return RecipeIngredientResponse.from(saved, ingredientCatalogue.getName());
    }

    // Update a specific ingredient in an existing recipe
    public RecipeIngredientResponse updateRecipeIngredient(int id, RecipeIngredientRequest request, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients.");
        }

        RecipeIngredient recipeIngredientForReturn = recipeIngredientRepository.findById(id)
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found."));
        
        if (!recipeIngredientForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Ingredient must be part of the recipe.");
        }

        IngredientCatalogue ingredientCatalogue = ingredientCatalogueRepository.findById(request.ingId())
        .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "The ingredient you want to change to does not exist."));

        // Normalise the quantity and unit
        UnitConverter.NormalisedQuantity normalised = UnitConverter.normaliseIngredient(request.quantity(), request.unit());

        recipeIngredientForReturn.setIngId(request.ingId());
        recipeIngredientForReturn.setQuantity(normalised.quantity());
        recipeIngredientForReturn.setUnit(normalised.unit());
        recipeIngredientForReturn.setSortOrder(request.sortOrder());

        RecipeIngredient saved = recipeIngredientRepository.save(recipeIngredientForReturn);
        return RecipeIngredientResponse.from(saved, ingredientCatalogue.getName());
    }

    // Delete a specific ingredient in an existing recipe
    public void deleteRecipeIngredient(int id, Integer recipeId, Integer ownerId)
    {
        Recipe recipeToCheck = recipeRepository.findById(recipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can modify its ingredients.");
        }

        RecipeIngredient recipeIngredientForReturn = recipeIngredientRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Ingredient not found."));
        
        if (!recipeIngredientForReturn.getRecipe().getRecipeId().equals(recipeId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Ingredient must be part of the recipe.");
        }

        recipeIngredientRepository.deleteById(id);
    }

    /* Mapping functions */

    public RecipeIngredient mapRequestToEntity(RecipeIngredientRequest request, Recipe recipe)
    {
        RecipeIngredient recipeIngredient = new RecipeIngredient();

        UnitConverter.NormalisedQuantity normalised = UnitConverter.normaliseIngredient(request.quantity(), request.unit());

        recipeIngredient.setRecipe(recipe);
        recipeIngredient.setIngId(request.ingId());
        recipeIngredient.setQuantity(normalised.quantity());
        recipeIngredient.setUnit(normalised.unit());
        recipeIngredient.setSortOrder(request.sortOrder());

        return recipeIngredient;
    }
}
