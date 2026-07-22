// unit testing for pantry

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

//models
import com.mealchemy.shoppinglist.model.ShoppingList;
import com.mealchemy.shoppinglist.model.ShoppingListItem;
import com.mealchemy.shared.enums.ShoppingListStatus;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.pantry.model.PantryIngredient;

//repositories
import com.mealchemy.shoppinglist.repository.ShoppingListRepository;
import com.mealchemy.shoppinglist.repository.ShoppingListItemRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
import com.mealchemy.pantry.repository.PantryIngredientRepository;

// import service
import com.mealchemy.shoppinglist.service.ShoppingListService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.ArgumentCaptor;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ShoppingListServiceTest {
    // @Mock - create fake version of dependency
    @Mock private ShoppingListRepository shoppingListRepository;
    @Mock private ShoppingListItemRepository shoppingListItemRepository;
    @Mock private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Mock private IngredientCategoryRepository ingredientCategoryRepository;
    @Mock private PantryIngredientRepository pantryIngredientRepository;
    
    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private ShoppingListService shoppingListService;

    private ShoppingList existingShoppingList;
    private ShoppingListItem existingShoppingListItem;
    private IngredientCatalogue catalogueInstance;
    private IngredientCategory categoryInstance;

    // requests that have bodies that need to be mocked
    private CreateShoppingListRequest createShoppingListRequest;
    private UpdateShoppingListRequest updateShoppingListRequest;
    private CreateShoppingListItemRequest createShoppingListItemRequest;
    private UpdateShoppingListItemRequest updateShoppingListItemRequest;
    private PurchasedUpdateRequest purchasedUpdateRequest;
    

    @BeforeEach
    void setUp() {
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

        catalogueInstance = new IngredientCatalogue();
        catalogueInstance.setName("Hummus");
        catalogueInstance.setCategoryId(5);

        categoryInstance = new IngredientCategory();
        categoryInstance.setCategoryName("Legumes and Legume Products");

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
        existingShoppingList.setShoppingListId(1);
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

        ArgumentCaptor<ShoppingList> captor = ArguementCaptor.forClass(ShoppingList.class);
        when(shoppingListRepository.save(captor.capture())).thenReturn(existingShoppingList);

        // Act
        ShoppingListResponse response = shoppingListService.createNewShoppingList(1, requestNoStatus);

        // Assert
        assertEquals(ShoppingListStatus.ACTIVE, captor.getValue().getStatus());
        assertNotNull(response);
        verify.(shoppingListRepository).save(any(ShoppingList.class));
    }

    @Test
    void createShoppingList_statusProvided() {
        // Arrange
        when(shoppingListRepository.findByUserId(1)).theReturn(existingShoppingList);

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
        existingShoppingList.setShoppingListId(1);
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
        existingShoppingList.setShoppingListId(1);
        when(shoppingListRepository.findById(1)).thenReturn(Optional.of(existingShoppingList));
       
        // Act
       shoppingListService.deleteShoppingList(1, 1);

        // Assert
        verify(shoppingListRepository).delete(existingShoppingList);
    }



    // ==================== Item Specific Tests ====================

    // ========== Get Shopping List Items ==========

    



}