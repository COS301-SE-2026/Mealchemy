// unit testing for ingredient catalogue service

package com.mealchemy.ingredient;

// import dto
import com.mealchemy.ingredient.dto.IngredientCatalogueResponse;
import com.mealchemy.ingredient.dto.IngredientSearchResponse;
// import model
import com.mealchemy.category.model.IngredientCategory;
import com.mealchemy.ingredient.model.IngredientCatalogue;
// import repository
import com.mealchemy.ingredient.repository.IngredientCatalogueRepository;
import com.mealchemy.category.repository.IngredientCategoryRepository;
// import service
import com.mealchemy.ingredient.service.IngredientCatalogueService;
import com.mealchemy.ingredient.service.CategoryRequiredException;
// adapter pattern classes
import com.mealchemy.ingredient.external.NutritionDataProvider;
import com.mealchemy.ingredient.external.ExternalIngredientItemResponse;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.math.BigDecimal;
import java.util.Optional;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.web.server.ResponseStatusException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class IngredientCatalogueServiceTest {
    // @Mock - create fake version of dependency
    @Mock private IngredientCatalogueRepository ingredientCatalogueRepository;
    @Mock private IngredientCategoryRepository ingredientCategoryRepository;
    @Mock private NutritionDataProvider nutritionDataProvider;

    private IngredientCatalogueService ingredientCatalogueService;

    private IngredientCatalogueResponse hummusResponse;
    private IngredientCatalogueResponse chickenResponse;

    @BeforeEach
    void setUp() {
        ingredientCatalogueService = new IngredientCatalogueService(ingredientCatalogueRepository, ingredientCategoryRepository, nutritionDataProvider);

        hummusResponse = new IngredientCatalogueResponse(1, "Hummus", "Legumes and Legume Products");
        chickenResponse = new IngredientCatalogueResponse(2, "Chicken Breast", "Poultry");
    }    

    // ========== get all items in ingredient catalogue ==========
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

    // ========== get by name - local (from ingredient catalogue) ==========
    @Test 
    void getIngredientCatalogueItemsByName_returnsNameMatchIngredients() {
        // Arrange
        IngredientSearchResponse chickeSearchResponse = new IngredientSearchResponse(
            2, 
            "Chicken Breast", 
            "Poultry",
            null, 
            null
        );
        when(ingredientCatalogueRepository.getIngredientByName("chick")).thenReturn(List.of(chickeSearchResponse));

        // Act 
        List<IngredientSearchResponse> response = ingredientCatalogueService.getIngredientByName("chick");

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
        List<IngredientSearchResponse> response = ingredientCatalogueService.getIngredientByName("no-match");

        // Assert
        assertTrue(response.isEmpty());
    }

    // ========== external api behaviour tests ==========
    @Test 
    void getIngredientByName_localEmpty_UsdaFallback() {
        // Arrange 
        when(ingredientCatalogueRepository.getIngredientByName("kimchi")).thenReturn(List.of()); // not in ingredient catalogue

        // what usda gives back
        ExternalIngredientItemResponse usdaResponse = new ExternalIngredientItemResponse(
            "Kimchi", // name
            null, // category
            15,
            BigDecimal.ONE,
            BigDecimal.TEN,
            BigDecimal.ZERO,
            BigDecimal.valueOf(498),
            BigDecimal.ONE,
            "USDA", // source url
            "2710077" // source id
        );

        when(nutritionDataProvider.findExternalIngredient("kimchi")).thenReturn(List.of(usdaResponse)); // so we query usda 

        // Act 
        List<IngredientSearchResponse> response = ingredientCatalogueService.getIngredientByName("kimchi");

        // Assert
        assertEquals(1, response.size());
        IngredientSearchResponse mappedResponse = response.get(0); //usda response mapped to one mealchemy understands
        assertNull(mappedResponse.ingId()); // ing id is null, not yet saved to ingredient catalogue
        assertNull(mappedResponse.category()); // need to find usda category
        assertEquals("2710077", mappedResponse.sourceId());
        assertEquals("USDA", mappedResponse.sourceApi());
        
        verify(nutritionDataProvider, times(1)).findExternalIngredient("kimchi");
    }

    @Test
    void getIngredientByName_localAndUsdaEmpty_returnEmptyList() {
        // Arrange
        when(ingredientCatalogueRepository.getIngredientByName("not found")).thenReturn(List.of()); // not in ingredient catalogue
        when(nutritionDataProvider.findExternalIngredient("not found")).thenReturn(List.of()); // not in usda either

        // Act 
        List<IngredientSearchResponse> response = ingredientCatalogueService.getIngredientByName("not found");

        // Assert
        assertTrue(response.isEmpty());
    }


    @Test
    void getIngredientByName_ingredientCategoryMatches_saveIngredientWithExitingCategory() {
        // Arrange
         ExternalIngredientItemResponse details = new ExternalIngredientItemResponse(
            "Kimchi", // name
            "Vegetables and Vegetable Products", // category
            15,
            BigDecimal.ZERO,
            BigDecimal.ONE,
            BigDecimal.valueOf(498),
            BigDecimal.ZERO,
            BigDecimal.ONE,
            "USDA", // source url
            "2710077" // source id
        );

        when(nutritionDataProvider.getExternalIngredientDetails("2710077")).thenReturn(details); // find the ingredient details of the given source id 

        // setting up matching category
        IngredientCategory existingCategory = mock(IngredientCategory.class);
        when(existingCategory.getCategoryId()).thenReturn(19);
        when(existingCategory.getCategoryName()).thenReturn("Vegetables and Vegetable Products");
        when(ingredientCategoryRepository.findByCatNameFuzzy("Vegetables and Vegetable Products")).thenReturn(List.of(existingCategory));

        IngredientCatalogue savedIngredient = mock(IngredientCatalogue.class);
        when(savedIngredient.getIngId()).thenReturn(306);
        when(savedIngredient.getName()).thenReturn("Kimchi");
        when(ingredientCatalogueRepository.save(any(IngredientCatalogue.class))).thenReturn(savedIngredient);

        // Act 
        IngredientCatalogueResponse result = ingredientCatalogueService.saveExternalIngredientToCatalogue("2710077", null);

        assertEquals(306, result.ingId());
        assertEquals("Kimchi", result.name());
        assertEquals("Vegetables and Vegetable Products", result.category());
        // no new category should have been created
        verify(ingredientCategoryRepository, never()).save(any(IngredientCategory.class));
    }


    // usda gave category
    @Test
    void saveExternalIngredient_noLocalCategoryMatch_createsNewCategory() {
        // Arrange 
        ExternalIngredientItemResponse details = new ExternalIngredientItemResponse(
                "New Food", 
                "New USDA Category",
                100, 
                BigDecimal.ONE, 
                BigDecimal.ONE,
                BigDecimal.ONE, 
                BigDecimal.ONE, 
                BigDecimal.ONE, 
                "USDA", 
                "999999"
        );

        when(nutritionDataProvider.getExternalIngredientDetails("999999")).thenReturn(details);
        when(ingredientCategoryRepository.findByCatNameFuzzy("New USDA Category")).thenReturn(List.of()); // category is not in local list
 
        IngredientCategory newCategory = mock(IngredientCategory.class); //reads back after save
        when(newCategory.getCategoryId()).thenReturn(20);
        when(newCategory.getCategoryName()).thenReturn("New USDA Category");
        when(ingredientCategoryRepository.save(any(IngredientCategory.class))).thenReturn(newCategory);
 
        IngredientCatalogue savedCategory = mock(IngredientCatalogue.class);
        when(savedCategory.getIngId()).thenReturn(400);
        when(savedCategory.getName()).thenReturn("New Food");
        when(ingredientCatalogueRepository.save(any(IngredientCatalogue.class))).thenReturn(savedCategory);
 
        IngredientCatalogueResponse result = ingredientCatalogueService.saveExternalIngredientToCatalogue("999999", null);
 
        assertEquals("New USDA Category", result.category());
        verify(ingredientCategoryRepository, times(1)).save(any(IngredientCategory.class));
    }

    // no local and no usda category
    @Test 
    void saveExternalIngredient_noLocalAndNoUsda_throwsCategoryRequiredExcepion() {
        ExternalIngredientItemResponse details = new ExternalIngredientItemResponse(
                "Snack", 
                null,
                100, 
                BigDecimal.ONE, 
                BigDecimal.ONE,
                BigDecimal.ONE, 
                BigDecimal.ONE, 
                BigDecimal.ONE, 
                "USDA", 
                "111111"
        );

        when(nutritionDataProvider.getExternalIngredientDetails("111111")).thenReturn(details);

        CategoryRequiredException ex = assertThrows(CategoryRequiredException.class,
                () -> ingredientCatalogueService.saveExternalIngredientToCatalogue("111111", null)
        );

        assertEquals("111111", ex.getSourceId());
        assertEquals("Snack", ex.getName());
        //don't save anything
        verify(ingredientCatalogueRepository, never()).save(any());
    }
}

