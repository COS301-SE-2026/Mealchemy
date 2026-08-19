// allergens testing for shopping list

package com.mealchemy.dietaryrestrictions;

//dtos
import com.mealchemy.dietaryrestrictions.dto.DietaryRestrictionOptionsResponse;
//models
import com.mealchemy.dietaryrestrictions.model.DietaryRestrictionOptions;
//repositories
import com.mealchemy.dietaryrestrictions.repository.DietaryRestrictionOptionsRepository;


import com.mealchemy.dietaryrestrictions.service.DietaryRestrictionOptionsService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class DietaryRestrictionOptionsServiceTest {
    // @Mock - create fake version of dependency
    @Mock private DietaryRestrictionOptionsRepository dietaryRestrictionOptionsRepository;

    // @InjectMocks creates the real DietaryRestrictionOptions service and injects the mocks above into it 
    @InjectMocks
    private DietaryRestrictionOptionsService dietaryRestrictionOptionsService;

    
    // GET all nutrtional goal options
    @Test
    void getAllDietaryRestrictionOptions_valid_returns200() {
        // Arrange 
        DietaryRestrictionOptionsResponse vegetarian = new DietaryRestrictionOptionsResponse(
            1, 
            "VEGETARIAN", 
            "Vegetarian"
        );

        DietaryRestrictionOptionsResponse glutenFree = new DietaryRestrictionOptionsResponse(
            2, 
            "GLUTEN_FREE", 
            "Gluten Free"
        );

        DietaryRestrictionOptionsResponse diabetesFriendly = new DietaryRestrictionOptionsResponse(
            3, 
            "DIABETES_Friendly", 
            "Diabetes-Friendly"
        );


        when(dietaryRestrictionOptionsRepository.getAllDietaryRestrictionOptions()).thenReturn(List.of(vegetarian, glutenFree, diabetesFriendly));

        // Act
        List<DietaryRestrictionOptionsResponse> dietaryRestrictionsList = dietaryRestrictionOptionsService.getAllDietaryRestrictionOptions();

        // Assert
        assertEquals(3, dietaryRestrictionsList.size());
        DietaryRestrictionOptionsResponse firstDietaryRestrictionOptionsResponse = dietaryRestrictionsList.get(0);
        assertEquals("VEGETARIAN", firstDietaryRestrictionOptionsResponse.value());
        assertEquals("Vegetarian", firstDietaryRestrictionOptionsResponse.label());
    }

    @Test
    void getValidDietaryRestrictionValues_returnAllValues() {
        // Arrange
        when(dietaryRestrictionOptionsRepository.getAllDietaryRestrictionOptionsValues()).thenReturn(List.of("VEGETARIAN", "GLUTEN_FREE", "DIABETES_Friendly"));

        // Act 
        List<String> validValues = dietaryRestrictionOptionsService.getValidDietaryRestrictionOptions();

        // Assert
        assertEquals(3, validValues.size());
        assertTrue(validValues.contains("VEGETARIAN")); // first 
        assertTrue(validValues.contains("DIABETES_Friendly")); // last
    }
}