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
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeUpdateRequest;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.event.RecipePhotoCleanupEvent;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.service.VaultFolderRecipeService;

@Service
public class RecipeService
{
    private final RecipeRepository recipeRepository;

    private final IngredientCatalogueRepository ingredientCatalogueRepository;

    private final FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    private final VaultFolderRepository vaultFolderRepository;

    private final VaultFolderRecipeService vaultFolderRecipeService;

    // lets it annouce that an old photo needs cleanup without making RecipeService directly responsible for GC Storage
    private final ApplicationEventPublisher eventPublisher;

    public RecipeService(RecipeRepository recipeRepository, IngredientCatalogueRepository ingredientCatalogueRepository, 
        FlavourProfileOptionsRepository flavourProfileOptionsRepository, VaultFolderRepository vaultFolderRepository, 
        VaultFolderRecipeService vaultFolderRecipeService, ApplicationEventPublisher eventPublisher)
    {
        this.recipeRepository = recipeRepository;
        this.ingredientCatalogueRepository = ingredientCatalogueRepository;
        this.flavourProfileOptionsRepository = flavourProfileOptionsRepository;
        this.vaultFolderRepository = vaultFolderRepository;
        this.vaultFolderRecipeService = vaultFolderRecipeService;
        this.eventPublisher = eventPublisher;
    }

    // Get all recipes
    // modified to call query with user ID instead of unrestricted findAll
    public List<RecipeResponse> getAllRecipes(Integer userId)
    {
        return recipeRepository.findAllAccessibleByUserId(userId).stream().map(RecipeResponse::from).collect(Collectors.toList());
    }

    // Get all community publishe recipes (global vault)
    public List<RecipeResponse> getAllCommunityPublishedRecipes()
    {
        return recipeRepository.findByIsCommunityPublishedTrue().stream().map(RecipeResponse::from).collect(Collectors.toList());
    }

    // Get a single recipe by Id
    // Modified to find accessible recipe, returns it when acess allowed, checkif reciepe exists if acess fails, returns 403 if exists but not allowed access, returns 404 when it doesnt exist.
    public RecipeResponse getRecipeById(Integer id, Integer userId)
    {
        Optional<Recipe> accessibleRecipe = recipeRepository.findAccessibleByIdAndUserId(id, userId);

        if (accessibleRecipe.isEmpty())
        {
            if (recipeRepository.existsById(id))
            {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not have permission to view this recipe.");
            }

            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.");
        }

        Recipe recipeForReturn = accessibleRecipe.get();
        return RecipeResponse.from(recipeForReturn);
    }

    // Post to create a new fresh recipe
    @Transactional
    public RecipeResponse createRecipe(RecipeRequest request, Integer ownerId)
    {
        if (request.folderId() == null)
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A folder must be specified when creating a recipe.");
        }

        if (!flavourProfileOptionsRepository.existsByValue(request.cuisineType()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cuisine type is invalid.");
        }

        validateFolderIsInPrivateVault(request.folderId(), ownerId);

        Recipe recipeForReturn = mapRequestToEntity(request, ownerId);
        Recipe saved = recipeRepository.save(recipeForReturn);

        vaultFolderRecipeService.createVaultFolderRecipe(
            new VaultFolderRecipeRequest(request.folderId(), saved.getRecipeId()),
            ownerId,
            request.folderId()
        );

        return RecipeResponse.from(saved);
    }

    // Post to create a new recipe from an existing one
    @Transactional
    public RecipeResponse createFromFullRecipe(RecipeFullRequest request, Integer ownerId, Integer sourceRecipeId)
    {
        if (!flavourProfileOptionsRepository.existsByValue(request.cuisineType()))
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cuisine type is invalid.");
        }
        
        validateFolderIsInPrivateVault(request.folderId(), ownerId);

        Recipe recipeForReturn = mapRequestToEntity(request, ownerId);

        if (sourceRecipeId != null)
        {
            Recipe sourceRecipe = recipeRepository.findById(sourceRecipeId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Source recipe not found."));

            recipeForReturn.setParentRecipe(sourceRecipe);
        }

        List<RecipeIngredient> ingredients = mapIngredientRequests(request.ingredients(), recipeForReturn);

        List<RecipeStep> steps = mapStepRequests(request.steps(), recipeForReturn);

        recipeForReturn.setIngredients(ingredients);
        recipeForReturn.setSteps(steps);

        Recipe saved = recipeRepository.save(recipeForReturn);

        vaultFolderRecipeService.createVaultFolderRecipe(
            new VaultFolderRecipeRequest(request.folderId(), saved.getRecipeId()),
            ownerId,
            request.folderId()
        );

        return RecipeResponse.from(saved);
    }

    // Put to update an existing recipe
    @Transactional
    public RecipeResponse updateRecipe(int id, RecipeUpdateRequest request, Integer ownerId)
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

        String oldPhotoUrl = recipeForReturn.getPhotoUrl();

        if (request.removePhoto() && request.photoUrl() != null && !request.photoUrl().isBlank())
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A replacement photo URL cannot be supplied when removing the photo.");
        }

        String newPhotoUrl = oldPhotoUrl;
        if (request.removePhoto())
        {
            newPhotoUrl = null;
        }
        else if (request.photoUrl() != null)
        {
            if (request.photoUrl().isBlank())
            {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Photo URL cannot be blank.");
            }
            newPhotoUrl = request.photoUrl();
        }

        List<RecipeIngredient> ingredients = request.ingredients() == null
            ? null
            : mapIngredientRequests(request.ingredients(), recipeForReturn);
        List<RecipeStep> steps = request.steps() == null
            ? null
            : mapStepRequests(request.steps(), recipeForReturn);

        recipeForReturn.setTitle(request.title());
        recipeForReturn.setDescription(request.description());
        recipeForReturn.setCuisineType(request.cuisineType());
        recipeForReturn.setPrepTimeMins(request.prepTimeMins());
        recipeForReturn.setCookingTimeMins(request.cookingTimeMins());
        recipeForReturn.setServingSize(request.servingSize());
        recipeForReturn.setPhotoUrl(newPhotoUrl);
        recipeForReturn.setVideoUrl(request.videoUrl());
        recipeForReturn.setExternalUrl(request.externalUrl());
        recipeForReturn.setIsCommunityPublished(request.isCommunityPublished());

        if (ingredients != null)
        {
            recipeForReturn.getIngredients().clear();
        }
        if (steps != null)
        {
            recipeForReturn.getSteps().clear();
        }
        if (ingredients != null || steps != null)
        {
            recipeRepository.saveAndFlush(recipeForReturn);
        }
        if (ingredients != null)
        {
            recipeForReturn.getIngredients().addAll(ingredients);
        }
        if (steps != null)
        {
            recipeForReturn.getSteps().addAll(steps);
        }

        Recipe saved = recipeRepository.save(recipeForReturn);
        publishPhotoCleanupWhenChanged(id, oldPhotoUrl, newPhotoUrl);

        return RecipeResponse.from(saved);
    }

    // Delete a specific vault using id
    @Transactional
    public void deleteRecipe(int id, Integer ownerId)
    {
        Recipe recipeForDeletion = recipeRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found."));

        if (!recipeForDeletion.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of this recipe can delete it.");
        }

        recipeRepository.deleteById(id);
        publishPhotoCleanup(id, recipeForDeletion.getPhotoUrl());
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

    private List<RecipeIngredient> mapIngredientRequests(
        List<RecipeIngredientRequest> requests,
        Recipe recipe
    )
    {
        return requests.stream().map(request -> {
            if (!ingredientCatalogueRepository.existsById(request.ingId()))
            {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "One of the ingredients you want to add does not exist.");
            }

            RecipeIngredient recipeIngredient = new RecipeIngredient();
            recipeIngredient.setIngId(request.ingId());
            recipeIngredient.setQuantity(request.quantity());
            recipeIngredient.setUnit(request.unit());
            recipeIngredient.setSortOrder(request.sortOrder());
            recipeIngredient.setRecipe(recipe);
            return recipeIngredient;
        }).toList();
    }

    private List<RecipeStep> mapStepRequests(
        List<RecipeStepRequest> requests,
        Recipe recipe
    )
    {
        return requests.stream().map(request -> {
            RecipeStep recipeStep = new RecipeStep();
            recipeStep.setStepNr(request.stepNr());
            recipeStep.setContent(request.content());
            recipeStep.setRecipe(recipe);
            return recipeStep;
        }).toList();
    }

    /* Helper */

    private void publishPhotoCleanupWhenChanged(
        Integer recipeId,
        String oldPhotoUrl,
        String newPhotoUrl
    )
    {
        if (!Objects.equals(oldPhotoUrl, newPhotoUrl))
        {
            publishPhotoCleanup(recipeId, oldPhotoUrl);
        }
    }
    //publish clean up event for old photo
    //recipe deleted from db, url therefore deleted, then only photo object in storage requested for deletion. Ensures DB correctness, recipe url won't point to an already deleted GCS object.
    private void publishPhotoCleanup(Integer recipeId, String photoUrl)
    {
        if (photoUrl != null && !photoUrl.isBlank())
        {
            eventPublisher.publishEvent(new RecipePhotoCleanupEvent(recipeId, photoUrl));
        }
    }

    private void validateFolderIsInPrivateVault(Integer folderId, Integer ownerId)
{
    VaultFolder folder = vaultFolderRepository.findById(folderId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

    Vault vault = folder.getVault();

    if (!vault.getOwnerId().equals(ownerId) || !vault.getVaultType().equals(VaultType.PRIVATE))
    {
        throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Recipes can only be added to a folder in your private vault.");
    }
}
}
