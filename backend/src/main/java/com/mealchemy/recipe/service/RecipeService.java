package com.mealchemy.recipe.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;

@Service
public class RecipeService
{
    private final RecipeRepository recipeRepository;

    private final IngredientCatalogueRepository ingredientCatalogueRepository;

    private final FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    public RecipeService(RecipeRepository recipeRepository, IngredientCatalogueRepository ingredientCatalogueRepository, FlavourProfileOptionsRepository flavourProfileOptionsRepository)
    {
        this.recipeRepository = recipeRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.flavourProfileOptionsRepository = flavourProfileOptionsRepository;
    }

    // Get all recipes
    public List<RecipeResponse> getAllRecipes()
    {
        return recipeRepository.findAll().stream().map(RecipeResponse::from).collect(Collectors.toList());
    }

    // Get all community publishe recipes (global vault)
    public List<RecipeResponse> getAllCommunityPublishedRecipes()
    {
        return recipeRepository.findByIsCommunityPublishedTrue().stream().map(RecipeResponse::from).collect(Collectors.toList());
    }

    // Get a single recipe by Id
    public RecipeResponse getRecipeById(Integer id)
    {
        Recipe recipeForReturn = recipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
        return RecipeResponse.from(recipeForReturn);
    }

    // Post to create a new fresh recipe
    public RecipeResponse createRecipe(RecipeRequest request, Integer ownerId)
    {
        if (!flavourProfileOptionsRepository.existsByValue(request.cuisineType()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cuisine type is invalid.");
        }

        Recipe recipeForReturn = mapRequestToEntity(request, ownerId);

        return RecipeResponse.from(recipeRepository.save(recipeForReturn));
    }

    // Post to create a new recipe from an existing one
    public RecipeResponse createFromFullRecipe(RecipeFullRequest request, Integer ownerId, Integer sourceRecipeId)
    {
        if (!flavourProfileOptionsRepository.existsByValue(request.cuisineType()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cuisine type is invalid.");
        }
        
        Recipe recipeForReturn = mapRequestToEntity(request, ownerId);

        if (sourceRecipeId != null)
        {
            Recipe sourceRecipe = recipeRepository.findById(sourceRecipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Source recipe not found."));

            recipeForReturn.setParentRecipe(sourceRecipe);
        }

        List<RecipeIngredient> ingredients = request.ingredients().stream().map(i -> {
            
            if (!ingredientCatalogueRepository.existsById(i.ingId()))
            {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "One of the ingredients you want to add does not exist.");
            }
            
            RecipeIngredient recipeIngredient = new RecipeIngredient();
            recipeIngredient.setIngId(i.ingId());
            recipeIngredient.setQuantity(i.quantity());
            recipeIngredient.setUnit(i.unit());
            recipeIngredient.setSortOrder(i.sortOrder());
            recipeIngredient.setRecipe(recipeForReturn);
            return recipeIngredient;
        }).toList();

        List<RecipeStep> steps = request.steps().stream().map(i -> {
            RecipeStep recipeStep = new RecipeStep();
            recipeStep.setStepNr(i.stepNr());
            recipeStep.setContent(i.content());
            recipeStep.setRecipe(recipeForReturn);
            return recipeStep;
        }).toList();

        recipeForReturn.setIngredients(ingredients);
        recipeForReturn.setSteps(steps);

        return RecipeResponse.from(recipeRepository.save(recipeForReturn));
    }

    // Put to update an existing recipe
    public RecipeResponse updateRecipe(int id, RecipeRequest request, Integer ownerId)
    {
        Recipe recipeForReturn = recipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));
        
        if (!recipeForReturn.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can edit it.");
        }

        if (!flavourProfileOptionsRepository.existsByValue(request.cuisineType()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cuisine type is invalid.");
        }

        recipeForReturn.setTitle(request.title());
        recipeForReturn.setDescription(request.description());
        recipeForReturn.setCuisineType(request.cuisineType());
        recipeForReturn.setPrepTimeMins(request.prepTimeMins());
        recipeForReturn.setCookingTimeMins(request.cookingTimeMins());
        recipeForReturn.setServingSize(request.servingSize());
        recipeForReturn.setPhotoUrl(request.photoUrl());
        recipeForReturn.setVideoUrl(request.videoUrl());
        recipeForReturn.setExternalUrl(request.externalUrl());
        recipeForReturn.setIsCommunityPublished(request.isCommunityPublished());

        return RecipeResponse.from(recipeRepository.save(recipeForReturn));
    }

    // Delete a specific vault using id
    public void deleteRecipe(int id, Integer ownerId)
    {
        Recipe recipeForDeletion = recipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeForDeletion.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can delete it.");
        }

        recipeRepository.deleteById(id);
    }

    /* Mapping functions */

    private Recipe mapRequestToEntity(RecipeRequest request, Integer ownerId)
    {
        Recipe recipe = new Recipe();

        recipe.setOwnerId(ownerId);
        recipe.setTitle(request.title());
        recipe.setDescription(request.description());
        recipe.setCuisineType(request.cuisineType());
        recipe.setPrepTimeMins(request.prepTimeMins());
        recipe.setCookingTimeMins(request.cookingTimeMins());
        recipe.setServingSize(request.servingSize());
        recipe.setPhotoUrl(request.photoUrl());
        recipe.setVideoUrl(request.videoUrl());
        recipe.setExternalUrl(request.externalUrl());
        recipe.setIsCommunityPublished(request.isCommunityPublished());

        return recipe;
    }

    private Recipe mapRequestToEntity(RecipeFullRequest request, Integer ownerId)
    {
        Recipe recipe = new Recipe();

        recipe.setOwnerId(ownerId);
        recipe.setTitle(request.title());
        recipe.setDescription(request.description());
        recipe.setCuisineType(request.cuisineType());
        recipe.setPrepTimeMins(request.prepTimeMins());
        recipe.setCookingTimeMins(request.cookingTimeMins());
        recipe.setServingSize(request.servingSize());
        recipe.setPhotoUrl(request.photoUrl());
        recipe.setVideoUrl(request.videoUrl());
        recipe.setExternalUrl(request.externalUrl());
        recipe.setIsCommunityPublished(request.isCommunityPublished());

        return recipe;
    }
}