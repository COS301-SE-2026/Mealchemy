// unit testing for pantry

package com.mealchemy.ingredient;

// import dto
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;
// import model
// import repository
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
// import service
import com.mealchemy.ingredient.service.IngredientCatalogueService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.InjectMocks;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class IngredientCatalogueServiceTest {
    // @Mock - create fake version of dependency
    @Mock private IngredientCatalogueRepository ingredientCatalogueRepository;

    @InjectMocks // creates the real IngredientCatalogueServiceTest and injects the mocks above into it - actually testing IngredientCatalogueService
    private IngredientCatalogueService ingredientCatalogueService;

    private IngredientCatalogueResponse hummusResponse;
    private IngredientCatalogueResponse chickenResponse;

    @BeforeEach
    void setUp() {
        ingredientCatalogueService = new IngredientCatalogueService(ingredientCatalogueRepository);

        hummusResponse = new IngredientCatalogueResponse(1, "Hummus", "Legumes and Legume Products");
        chickenResponse = new IngredientCatalogueResponse(2, "Chicken Breast", "Poultry");
    }    

    @Test 
    void getIngredientCatalogue_returnsAllItemsInCatalogue() {
        // Arrange
        when(ingredientCatalogueRepository.getIngredientCatalogueItems()).thenReturn(List.of(hummusResponse, chickenResponse));

        // Act
        List<IngredientCatalogueResponse> response = ingredientCatalogueService.getIngredientCatalogue();

        // Assert 
        assertEquals(2, response.size());
        assertTrue(response.contains(hummusResponse));
        verify(ingredientCatalogueRepository, times(1)).getIngredientCatalogueItems();
    }

    @Test 
    void getIngredientCatalogueItemsByName_returnsNameMatchIngredients() {
        // Arrange
        when(ingredientCatalogueRepository.getIngredientByName("chick")).thenReturn(List.of(chickenResponse));

        // Act 
        List<IngredientCatalogueResponse> response = ingredientCatalogueService.getIngredientByName("chick");

        // Assert
        assertEquals(1, response.size());
        assertEquals("Chicken Breast", response.get(0).name());
        verify(ingredientCatalogueRepository, times(1)).getIngredientByName("chick");

    }

    @Test 
    void getIngredientCatalogueItemsByName_noMatches_returnsEmptyList() {
        // Arrange
        when(ingredientCatalogueRepository.getIngredientByName("no-match")).thenReturn(List.of());

        // Act 
        List<IngredientCatalogueResponse> response = ingredientCatalogueService.getIngredientByName("no-match");

        // Assert
        assertTrue(response.isEmpty());
    }

    @Test
    void findExistingIngredientNames_returnsNamesThatExist() {
        when(ingredientCatalogueRepository.findExistingNames(List.of("Hummus", "DoesNotExist"))).thenReturn(List.of("Hummus"));
        
        List<String> existing = ingredientCatalogueService.findExistingIngredientNames(List.of());

        assertEquals(1, existing.size());
        assertTrue(existing.contains("Hummus"));
        verify(ingredientCatalogueRepository, times(1)).findExistingNames(List.of("Hummus", "DoesNotExist"));
    }

    @Test
    void findExistingIngredientNames_withEmptyList_returnsEmptyList() {
        when(ingredientCatalogueRepository.findExistingNames(List.of())).thenReturn(List.of());

       List<String> existing = ingredientCatalogueService.findExistingIngredientNames(List.of("Hummus", "DoesNotExist"));

        assertTrue(existing.isEmpty());
    }
}

