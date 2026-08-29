// allergens testing for shopping list

package com.mealchemy.allergens;

//dtos
import com.mealchemy.allergens.dto.AllergenOptionsResponse;
//models
import com.mealchemy.allergens.model.AllergenOptions;
//repositories
import com.mealchemy.allergens.repository.AllergenOptionsRepository;


import com.mealchemy.allergens.service.AllergenOptionsService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class AllergenOptionsServiceTest {
    // @Mock - create fake version of dependency
    @Mock private AllergenOptionsRepository allergenOptionsRepository;

    // @InjectMocks creates the real AllergenOptions service and injects the mocks above into it 
    @InjectMocks
    private AllergenOptionsService allergenOptionsService;

    
    // GET all allergens options
    @Test
    void getAllAllergenOptions_valid_returns200() {
        // Arrange 

        AllergenOptionsResponse peanuts = new AllergenOptionsResponse(
            1, 
            "PEANUTS", 
            "Peanuts"
        );

        AllergenOptionsResponse dairy = new AllergenOptionsResponse(
            2, 
            "DAIRY", 
            "Dairy"
        );

        AllergenOptionsResponse soy = new AllergenOptionsResponse(
            3, 
            "SOY", 
            "Soy"
        );

        AllergenOptionsResponse fish = new AllergenOptionsResponse(
            4, 
            "FISH", 
            "Fish"
        );

        when(allergenOptionsRepository.getAllAllergenOptions()).thenReturn(List.of(peanuts, dairy, soy, fish));

        // Act
        List<AllergenOptionsResponse> allergensList = allergenOptionsService.getAllAllergenOptions();

        // Assert
        assertEquals(4, allergensList.size());
        AllergenOptionsResponse firstAllergenOptionsResponse = allergensList.get(0);
        assertEquals("PEANUTS", firstAllergenOptionsResponse.value());
        assertEquals("Peanuts", firstAllergenOptionsResponse.label());
    }

    @Test
    void getValidAllergenValues_returnAllValues() {
        // Arrange
        when(allergenOptionsRepository.getAllAllergenValues()).thenReturn(List.of("PEANUTS", "DAIRY", "SOY", "FISH"));

        // Act 
        List<String> validValues = allergenOptionsService.getValidAllergenOptions();

        // Assert
        assertEquals(4, validValues.size());
        assertTrue(validValues.contains("PEANUTS")); // first 
        assertTrue(validValues.contains("FISH")); // last
    }
}