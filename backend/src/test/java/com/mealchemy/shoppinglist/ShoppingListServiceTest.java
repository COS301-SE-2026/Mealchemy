// unit testing for shopping list

package com.mealchemy.shoppinglist;

//dtos
import com.mealchemy.shoppinglist.dto.CreateShoppingListItemRequest;
import com.mealchemy.shoppinglist.dto.CreateShoppingListRequest;
import com.mealchemy.shoppinglist.dto.PantryRecipeComparisonRequest;
import com.mealchemy.shoppinglist.dto.PurchasedUpdateRequest;
import com.mealchemy.shoppinglist.dto.ShoppingListResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListItemResponse;
import com.mealchemy.shoppinglist.dto.ShoppingListWithItemsResponse;
import com.mealchemy.shoppinglist.dto.UpdateShoppingListItemRequest;
import com.mealchemy.shoppinglist.dto.UpdateShoppingListRequest;
import com.mealchemy.shoppinglist.dto.DeleteBatchItemsRequest;
import com.mealchemy.shoppinglist.dto.CompleteShopResponse;
import com.mealchemy.shoppinglist.dto.AddRecipeToShoppingListRequest;

//models
import com.mealchemy.shoppinglist.model.ShoppingList;
import com.mealchemy.shoppinglist.model.ShoppingListItem;
import com.mealchemy.shared.enums.ShoppingListStatus;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.model.RecipeIngredient; // can get recipeId from recipe ingredients table
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.profile.model.UserProfile;

//repositories
import com.mealchemy.shoppinglist.repository.ShoppingListRepository;
import com.mealchemy.shoppinglist.repository.ShoppingListItemRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.recipe.repository.RecipeIngredientRepository;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.profile.repository.UserProfileRepository;

// import service
import com.mealchemy.shoppinglist.service.ShoppingListService;

import com.mealchemy.shared.enums.PreferredUnit;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.ArgumentCaptor;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ShoppingListServiceTest {
    // @Mock - create fake version of dependency
    @Mock private ShoppingListRepository shoppingListRepository;
    @Mock private ShoppingListItemRepository shoppingListItemRepository;
    @Mock private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Mock private IngredientCategoryRepository ingredientCategoryRepository;
    @Mock private PantryIngredientRepository pantryIngredientRepository;
    @Mock private RecipeRepository recipeRepository;
    @Mock private RecipeIngredientRepository recipeIngredientRepository;
    @Mock private VaultFolderRecipeRepository vaultFolderRecipeRepository;
    @Mock private VaultMemberRepository vaultMemberRepository;
    @Mock private UserProfileRepository userProfileRepository; 
    
    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private ShoppingListService shoppingListService;

    private ShoppingList existingShoppingList;
    private ShoppingListItem existingShoppingListItem;
    private IngredientCatalogue catalogueInstance;
    private IngredientCategory categoryInstance;
    private Recipe existingRecipe;
    private PantryIngredient existingPantryIngredient;
    private UserProfile userProfile;

    // requests that have bodies that need to be mocked
    private CreateShoppingListRequest createShoppingListRequest;
    private UpdateShoppingListRequest updateShoppingListRequest;
    private CreateShoppingListItemRequest createShoppingListItemRequest;
    private UpdateShoppingListItemRequest updateShoppingListItemRequest;
    private PurchasedUpdateRequest purchasedUpdateRequest;
    private PantryRecipeComparisonRequest pantryRecipeComparisonRequest;
    private AddRecipeToShoppingListRequest addRecipeToShoppingListRequest;
    

    @BeforeEach
    void setUp() {

        userProfile = new UserProfile();
        userProfile.setPreferredUnit(PreferredUnit.METRIC);

        // simulates what db returns for existing shopping list owned by user 1
        existingShoppingList = new ShoppingList();
        existingShoppingList.setUserId(1);
        existingShoppingList.setName("Weekly Groceries");
        existingShoppingList.setStatus(ShoppingListStatus.ACTIVE);

        // simulates what db returns for an existing item on that shopping list
        existingShoppingListItem = new ShoppingListItem();
        existingShoppingListItem.setShoppingListId(1);
        existingShoppingListItem.setIngId(2);
        existingShoppingListItem.setQuantity(new BigDecimal("250"));
        existingShoppingListItem.setUnit("g");
        existingShoppingListItem.setPurchased(false);

        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 1);

        catalogueInstance = new IngredientCatalogue();
        catalogueInstance.setName("Hummus");
        catalogueInstance.setCategoryId(5);

        categoryInstance = new IngredientCategory();
        categoryInstance.setCategoryName("Legumes and Legume Products");

        existingRecipe = new Recipe();
        existingRecipe.setOwnerId(1);
        existingRecipe.setTitle("Braised Short Rib");
        existingRecipe.setDescription("A slow-braised short rib recipe.");
        existingRecipe.setCuisineType("French");
        existingRecipe.setPrepTimeMins(20);
        existingRecipe.setCookingTimeMins(180);
        existingRecipe.setServingSize(4);
        existingRecipe.setIsCommunityPublished(false);
        
        existingPantryIngredient = new PantryIngredient();
        existingPantryIngredient.setUserId(1);
        existingPantryIngredient.setIngredientId(2);
        existingPantryIngredient.setQuantity(new BigDecimal("500"));
        existingPantryIngredient.setUnit("g");
        

        // what flutter sends when creating new shopping list
        createShoppingListRequest = new CreateShoppingListRequest(
            "Weekly Groceries",
            ShoppingListStatus.ACTIVE
        );

        // what flutter sends when updating existing shopping list
        updateShoppingListRequest = new UpdateShoppingListRequest(
            "Weekly Groceries (Updated)",
            ShoppingListStatus.COMPLETED
        );

        // what flutter sends when manually adding a catalogue linked ingredient to a list
        createShoppingListItemRequest = new CreateShoppingListItemRequest(
            2,
            null,
            new BigDecimal("150"),
            "g"
        );

        // what flutter sends when manually updating a catalogue linked ingredient to a list
        updateShoppingListItemRequest = new UpdateShoppingListItemRequest(
            2,
            null,
            new BigDecimal("150"),
            "g",
            false
        );

        // what flutter sends to dedicated purchased toggle 
        purchasedUpdateRequest = new PurchasedUpdateRequest(true);

        // generate shopping list request
        pantryRecipeComparisonRequest = new PantryRecipeComparisonRequest(
            "Generate with all ingredients",
            false
        );

        // what flutter sends to dedicated purchased toggle 
        purchasedUpdateRequest = new PurchasedUpdateRequest(true);

        // generate shopping list request
        addRecipeToShoppingListRequest = new AddRecipeToShoppingListRequest(
            false // add all items, don't compare pantry
        );

        // so call doesn't have to change in every test
        lenient().when(userProfileRepository.findByUserId(anyInt())).thenReturn(Optional.of(userProfile));
    }


    // ========== Get Shopping Lists ==========

    @Test
    void getUsersShoppingList_whenUserHasNoLists_returnsEmptyList() {
        // Arrange
        when(shoppingListRepository.findByUserId(1)).thenReturn(List.of());

        // Act
        List<ShoppingListResponse> responses = shoppingListService.getUsersShoppingLists(1);

        // Assert
        assertNotNull(responses);
        assertTrue(responses.isEmpty());
    }

    @Test
    void getUsersShoppingList_whenUserHasLists_returnsShoppingListResponse() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findByUserId(1)).thenReturn(List.of(existingShoppingList));

        // Act - from actual service
        List<ShoppingListResponse> responses = shoppingListService.getUsersShoppingLists(1);

        // Assert
        assertEquals(1, responses.size());
        ShoppingListResponse response = responses.get(0);
        assertEquals(1, response.shoppingListId());
        assertEquals(1, response.userId());
        assertEquals("Weekly Groceries", response.name());
        assertEquals(ShoppingListStatus.ACTIVE, response.status());
    }

    // ========== Create New Shopping Lists ==========

    @Test
    void createNewShoppingList_statusOmitted_defaultToActive() {
        // Arrange
        CreateShoppingListRequest requestNoStatus = new CreateShoppingListRequest(
            "Weekly Groceries",
            null
        );

        ArgumentCaptor<ShoppingList> captor = ArgumentCaptor.forClass(ShoppingList.class);
        when(shoppingListRepository.save(captor.capture())).thenReturn(existingShoppingList);

        // Act
        ShoppingListResponse response = shoppingListService.createNewShoppingList(1, requestNoStatus);

        // Assert
        assertEquals(ShoppingListStatus.ACTIVE, captor.getValue().getStatus());
        assertNotNull(response);
        verify(shoppingListRepository).save(any(ShoppingList.class));
    }

    @Test
    void createShoppingList_statusProvided() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.save(any(ShoppingList.class))).thenReturn(existingShoppingList); // when anything is saved to the repository - return

        // Act
        ShoppingListResponse response = shoppingListService.createNewShoppingList(1, createShoppingListRequest);

        // Assert
        assertEquals(1, response.shoppingListId());
        assertEquals(1, response.userId());
        assertEquals("Weekly Groceries", response.name());
        assertEquals(ShoppingListStatus.ACTIVE, response.status());
    }


    // ========== Update Shopping Lists ==========

    @Test
    void updateShoppingList_whenNotFound_throwNotFound() {
        // Arrange
        when(shoppingListRepository.findById(48)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updateShoppingList(1, 48, updateShoppingListRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updateShoppingList_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updateShoppingList(1, 1, updateShoppingListRequest)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void updateShoppingList_whenValid_updatesAndReturnsResponse() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListRepository.save(any(ShoppingList.class))).thenReturn(existingShoppingList);

        // Act
        ShoppingListResponse response = shoppingListService.updateShoppingList(1, 1, updateShoppingListRequest);

        // Assert
        assertEquals(1, response.shoppingListId());
        assertEquals(1, response.userId());
        assertEquals("Weekly Groceries (Updated)", response.name());
        assertEquals(ShoppingListStatus.COMPLETED, response.status());
    }


    // ========== Delete Shopping List Testing ==========

    @Test
    void deleteShoppingList_whenNotFound_throwsNotFound() {
        // Arrange
        when(shoppingListRepository.findById(48)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteShoppingList(1, 48)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void deleteShoppingList_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteShoppingList(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void deleteShoppingList_whenValid_deletesList() {
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
       
        // Act
       shoppingListService.deleteShoppingList(1, 1);

        // Assert
        verify(shoppingListRepository).delete(existingShoppingList);
    }



    // ==================== Item Specific Tests ====================

    // ========== Get Shopping List Items ==========

    @Test 
    void getSpecificListItems_whenListNotFound_throwsNotFound() {
        when(shoppingListRepository.findById(48)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.getSpecificListItems(1, 48)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void getSpecificListItems_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.getSpecificListItems(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void getSpecificListItems_returnsListWithNestedItems() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);

        ShoppingListItemResponse expectedItem = new ShoppingListItemResponse(
            1, // itemId
            1, // shoppingListId
            2, // ingId
            "Hummus",
            "Legumes and Legume Products",
            new BigDecimal("250"),
            "g",
            false
        );

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList)); // when shoppingListId is 1 return the existingShoppingList
        when(shoppingListItemRepository.getSpecificShoppingListItems(1)).thenReturn(List.of(expectedItem)); // when getting the specific items for list 1 return list of the expectedItem

        // Act
        ShoppingListWithItemsResponse response = shoppingListService.getSpecificListItems(1, 1);

        // Assert
        // List level
        assertEquals(1, response.shoppingListId());
        assertEquals(1, response.userId());
        assertEquals("Weekly Groceries", response.name());
        assertEquals(ShoppingListStatus.ACTIVE, response.status());
        
        // List Item Level
        assertEquals(1, response.items().size());
        ShoppingListItemResponse actualItem = response.items().get(0);
        assertEquals(1, actualItem.itemId());
        assertEquals(2, actualItem.ingId());
        assertEquals("Hummus", actualItem.name());
        assertEquals("Legumes and Legume Products", actualItem.category());
        assertEquals(0, BigDecimal.valueOf(250).compareTo(actualItem.quantity()));
        assertEquals("g", actualItem.unit());
        assertEquals(false, actualItem.purchased());

    }

    // ========== Add New Shopping List Items ==========

    @Test
    void addNewShoppingListItem_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(2)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addNewShoppingListItem(1, 2, createShoppingListItemRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test 
    void addNewShoppingListItem_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addNewShoppingListItem(1, 1, createShoppingListItemRequest)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void addNewShoppingListItem_NoNameOrIngId_throwsBadRequest() {
        // Arrange 
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        CreateShoppingListItemRequest badRequest = new CreateShoppingListItemRequest(
            null,
            null,
            new BigDecimal("120"),
            "g"
        );

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addNewShoppingListItem(1, 1, badRequest)
        );

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
    }

    @Test
    void addNewShoppingListItem_nameAndIngId_throwsBadRequest() {
        // Arrange 
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        CreateShoppingListItemRequest badRequest = new CreateShoppingListItemRequest(
            2,
            "Flour",
            new BigDecimal("120"),
            "g"
        );

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addNewShoppingListItem(1, 1, badRequest)
        );

        // Assert
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatusCode());
    }

    @Test
    void addNewShoppingListItem_withIngId_getNameFromCatalogue() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        existingShoppingListItem.setName(null);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.save(any(ShoppingListItem.class))).thenReturn(existingShoppingListItem);
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.of(catalogueInstance));
        when(ingredientCategoryRepository.findById(5)).thenReturn(Optional.of(categoryInstance));

        // Act
        ShoppingListItemResponse response = shoppingListService.addNewShoppingListItem(1, 1, createShoppingListItemRequest);

        // Assert
        assertEquals(2, response.ingId());
        assertEquals("Hummus", response.name());
        assertEquals("Legumes and Legume Products", response.category());
        assertEquals(0, BigDecimal.valueOf(250).compareTo(response.quantity()));
    }

    @Test
    void addNewShoppingListItem_withNameIngIdNull_categoryIsNull() {
        // Arrange
        CreateShoppingListItemRequest manualRequest = new CreateShoppingListItemRequest(
            null,
            "Tomatoes",
            new BigDecimal("150"),
            "g"
        );

        ShoppingListItem savedManualItem = new ShoppingListItem();
        savedManualItem.setShoppingListId(1);
        savedManualItem.setIngId(null);
        savedManualItem.setName("Tomatoes");
        savedManualItem.setQuantity(new BigDecimal("150"));
        savedManualItem.setUnit("g");
        savedManualItem.setPurchased(false);

        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.save(any(ShoppingListItem.class))).thenReturn(savedManualItem);

        // Act 
        ShoppingListItemResponse response = shoppingListService.addNewShoppingListItem(1, 1, manualRequest);

        // Assert
        assertEquals(1, response.shoppingListId());
        assertEquals(null, response.ingId()); //ing_id
        assertEquals("Tomatoes", response.name());
        assertEquals(null, response.category()); 
        assertEquals(0, BigDecimal.valueOf(150).compareTo(response.quantity()));
        assertEquals("g", response.unit()); 
        assertEquals(false, response.purchased());
    }


    // ========== Update Shopping List Item ==========

    @Test 
    void updateShoppingListItem_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updateShoppingListItem(1, 1, 1, updateShoppingListItemRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test 
    void updateShoppingListItem_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updateShoppingListItem(1, 1, 1, updateShoppingListItemRequest)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void updateShoppingListItem_whenItemNotFound_throwsNotFound() { //lost found but item not found
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(48)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updateShoppingListItem(1, 1, 48, updateShoppingListItemRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updateShoppingListItem_itemBelongsToDifferentList_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 48);
        existingShoppingListItem.setShoppingListId(2); // different list 

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(48)).thenReturn(Optional.of(existingShoppingListItem));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updateShoppingListItem(1, 1, 48, updateShoppingListItemRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updateShoppingListItem_valid_UpdatesAndReturnsResponse() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 1);
        existingShoppingListItem.setShoppingListId(1);

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(1)).thenReturn(Optional.of(existingShoppingListItem));
        when(shoppingListItemRepository.save(any(ShoppingListItem.class))).thenReturn(existingShoppingListItem);
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.of(catalogueInstance));
        when(ingredientCategoryRepository.findById(5)).thenReturn(Optional.of(categoryInstance));

        // Act
        ShoppingListItemResponse response = shoppingListService.updateShoppingListItem(1, 1, 1, updateShoppingListItemRequest);

        // Assert
        assertEquals(1, response.shoppingListId());
        assertEquals(2, response.ingId());
        assertEquals("Hummus", response.name());
        assertEquals("Legumes and Legume Products", response.category());
        assertEquals(0, BigDecimal.valueOf(150).compareTo(response.quantity()));
        assertEquals("g", response.unit());
        assertEquals(false, response.purchased());
    }


    // ========== Update Purchased Flag ==========

    @Test
    void updatePurchasedFlag_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updatePurchasedFlag(1, 1, 1, purchasedUpdateRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updatePurchasedFlag_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updatePurchasedFlag(1, 1, 1, purchasedUpdateRequest)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void updatePurchasedFlag_whenItemNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(48)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updatePurchasedFlag(1, 1, 48, purchasedUpdateRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updatePurchasedFlag_whenItemInDifferentList_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 48);
        existingShoppingListItem.setShoppingListId(2); // different list 

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(48)).thenReturn(Optional.of(existingShoppingListItem));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.updatePurchasedFlag(1, 1, 48, purchasedUpdateRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void updatePurchasedFlag_changePurchasedField() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 1);
        existingShoppingListItem.setShoppingListId(1);
        existingShoppingListItem.setPurchased(false); // initially false

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(1)).thenReturn(Optional.of(existingShoppingListItem));
        when(shoppingListItemRepository.save(any(ShoppingListItem.class))).thenReturn(existingShoppingListItem);
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.of(catalogueInstance));
        when(ingredientCategoryRepository.findById(5)).thenReturn(Optional.of(categoryInstance));

        // Act
        ShoppingListItemResponse response = shoppingListService.updatePurchasedFlag(1, 1, 1, purchasedUpdateRequest);
        
        // Assert
        assertEquals(2, response.ingId());
        assertEquals(0, BigDecimal.valueOf(250).compareTo(response.quantity()));
        assertEquals("g", response.unit());
        assertEquals(true, response.purchased());
    }


    // ========== Delete item testing ==========

    @Test
    void deleteShoppingListItem_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteShoppingListItem(1, 1, 1)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void deleteShoppingListItem_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteShoppingListItem(1, 1, 1)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void deleteShoppingListItem_whenItemNtFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(48)).thenReturn(Optional.empty());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteShoppingListItem(1, 1, 48)
        );

        // Assert1, 2, 3
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void deleteShoppingListItem_whenItemBelongsToDifferentList_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 48);
        existingShoppingListItem.setShoppingListId(2); // different list 

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(48)).thenReturn(Optional.of(existingShoppingListItem));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteShoppingListItem(1, 1, 48)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void deleteShoppingListItem_valid_deletesItem() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingShoppingListItem, "itemId", 1);
        existingShoppingListItem.setShoppingListId(1);

        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(shoppingListItemRepository.findById(1)).thenReturn(Optional.of(existingShoppingListItem));

        // Act 
        shoppingListService.deleteShoppingListItem(1, 1, 1);

        // Assert
        verify(shoppingListItemRepository).delete(existingShoppingListItem);
    }


    // ========== Delete Selected Item ==========

    @Test
    void deleteSelectedItems_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        DeleteBatchItemsRequest request = new DeleteBatchItemsRequest(List.of(1, 2, 3));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteSelectedItems(1, 1, request)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void deleteSelectedItems_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        DeleteBatchItemsRequest request = new DeleteBatchItemsRequest(List.of(1, 2, 3));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteSelectedItems(1, 1, request)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void deleteSelectedItems_whenOneItemNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem item1 = new ShoppingListItem();
        item1.setShoppingListId(1);
        ReflectionTestUtils.setField(item1, "itemId", 1);

        when(shoppingListItemRepository.findById(1)).thenReturn(Optional.of(item1));
        when(shoppingListItemRepository.findById(2)).thenReturn(Optional.empty());

        DeleteBatchItemsRequest request = new DeleteBatchItemsRequest(List.of(1, 2, 3));
        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteSelectedItems(1, 1, request)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        
        // loop delets as it goes, item 1 should be deleted 
        verify(shoppingListItemRepository).delete(item1);
        // item 3 never reached - loop stopperd after failure
        verify(shoppingListItemRepository, times(1)).delete(any());
    }

    @Test
    void deleteSelectedItems_whenItemBelongsToDifferentList_throwsNotFound() {
        // Arrange 
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem itemDiffList = new ShoppingListItem();
        itemDiffList.setShoppingListId(2); 
        ReflectionTestUtils.setField(itemDiffList, "itemId", 5);

        when(shoppingListItemRepository.findById(5)).thenReturn(Optional.of(itemDiffList));

        DeleteBatchItemsRequest request = new DeleteBatchItemsRequest(List.of(5));

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deleteSelectedItems(1, 1, request)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        verify(shoppingListItemRepository, never()).delete(any());        
    }

    @Test
    void deleteSelectedItems_valid_deletesAllItems() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem item1 = new ShoppingListItem();
        item1.setShoppingListId(1);
        ReflectionTestUtils.setField(item1, "itemId", 1);

        ShoppingListItem item2 = new ShoppingListItem();
        item2.setShoppingListId(1);
        ReflectionTestUtils.setField(item2, "itemId", 2);

        when(shoppingListItemRepository.findById(1)).thenReturn(Optional.of(item1));
        when(shoppingListItemRepository.findById(2)).thenReturn(Optional.of(item2));

        // Act 
        DeleteBatchItemsRequest request = new DeleteBatchItemsRequest(List.of(1, 2));

        shoppingListService.deleteSelectedItems(1, 1, request);

        // Assert
        verify(shoppingListItemRepository).delete(item1);
        verify(shoppingListItemRepository).delete(item2);
        verify(shoppingListItemRepository, times(2)).delete(any(ShoppingListItem.class));     
    }


    // ========== Select All Items As Purchased ==========

    @Test 
    void selectAllItemsAsPurchase_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.selectAllItemsAsPurchased(1, 1)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void selectAllItemsAsPurchase_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.selectAllItemsAsPurchased(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void selectAllItemsAsPurchase_valid_selectsAllItemsAsPurchased() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem item1 = new ShoppingListItem();
        item1.setShoppingListId(1);
        ReflectionTestUtils.setField(item1, "itemId", 1);

        ShoppingListItem item2 = new ShoppingListItem();
        item2.setShoppingListId(1);
        ReflectionTestUtils.setField(item2, "itemId", 2);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(item1, item2));

        shoppingListService.selectAllItemsAsPurchased(1, 1);

        // Assert
       assertEquals(true, item1.getPurchased());
       assertEquals(true, item2.getPurchased());
       verify(shoppingListItemRepository, times(2)).save(any(ShoppingListItem.class));
    }


    // ========== Deselect All Items As Purchased ==========

    @Test 
    void deselectAllItemsAsPurchase_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deselectAllItemsAsPurchased(1, 1)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void deselectAllItemsAsPurchase_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.deselectAllItemsAsPurchased(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void deselectAllItemsAsPurchase_valid_deselectsAllItemsAsPurchased() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem item1 = new ShoppingListItem();
        item1.setShoppingListId(1);
        ReflectionTestUtils.setField(item1, "itemId", 1);

        ShoppingListItem item2 = new ShoppingListItem();
        item2.setShoppingListId(1);
        ReflectionTestUtils.setField(item2, "itemId", 2);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(item1, item2));

        shoppingListService.deselectAllItemsAsPurchased(1, 1);

        // Assert
       assertEquals(false, item1.getPurchased());
       assertEquals(false, item2.getPurchased());
       verify(shoppingListItemRepository, times(2)).save(any(ShoppingListItem.class));
    }

    // ========== Auto add to pantry from shopping list ==========

    @Test 
    void autoAddToPantryRemoveFromList_whenListNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.autoAddToPantryRemoveFromList(1, 1)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void autoAddToPantryRemoveFromList_whenNotOwned_throwsUnauthorized() {
        // Arrange
        existingShoppingList.setUserId(2);
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.autoAddToPantryRemoveFromList(1, 1)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    void autoAddToPantryRemoveFromList_catalogueLinkedItem_addToPantry() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem  itemInCatalogue = new ShoppingListItem();
        itemInCatalogue.setShoppingListId(1);
        itemInCatalogue.setIngId(2);
        itemInCatalogue.setQuantity(new BigDecimal("250"));
        itemInCatalogue.setUnit("g");
        itemInCatalogue.setPurchased(true);
        ReflectionTestUtils.setField(itemInCatalogue, "itemId", 1);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(itemInCatalogue)).thenReturn(List.of());
        
        // Act
        CompleteShopResponse response = shoppingListService.autoAddToPantryRemoveFromList(1, 1);

        // Assert
        assertEquals(1, response.addedToPantryCount());
        assertTrue(response.skippedManualItemNames().isEmpty());
        verify(pantryIngredientRepository).save(any(PantryIngredient.class));
        verify(shoppingListItemRepository).delete(itemInCatalogue);
    }

    @Test
    void autoAddToPantryRemoveFromList_manualItem_skippedButRemovedFromList() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem  manualItem = new ShoppingListItem();
        manualItem.setShoppingListId(1);
        manualItem.setIngId(null);
        manualItem.setName("Tomatoes");
        manualItem.setQuantity(new BigDecimal("250"));
        manualItem.setUnit("g");
        manualItem.setPurchased(true);
        ReflectionTestUtils.setField(manualItem, "itemId", 1);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(manualItem)).thenReturn(List.of());
        
        // Act
        CompleteShopResponse response = shoppingListService.autoAddToPantryRemoveFromList(1, 1);

        // Assert
        assertEquals(0, response.addedToPantryCount());
        assertEquals(1, response.skippedManualItemNames().size());
        assertEquals("Tomatoes", response.skippedManualItemNames().get(0));
        verify(pantryIngredientRepository, never()).save(any());
        verify(shoppingListItemRepository).delete(manualItem);
    }

    @Test
    void autoAddToPantryRemoveFromList_purchasedAndUnpurchased() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem  itemInCatalogue = new ShoppingListItem();
        itemInCatalogue.setShoppingListId(1);
        itemInCatalogue.setIngId(2);
        itemInCatalogue.setQuantity(new BigDecimal("250"));
        itemInCatalogue.setUnit("g");
        itemInCatalogue.setPurchased(true);
        ReflectionTestUtils.setField(itemInCatalogue, "itemId", 1);

        ShoppingListItem  unpurchased = new ShoppingListItem();
        unpurchased.setShoppingListId(1);
        unpurchased.setIngId(3);
        unpurchased.setQuantity(new BigDecimal("250"));
        unpurchased.setUnit("g");
        unpurchased.setPurchased(false);
        ReflectionTestUtils.setField(unpurchased, "itemId", 2);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(itemInCatalogue, unpurchased)).thenReturn(List.of(unpurchased));
        
        // Act
        CompleteShopResponse response = shoppingListService.autoAddToPantryRemoveFromList(1, 1);

        // Assert
        assertEquals(1, response.addedToPantryCount());
        assertTrue(response.skippedManualItemNames().isEmpty());
        verify(pantryIngredientRepository).save(any(PantryIngredient.class));
        assertFalse(response.canDeleteShoppingList());
        verify(shoppingListItemRepository).delete(itemInCatalogue);
        verify(shoppingListItemRepository, never()).delete(unpurchased);
    }

    @Test
    void autoAddToPantryRemoveFromList_allItemsRemoved_deleteList() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem  item1 = new ShoppingListItem();
        item1.setShoppingListId(1);
        item1.setIngId(2);
        item1.setQuantity(new BigDecimal("250"));
        item1.setUnit("g");
        item1.setPurchased(true);
        ReflectionTestUtils.setField(item1, "itemId", 1);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(item1)).thenReturn(List.of());

        // Act
        CompleteShopResponse response = shoppingListService.autoAddToPantryRemoveFromList(1, 1);

        // Assert
        assertTrue(response.canDeleteShoppingList());
        verify(shoppingListRepository, never()).delete(any(ShoppingList.class));  
    }
    
    @Test
    void autoAddToPantryRemoveFromList_someItemsRemoved_doNotDeleteShoppingList() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        ShoppingListItem  purchased = new ShoppingListItem();
        purchased.setShoppingListId(1);
        purchased.setIngId(2);
        purchased.setQuantity(new BigDecimal("250"));
        purchased.setUnit("g");
        purchased.setPurchased(true);
        ReflectionTestUtils.setField(purchased, "itemId", 1);

        ShoppingListItem  unpurchased = new ShoppingListItem();
        unpurchased.setShoppingListId(1);
        unpurchased.setIngId(3);
        unpurchased.setQuantity(new BigDecimal("250"));
        unpurchased.setUnit("g");
        unpurchased.setPurchased(false);
        ReflectionTestUtils.setField(unpurchased, "itemId", 2);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(purchased, unpurchased)).thenReturn(List.of(unpurchased));
        
        // Act
        CompleteShopResponse response = shoppingListService.autoAddToPantryRemoveFromList(1, 1);

        assertFalse(response.canDeleteShoppingList());
        verify(shoppingListRepository, never()).delete(any(ShoppingList.class));
    }


    // ========== Generating Shopping List Items (Compares recipe to current pantry ingredients and inserts the rest into shopping list) Testing ==========

    @Test
    void generateShoppingListFromRecipe_whenRecipeNotFound_throwNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.generateShoppingListFromRecipe(1, 1, pantryRecipeComparisonRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    void generateShoppingListFromRecipe_whenUserIsOwner_allowsAccess() {
        // Arrange
        existingRecipe.setOwnerId(1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of());

        ShoppingList savedList = new ShoppingList();
        savedList.setUserId(1);
        savedList.setName("Generate with all ingredients");
        savedList.setStatus(ShoppingListStatus.ACTIVE);
        ReflectionTestUtils.setField(savedList, "shoppingListId", 10);
        when(shoppingListRepository.save(any(ShoppingList.class))).thenReturn(savedList);

        // Act
        ShoppingListResponse response = shoppingListService.generateShoppingListFromRecipe(1, 1, pantryRecipeComparisonRequest);

        // Assert
        assertNotNull(response);
        assertEquals(10, response.shoppingListId());
        assertEquals(1, response.userId());
    }

    @Test
    void generateShoppingListFromRecipe_userDoesNotHaveAccess_throwsNotFound() {
        // Arrange
        existingRecipe.setOwnerId(1);
        existingRecipe.setIsCommunityPublished(false);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(vaultFolderRecipeRepository.findByRecipe_RecipeId(1)).thenReturn(List.of());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.generateShoppingListFromRecipe(2, 1, pantryRecipeComparisonRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());

    }

    @Test
    void generateShoppingListFromRecipe_addAllRecipeIngredients() {
        // Arrange
        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("100"));
        ingredient1.setUnit("g");

        RecipeIngredient ingredient2 = new RecipeIngredient();
        ingredient2.setIngId(3);
        ingredient2.setQuantity(new BigDecimal("50"));
        ingredient2.setUnit("ml");

        existingRecipe.setOwnerId(1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1, ingredient2));

        ShoppingList savedList = new ShoppingList();
        savedList.setUserId(1);
        savedList.setName("Generate with all ingredients");
        savedList.setStatus(ShoppingListStatus.ACTIVE);
        ReflectionTestUtils.setField(savedList, "shoppingListId", 10);
        when(shoppingListRepository.save(any(ShoppingList.class))).thenReturn(savedList);

        shoppingListService.generateShoppingListFromRecipe(1, 1, pantryRecipeComparisonRequest);

        // Assert
        verify(shoppingListItemRepository, times(2)).save(any(ShoppingListItem.class));
        verify(pantryIngredientRepository, never()).findByUserIdAndIngId(any(), any());
    }

    @Test
    void generateShoppingListFromRecipe_addOnlyItemsNotInPantry() {
        // Arrange
        pantryRecipeComparisonRequest = new PantryRecipeComparisonRequest(
                " Generate missing only",
                true
        );

        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("100"));
        ingredient1.setUnit("g");

        RecipeIngredient ingredient2 = new RecipeIngredient();
        ingredient2.setIngId(3);
        ingredient2.setQuantity(new BigDecimal("50"));
        ingredient2.setUnit("ml");

        existingRecipe.setOwnerId(1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1, ingredient2));

        when(pantryIngredientRepository.findByUserIdAndIngId(1, 2)).thenReturn(List.of());
        when(pantryIngredientRepository.findByUserIdAndIngId(1, 3)).thenReturn(List.of());

        ShoppingList savedList = new ShoppingList();
        savedList.setUserId(1);
        savedList.setName("Generate with all ingredients");
        savedList.setStatus(ShoppingListStatus.ACTIVE);
        ReflectionTestUtils.setField(savedList, "shoppingListId", 10);
        when(shoppingListRepository.save(any(ShoppingList.class))).thenReturn(savedList);

        // Act
        shoppingListService.generateShoppingListFromRecipe(1, 1, pantryRecipeComparisonRequest);

        // Assert
        verify(shoppingListItemRepository, times(2)).save(any(ShoppingListItem.class));
    }

    @Test
    void generateShoppingListFromRecipe_mixedSomeAlreadyInPantry_addOnlyItemsNotInPantry() {
        // Arrange
        pantryRecipeComparisonRequest = new PantryRecipeComparisonRequest(
                " Generate missing only",
                true
        );

        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("100"));
        ingredient1.setUnit("g");

        RecipeIngredient ingredient2 = new RecipeIngredient();
        ingredient2.setIngId(3);
        ingredient2.setQuantity(new BigDecimal("50"));
        ingredient2.setUnit("ml");

        existingRecipe.setOwnerId(1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1, ingredient2));

        PantryIngredient existingPantryIngredient = new PantryIngredient();
        existingPantryIngredient.setUserId(1);
        existingPantryIngredient.setIngredientId(2);
        existingPantryIngredient.setQuantity(new BigDecimal("500"));
        existingPantryIngredient.setUnit("g");

        // ingredient1 (id = 2) already in pantry - will be skipped
        when(pantryIngredientRepository.findByUserIdAndIngId(1, 2)).thenReturn(List.of(existingPantryIngredient));
        // ingredient2
        when(pantryIngredientRepository.findByUserIdAndIngId(1, 3)).thenReturn(List.of());

        ShoppingList savedList = new ShoppingList();
        savedList.setUserId(1);
        savedList.setName("Generate missing only");
        savedList.setStatus(ShoppingListStatus.ACTIVE);
        ReflectionTestUtils.setField(savedList, "shoppingListId", 10);
        when(shoppingListRepository.save(any(ShoppingList.class))).thenReturn(savedList);
        // Act
        shoppingListService.generateShoppingListFromRecipe(1, 1, pantryRecipeComparisonRequest);

        // Assert
        verify(shoppingListItemRepository, times(1)).save(any(ShoppingListItem.class));
    }


    //  ========== Generating Shopping List Items Add to existing list (Compares recipe to current pantry ingredients and inserts the rest into shopping list) Testing ==========

    @Test 
    public void addRecipeIngredientsToShoppingList_whenListNotFound_throwsNotFound() {
        // Arrange
        when(shoppingListRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, addRecipeToShoppingListRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }  


    @Test
    public void addRecipeIngredientsToShoppingList_whenNotOwned_throwsUnauthorized() {    
        // Arrange
        existingShoppingList.setUserId(2);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 2, addRecipeToShoppingListRequest)
        );

        // Assert
        assertEquals(HttpStatus.UNAUTHORIZED, ex.getStatusCode());
    }

    @Test
    public void addRecipeIngredientsToShoppingList_whenRecipeNotFound_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(recipeRepository.findById(1)).thenReturn(Optional.empty());
        
        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, addRecipeToShoppingListRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    @Test
    public void addRecipeIngredientsToShoppingList_whenUserCannotAccessRecipe_throwsNotFound() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        existingRecipe.setOwnerId(2);
        existingRecipe.setIsCommunityPublished(false);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(vaultFolderRecipeRepository.findByRecipe_RecipeId(1)).thenReturn(List.of());

        // Act 
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, addRecipeToShoppingListRequest)
        );

        // Assert
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    // actual behaviour
    @Test
    public void addRecipeIngredientsToShoppingList_noPantryComparison_addsAllIngredientsAsNewItems() {
        // Arrange
        
        // selected shopping list
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));

        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("100"));
        ingredient1.setUnit("g");

        RecipeIngredient ingredient2 = new RecipeIngredient();
        ingredient2.setIngId(3);
        ingredient2.setQuantity(new BigDecimal("50"));
        ingredient2.setUnit("ml");

        existingRecipe.setOwnerId(1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1, ingredient2));

        when(shoppingListItemRepository.save(any(ShoppingListItem.class))).thenAnswer(inv -> inv.getArgument(0));

        shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, addRecipeToShoppingListRequest);

        // Assert
        verify(shoppingListItemRepository, times(2)).save(any(ShoppingListItem.class));
        verify(pantryIngredientRepository, never()).findByUserIdAndIngId(any(), any());
    }

    // compare to current pantry ingredients- partially enough of ingredient, add shortfall
    @Test
    public void addRecipeIngredientsToShoppingList_pantryComparison_onlyAddShortfall() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        existingRecipe.setOwnerId(1);

        // selected shopping list
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));

        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("100"));
        ingredient1.setUnit("g");
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1));

        // no existing item - no merge
        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of());

        PantryIngredient existingPantryIngredient = new PantryIngredient();
        existingPantryIngredient.setUserId(1);
        existingPantryIngredient.setIngredientId(2);
        existingPantryIngredient.setQuantity(new BigDecimal("40"));
        existingPantryIngredient.setUnit("g");

        when(pantryIngredientRepository.findByUserIdAndIngId(1, 2)).thenReturn(List.of(existingPantryIngredient));

        when(shoppingListItemRepository.getSpecificShoppingListItems(1)).thenReturn(List.of());

        // save passed in to access value to assert equals
        ArgumentCaptor<ShoppingListItem> captor = ArgumentCaptor.forClass(ShoppingListItem.class);
        when(shoppingListItemRepository.save(captor.capture())).thenAnswer(inv -> inv.getArgument(0)); // else will throw a null ptr exception

        AddRecipeToShoppingListRequest requestWithPantryComparison = new AddRecipeToShoppingListRequest(true);

        // Act
        shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, requestWithPantryComparison);

        // Assert
        assertEquals(0, BigDecimal.valueOf(60).compareTo(captor.getValue().getQuantity()));
        assertEquals(2, captor.getValue().getIngId());
        verify(shoppingListItemRepository, times(1)).save(any(ShoppingListItem.class));
    }

    // compare to current pantry ingredients- add full ingredient quantity
    @Test
    void addRecipeIngredientsToShoppingList_pantryComparison_addFullIngredient() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        existingRecipe.setOwnerId(1);

        // selected shopping list
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));

        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("100"));
        ingredient1.setUnit("g");
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1));

        // no existing item - no merge
        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of());

        when(shoppingListItemRepository.getSpecificShoppingListItems(1)).thenReturn(List.of());

        // save passed in to access value to assert equals
        ArgumentCaptor<ShoppingListItem> captor = ArgumentCaptor.forClass(ShoppingListItem.class);
        when(shoppingListItemRepository.save(captor.capture())).thenAnswer(inv -> inv.getArgument(0)); // else will throw a null ptr exception

        AddRecipeToShoppingListRequest requestWithPantryComparison = new AddRecipeToShoppingListRequest(true);

        // Act
        shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, requestWithPantryComparison);

        // Assert
        assertEquals(0, BigDecimal.valueOf(100).compareTo(captor.getValue().getQuantity()));
        verify(shoppingListItemRepository, times(1)).save(any(ShoppingListItem.class));
    }

    // matching ingredient already exists in shopping list - merge
    @Test
    void addRecipeIngredientsToShoppingList_pantryComparison_mergeQuantity() {
        // Arrange
        ReflectionTestUtils.setField(existingShoppingList, "shoppingListId", 1);
        ReflectionTestUtils.setField(existingRecipe, "recipeId", 1);
        existingRecipe.setOwnerId(1);

        // selected shopping list
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
        when(recipeRepository.findById(1)).thenReturn(Optional.of(existingRecipe));

        RecipeIngredient ingredient1 = new RecipeIngredient();
        ingredient1.setIngId(2);
        ingredient1.setQuantity(new BigDecimal("50"));
        ingredient1.setUnit("g");
        when(recipeIngredientRepository.findByRecipe_RecipeId(1)).thenReturn(List.of(ingredient1));

        // existing item in shopping list
        ShoppingListItem existingMatch = new ShoppingListItem();
        existingMatch.setShoppingListId(1);
        existingMatch.setIngId(2);
        existingMatch.setUnit("g");
        existingMatch.setQuantity(new BigDecimal("100"));
        ReflectionTestUtils.setField(existingMatch, "itemId", 4);

        when(shoppingListItemRepository.findByShoppingListId(1)).thenReturn(List.of(existingMatch));
        when(shoppingListItemRepository.getSpecificShoppingListItems(1)).thenReturn(List.of());
        when(shoppingListItemRepository.save(any(ShoppingListItem.class))).thenAnswer(inv -> inv.getArgument(0));

        AddRecipeToShoppingListRequest requestWithPantryComparison = new AddRecipeToShoppingListRequest(true);

        // Act
        shoppingListService.addRecipeIngredientsToShoppingList(1, 1, 1, requestWithPantryComparison);

        // Assert
        assertEquals(0, BigDecimal.valueOf(150).compareTo(existingMatch.getQuantity()));
        verify(shoppingListItemRepository, times(1)).save(existingMatch);
        verify(shoppingListItemRepository, times(1)).save(any(ShoppingListItem.class));
    }
}