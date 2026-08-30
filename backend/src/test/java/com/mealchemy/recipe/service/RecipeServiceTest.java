package com.mealchemy.recipe.service;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.context.ApplicationEventPublisher;

import java.time.OffsetDateTime;
import java.util.*;
import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/* Import classes */

import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient;
import com.mealchemy.recipe.model.RecipeStep;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.recipe.dto.RecipeRequest;
import com.mealchemy.recipe.dto.RecipeFullRequest;
import com.mealchemy.recipe.dto.RecipeUpdateRequest;
import com.mealchemy.recipe.dto.RecipeResponse;
import com.mealchemy.recipe.dto.RecipeIngredientRequest;
import com.mealchemy.recipe.dto.RecipeStepRequest;
import com.mealchemy.recipe.event.RecipePhotoCleanupEvent;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.service.VaultFolderRecipeService;
import com.mealchemy.shared.enums.VaultType;

@ExtendWith(MockitoExtension.class)
public class RecipeServiceTest {
    @Mock
    private RecipeRepository recipeRepository;

    @Mock
    private IngredientCatalogueRepository ingredientCatalogueRepository;

    @Mock 
    private FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    @Mock 
    private VaultFolderRepository vaultFolderRepository;

    @Mock 
    private VaultFolderRecipeService vaultFolderRecipeService;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private RecipeService recipeService;

    private Recipe recipe;
    private Recipe sourceRecipe;
    private RecipeRequest request;
    private RecipeFullRequest fullRequest;
    private RecipeUpdateRequest updateRequest;
    private VaultFolder privateFolder;
    private Vault privateVault;

    @BeforeEach
    void setUp()
    {
        recipe = new Recipe();
        recipe.setOwnerId(1);
        recipe.setTitle("Recipe 1");
        recipe.setCuisineType("Japanese");
        ReflectionTestUtils.setField(recipe, "recipeId", 1);

        sourceRecipe = new Recipe();
        sourceRecipe.setOwnerId(1);
        sourceRecipe.setTitle("Recipe 2");
        sourceRecipe.setCuisineType("Italian");
        ReflectionTestUtils.setField(sourceRecipe, "recipeId", 2);

        privateVault = new Vault();
        privateVault.setOwnerId(1);
        privateVault.setVaultType(VaultType.PRIVATE);
        ReflectionTestUtils.setField(privateVault, "vaultId", 1);

        privateFolder = new VaultFolder();
        privateFolder.setVault(privateVault);
        privateFolder.setFolderName("My Folder");
        ReflectionTestUtils.setField(privateFolder, "folderId", 1);

        request = new RecipeRequest("Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false, 1);

        List<RecipeIngredientRequest> ingredients = List.of(
            new RecipeIngredientRequest(1, BigDecimal.valueOf(2.0), "cup", 1)
        );

        List<RecipeStepRequest> steps = List.of(
            new RecipeStepRequest(1, "Mix everything together.")
        );

        fullRequest = new RecipeFullRequest("FullReq Title", "Full Description", "Chinese", 10, 15, 2, null, null, null, false, ingredients, steps, 1);

        updateRequest = new RecipeUpdateRequest("Req Title", "Description", "Chinese", 10, 15, 2, null, false, null, null, false, null, null);
    }

    @Test
    void getAllRecipes_returnsListOfRecipes_whenFound()
    {
        when(recipeRepository.findAllAccessibleByUserId(1)).thenReturn(List.of(recipe));

        List<RecipeResponse> result = recipeService.getAllRecipes(1);

        assertNotNull(result);
        assertEquals("Recipe 1", result.get(0).title());
    }

    @Test
    void getAllRecipes_returnsEmptyList_whenNotFound()
    {
        when(recipeRepository.findAllAccessibleByUserId(1)).thenReturn(List.of());

        List<RecipeResponse> result = recipeService.getAllRecipes(1);

        assertTrue(result.isEmpty());
    }

    @Test
    void getRecipeById_returnsRecipe_whenFound()
    {
        when(recipeRepository.findAccessibleByIdAndUserId(1, 1)).thenReturn(Optional.of(recipe));

        RecipeResponse result = recipeService.getRecipeById(1, 1);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
    }

    @Test
    void getRecipeById_throwsException_whenNotFound()
    {
        when(recipeRepository.findAccessibleByIdAndUserId(99, 1)).thenReturn(Optional.empty());
        when(recipeRepository.existsById(99)).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.getRecipeById(99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void getRecipeById_throwsException_whenRecipeIsNotAccessible()
    {
        when(recipeRepository.findAccessibleByIdAndUserId(1, 2)).thenReturn(Optional.empty());
        when(recipeRepository.existsById(1)).thenReturn(true);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.getRecipeById(1, 2));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("You do not have permission to view this recipe.", ex.getReason());
    }

    @Test
    void getAllCommunityPublishedRecipes_returnsListOfRecipes_whenFound()
    {
        when(recipeRepository.findByIsCommunityPublishedTrue()).thenReturn(List.of(recipe));

        List<RecipeResponse> result = recipeService.getAllCommunityPublishedRecipes();

        assertNotNull(result);
        assertEquals("Recipe 1", result.get(0).title());
    }

    @Test
    void getAllCommunityPublishedRecipes_returnsEmptyList_whenNoneFound()
    {
        when(recipeRepository.findByIsCommunityPublishedTrue()).thenReturn(List.of());

        List<RecipeResponse> result = recipeService.getAllCommunityPublishedRecipes();

        assertTrue(result.isEmpty());
    }

    @Test
    void createRecipe_returnsCreatedRecipe_whenCuisineTypeValid()
    {
        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(request.folderId())).thenReturn(Optional.of(privateFolder));
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);
        when(vaultFolderRecipeService.createVaultFolderRecipe(any(), eq(1), eq(request.folderId()))).thenReturn(null);

        RecipeResponse result = recipeService.createRecipe(request, 1);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
        verify(recipeRepository, times(1)).save(any(Recipe.class));
        verify(vaultFolderRecipeService, times(1)).createVaultFolderRecipe(any(), eq(1), eq(request.folderId()));
    }

    @Test
    void createRecipe_throwsException_whenCuisineTypeNotValid()
    {
        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createRecipe(request, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Cuisine type is invalid.", ex.getReason());
    }

    @Test
    void createRecipe_throwsException_whenFolderIdIsNull()
    {   
        RecipeRequest noFolderRequest = new RecipeRequest("Req Title", "Description", "Chinese", 10, 15, 2, null, null, null, false, null);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createRecipe(noFolderRequest, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("A folder must be specified when creating a recipe.", ex.getReason());
    }

    @Test
    void createRecipe_throwsException_whenFolderNotFound()
    {
        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(request.folderId())).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createRecipe(request, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Folder not found.", ex.getReason());
    }

    @Test
    void createRecipe_throwsException_whenFolderNotOwnedByUser()
    {
        privateVault.setOwnerId(99);

        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(request.folderId())).thenReturn(Optional.of(privateFolder));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createRecipe(request, 1));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Recipes can only be added to a folder in your private vault.", ex.getReason());
    }

    @Test
    void createRecipe_throwsException_whenVaultNotPrivate()
    {
        privateVault.setVaultType(VaultType.SHARED);

        when(flavourProfileOptionsRepository.existsByValue(request.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(request.folderId())).thenReturn(Optional.of(privateFolder));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createRecipe(request, 1));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Recipes can only be added to a folder in your private vault.", ex.getReason());
    }

    @Test
    void createFromFullRecipe_returnsCreatedRecipe_whenSourceIdIsNull()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(fullRequest.folderId())).thenReturn(Optional.of(privateFolder));
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);
        when(ingredientCatalogueRepository.existsById(1)).thenReturn(true);
        when(vaultFolderRecipeService.createVaultFolderRecipe(any(), eq(1), eq(fullRequest.folderId()))).thenReturn(null);

        RecipeResponse result = recipeService.createFromFullRecipe(fullRequest, 1, null);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
        verify(recipeRepository, times(1)).save(any(Recipe.class));
        verify(vaultFolderRecipeService, times(1)).createVaultFolderRecipe(any(), eq(1), eq(fullRequest.folderId()));
    }

    @Test
    void createFromFullRecipe_returnsCreatedRecipe_whenSourceIdIsNotNull()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(fullRequest.folderId())).thenReturn(Optional.of(privateFolder));
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);
        when(recipeRepository.findById(2)).thenReturn(Optional.of(sourceRecipe));
        when(ingredientCatalogueRepository.existsById(1)).thenReturn(true);
        when(vaultFolderRecipeService.createVaultFolderRecipe(any(), eq(1), eq(fullRequest.folderId()))).thenReturn(null);
        
        RecipeResponse result = recipeService.createFromFullRecipe(fullRequest, 1, 2);

        assertNotNull(result);
        assertEquals("Recipe 1", result.title());
        verify(recipeRepository, times(1)).save(any(Recipe.class));
    }

    @Test
    void createFromFullRecipe_throwsException_whenCuisineTypeNotValid()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createFromFullRecipe(fullRequest, 1, null));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Cuisine type is invalid.", ex.getReason());
    }

    @Test
    void createFromFullRecipe_throwsException_whenSourceRecipeNotFound()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(fullRequest.folderId())).thenReturn(Optional.of(privateFolder));
        when(recipeRepository.findById(2)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createFromFullRecipe(fullRequest, 1, 2));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Source recipe not found.", ex.getReason());
    }

    @Test
    void createFromFullRecipe_throwsException_whenIngredientNotInCatalogue()
    {
        when(flavourProfileOptionsRepository.existsByValue(fullRequest.cuisineType())).thenReturn(true);
        when(vaultFolderRepository.findById(fullRequest.folderId())).thenReturn(Optional.of(privateFolder));
        when(ingredientCatalogueRepository.existsById(1)).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.createFromFullRecipe(fullRequest, 1, null));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("One of the ingredients you want to add does not exist.", ex.getReason());
    }

    @Test
    void updateRecipe_updatesRecipe_whenFoundOwnerAndHasValidCuisineType()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(updateRequest.cuisineType())).thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        RecipeResponse result = recipeService.updateRecipe(1, updateRequest, 1);

        assertNotNull(result);
        assertEquals("Req Title", result.title());
        verify(recipeRepository, times(1)).save(any(Recipe.class));
    }

    @Test
    void updateRecipe_publishesCleanup_whenPhotoIsReplaced()
    {
        String oldPhotoUrl = "https://storage.googleapis.com/bucket/recipes/1/old.jpg";
        String newPhotoUrl = "https://storage.googleapis.com/bucket/recipes/1/new.jpg";
        recipe.setPhotoUrl(oldPhotoUrl);
        RecipeUpdateRequest photoRequest = new RecipeUpdateRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2,
            newPhotoUrl, false, null, null, false, null, null
        );

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(photoRequest.cuisineType()))
            .thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        recipeService.updateRecipe(1, photoRequest, 1);

        verify(eventPublisher).publishEvent(
            new RecipePhotoCleanupEvent(1, oldPhotoUrl)
        );
    }

    @Test
    void updateRecipe_publishesCleanup_whenPhotoIsRemoved()
    {
        String oldPhotoUrl = "https://storage.googleapis.com/bucket/recipes/1/old.jpg";
        recipe.setPhotoUrl(oldPhotoUrl);

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        RecipeUpdateRequest removalRequest = new RecipeUpdateRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2,
            null, true, null, null, false, null, null
        );

        when(flavourProfileOptionsRepository.existsByValue(removalRequest.cuisineType()))
            .thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        recipeService.updateRecipe(1, removalRequest, 1);

        verify(eventPublisher).publishEvent(
            new RecipePhotoCleanupEvent(1, oldPhotoUrl)
        );
    }

    @Test
    void updateRecipe_doesNotPublishCleanup_whenPhotoIsUnchanged()
    {
        String photoUrl = "https://storage.googleapis.com/bucket/recipes/1/photo.jpg";
        recipe.setPhotoUrl(photoUrl);
        RecipeUpdateRequest photoRequest = new RecipeUpdateRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2,
            photoUrl, false, null, null, false, null, null
        );

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(photoRequest.cuisineType()))
            .thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        recipeService.updateRecipe(1, photoRequest, 1);

        verifyNoInteractions(eventPublisher);
    }

    @Test
    void updateRecipe_preservesPhotoIngredientsAndSteps_whenFieldsAreOmitted()
    {
        String photoUrl = "https://storage.googleapis.com/bucket/recipes/1/photo.jpg";
        recipe.setPhotoUrl(photoUrl);

        RecipeIngredient existingIngredient = new RecipeIngredient();
        existingIngredient.setRecipe(recipe);
        existingIngredient.setIngId(1);
        existingIngredient.setQuantity(BigDecimal.ONE);
        existingIngredient.setUnit("cup");
        existingIngredient.setSortOrder(1);
        recipe.getIngredients().add(existingIngredient);

        RecipeStep existingStep = new RecipeStep();
        existingStep.setRecipe(recipe);
        existingStep.setStepNr(1);
        existingStep.setContent("Existing step");
        recipe.getSteps().add(existingStep);

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(updateRequest.cuisineType()))
            .thenReturn(true);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        recipeService.updateRecipe(1, updateRequest, 1);

        assertEquals(photoUrl, recipe.getPhotoUrl());
        assertEquals(1, recipe.getIngredients().size());
        assertEquals(1, recipe.getSteps().size());
        verify(recipeRepository, never()).saveAndFlush(any(Recipe.class));
        verifyNoInteractions(eventPublisher);
    }

    @Test
    void updateRecipe_replacesIngredientsAndSteps_whenFieldsAreProvided()
    {
        RecipeUpdateRequest fullUpdateRequest = new RecipeUpdateRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2,
            null, false, null, null, false,
            List.of(new RecipeIngredientRequest(1, BigDecimal.valueOf(3), "tbsp", 0)),
            List.of(new RecipeStepRequest(1, "Replacement step"))
        );

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(fullUpdateRequest.cuisineType()))
            .thenReturn(true);
        when(ingredientCatalogueRepository.existsById(1)).thenReturn(true);
        when(recipeRepository.saveAndFlush(any(Recipe.class))).thenReturn(recipe);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        recipeService.updateRecipe(1, fullUpdateRequest, 1);

        assertEquals(1, recipe.getIngredients().size());
        assertEquals("tbsp", recipe.getIngredients().get(0).getUnit());
        assertEquals(1, recipe.getSteps().size());
        assertEquals("Replacement step", recipe.getSteps().get(0).getContent());
        verify(recipeRepository).saveAndFlush(recipe);
    }

    @Test
    void updateRecipe_clearsIngredientsAndSteps_whenEmptyListsAreProvided()
    {
        recipe.getIngredients().add(new RecipeIngredient());
        recipe.getSteps().add(new RecipeStep());
        RecipeUpdateRequest clearRequest = new RecipeUpdateRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2,
            null, false, null, null, false, List.of(), List.of()
        );

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(clearRequest.cuisineType())).thenReturn(true);
        when(recipeRepository.saveAndFlush(any(Recipe.class))).thenReturn(recipe);
        when(recipeRepository.save(any(Recipe.class))).thenReturn(recipe);

        recipeService.updateRecipe(1, clearRequest, 1);

        assertTrue(recipe.getIngredients().isEmpty());
        assertTrue(recipe.getSteps().isEmpty());
        verify(recipeRepository).saveAndFlush(recipe);
    }

    @Test
    void updateRecipe_throwsException_whenRemovingAndReplacingPhoto()
    {
        RecipeUpdateRequest invalidRequest = new RecipeUpdateRequest(
            "Req Title", "Description", "Chinese", 10, 15, 2,
            "https://storage.googleapis.com/bucket/recipes/1/new.jpg",
            true, null, null, false, null, null
        );

        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(invalidRequest.cuisineType()))
            .thenReturn(true);

        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> recipeService.updateRecipe(1, invalidRequest, 1)
        );

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals(
            "A replacement photo URL cannot be supplied when removing the photo.",
            ex.getReason()
        );
        verify(recipeRepository, never()).save(any(Recipe.class));
    }

    @Test
    void updateRecipe_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.updateRecipe(99, updateRequest, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void updateRecipe_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.updateRecipe(1, updateRequest, 99));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can edit it.", ex.getReason());
    }

    @Test
    void updateRecipe_throwsException_whenCuisineTypeNotValid()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        when(flavourProfileOptionsRepository.existsByValue(updateRequest.cuisineType())).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.updateRecipe(1, updateRequest, 1));

        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
        assertEquals("Cuisine type is invalid.", ex.getReason());
    }

    @Test
    void deleteRecipe_callsDeleteById_whenFoundAndOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        doNothing().when(recipeRepository).deleteById(1);

        recipeService.deleteRecipe(1, 1);

        verify(recipeRepository, times(1)).deleteById(1);
    }

    @Test
    void deleteRecipe_publishesCleanup_whenRecipeHasPhoto()
    {
        String photoUrl = "https://storage.googleapis.com/bucket/recipes/1/photo.jpg";
        recipe.setPhotoUrl(photoUrl);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));

        recipeService.deleteRecipe(1, 1);

        verify(recipeRepository).deleteById(1);
        verify(eventPublisher).publishEvent(new RecipePhotoCleanupEvent(1, photoUrl));
    }

    @Test
    void deleteRecipe_throwsException_whenRecipeNotFound()
    {
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.deleteRecipe(99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Recipe not found.", ex.getReason());
    }

    @Test
    void deleteRecipe_throwsException_whenNotOwner()
    {
        when(recipeRepository.findById(1)).thenReturn(Optional.of(recipe));
        
        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> recipeService.deleteRecipe(1, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only the owner of this recipe can delete it.", ex.getReason());
    }
}
