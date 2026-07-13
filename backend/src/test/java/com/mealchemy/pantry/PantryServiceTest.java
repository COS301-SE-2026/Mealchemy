// unit testing for pantry

package com.mealchemy.pantry;

// import dto
import com.mealchemy.pantry.dto.PantryIngredientRequest;
import com.mealchemy.pantry.dto.PantryIngredientResponse;
// import model
import com.mealchemy.pantry.model.PantryIngredient;
import com.mealchemy.ingredient.model.IngredientCatalogue;
import com.mealchemy.category.model.IngredientCategory;
// import repository
import com.mealchemy.pantry.repository.PantryIngredientRepository;
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com mealchemy.category.repository.IngredientCategoryRepository;
// import service
import com.mealchemy.pantry.service.PantryService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;


@ExtendWith(MockitoExtension.class) //tells JUnit to use Mockito to create mocks
public class PantryServiceTest {
    // @Mock - create fake version of dependency
    @Mock private PantryIngredientRepository pantryIngredientRepository;
    @Mock private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Mock private IngredientCategoryRepository ingredientCategoryRepository;

    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing PantryService
    @InjectMocks
    private PantryService pantryService;

    private PantryIngredient existingPantryIngredients;
    private IngredientCatalogue catalogueInstance;
    private IngredientCategory categoryInstance;

    private PantryIngredientRequest createRequest;

    @BeforeEach
    void setUp() {
        // simulates what db returns for existing user pantry
        existingPantryIngredient = new PantryIngredient();
        existingPantryIngredient.setUserId(1);
        existingPantryIngredient.setIngredientId(2);
        existingPantryIngredient.setQuantity(new BigDecimal("250"));
        existingPantryIngredient.setUnit("g");

        catalogueInstance = new IngredientCatalogue();
        catalogueInstance.setName("Hummus");
        catalogueInstance.setCategoryId(5);

        categoryInstance = new IngredientCategory();
        categoryInstance.setCategoryName("Legumes and Legume Products")
        
        // what flutter puts in req
        updateRequest = new PantryIngredientRequest (
            2,
            new BigDecimal("150"),
            "g"
        );
    }


    // ========== Get User Pantry Ingredients Testing ==========

    @Test
    void pantry_whenUserHasNoItems_returnsEmptyList() {
        // Arrange - no ingredients in pantry returns empty array
        when(pantryIngredientRepository.findByUserId(1)).thenReturn(List.of());

        // Act
        List<PantryIngredientResponse> responses = pantryService.getUserPantryItems(1);
        
        // Assert
        assertNotNull(response);
        assertTrue(responses.isEmpty());
    }

    // User has items 
    @Test
    void pantry_whenUserHasItems_returnsPantryIngredientResponses() {
        // Arrange 
        when(pantryIngredientRepository.findByUserId(1)).thenReturn(List.of(existingPantryIngredient));
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.of(catalogueInstance));
        when(ingredientCategoryRepository.findById(5)).thenReturn(Optional.of(categoryInstance));

        // Act
        List<PantryIngredientResponse> responses = pantryService.getUserPantryItems(1);

        // Assert
        assertEquals(1, response.size());
        PantryIngredientResponse response = responses.get(0);
        assertEquals(2, response.ingId());
        assertEquals("Hummus", response.name());
        assertEquals("Legumes and Legume Products", response.category());
        assertEquals(new BigDecimal("250"), response.quantity());
        assertEquals("g", response.unit());
    }


    // ========== Add Ingredient Manually Testing ==========

    // Negative path
    @Test
    void addIngredientManually_whenIngredientNotInCatalogue_throwNotFound() {
        // Arrange
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> pantryService.addIngredientManually(1, createRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    // Happy path
    @Test addIngredientManually_whenRequestIsValid_saveAndReturnResponse() {
        // Arrange
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.of(catalogueInstance));
        when(ingredientCategoryRepository.findById(5)).thenReturn(Optional.of(categoryInstance));
        when(pantryIngredientRepository.save(any(PantryIngredient.class))).thenReturn(existingPantryIngredient);

        // Act
        PantryIngredientResponse response = pantryService.addIngredientManually(1, createRequest);
        assertNotNull(response);
        assertEquals("Hummus", response.name());
        assertEquals("Legumes and Legume Products", response.category());
        verify(pantryIngredientRepository).save(any(PantryIngredient.class));
    }


    // ========== Update Ingredient Manually Testing ==========

    // Negative
    @Test
    void updateIngredientManually_whenNotFound_throwNotFound() {
        // Arrange
        when(pantryIngredientRepository.findById(48)).thenReturn(Optional.empty());

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> pantryService.updateIngredientManually(1, 48, createRequest)
        );

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
    }

    // Happy
    @Test
    void updateIngredientManually_whenNotOwned_throwsForbidden() {
        // Arrange
        existingPantryIngredient.setUserId(2);
        when(pantryIngredientRepository.findById(1)).thenReturn(Optional.of(existingPantryIngredient));

        // Act
        ResponseStatusException ex = assertThrows(
            ResponseStatusException.class,
            () -> pantryService.updateIngredientManually(1, 1, createRequest)
        );

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
    }

    @Test
    void updateIngredientManually_withPositiveQuantity_returnPantryIngredientResponse() {
        // Arrange 
        when(pantryIngredientRepository.findById(1)).thenReturn(Optional.of(existingPantryIngredient));
        when(ingredientCatalogueRepository.findById(2)).thenReturn(Optional.of(catalogueInstance));
        when(ingredientCategoryRepository.findById(5)).thenReturn(Optional.of(categoryInstance));
        when(pantryIngredientRepository.save(any(PantryIngredient.class))).thenReturn(existingPantryIngredient);
    }


}