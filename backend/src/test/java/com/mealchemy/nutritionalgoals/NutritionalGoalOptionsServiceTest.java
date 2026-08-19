// allergens testing for shopping list

package com.mealchemy.nutritionalgoals;

//dtos
import com.mealchemy.nutritionalgoals.dto.NutritionalGoalOptionsResponse;
//models
import com.mealchemy.nutritionalgoals.model.NutritionalGoalOptions;
//repositories
import com.mealchemy.nutritionalgoals.repository.NutritionalGoalOptionsRepository;


import com.mealchemy.nutritionalgoals.service.NutritionalGoalOptionsService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class NutritionalGoalOptionsServiceTest {
    // @Mock - create fake version of dependency
    @Mock private NutritionalGoalOptionsRepository nutritionalGoalOptionsRepository;

    // @InjectMocks creates the real NutritionalGoalOptions service and injects the mocks above into it 
    @InjectMocks
    private NutritionalGoalOptionsService nutritionalGoalOptionsService;

    
    // GET all nutrtional goal options
    @Test
    void getAllNutritionalGoalOptions_valid_returns200() {
        // Arrange 

        NutritionalGoalOptionsResponse highProtein = new NutritionalGoalOptionsResponse(
            1, 
            "HIGH_PROTEIN", 
            "High Protein"
        );

        NutritionalGoalOptionsResponse lowCarb = new NutritionalGoalOptionsResponse(
            2, 
            "LOW_CARB", 
            "Low Carb"
        );


        when(nutritionalGoalOptionsRepository.getAllNutritionalGoalOptions()).thenReturn(List.of(highProtein, lowCarb));

        // Act
        List<NutritionalGoalOptionsResponse> nutritionalGoalsList = nutritionalGoalOptionsService.getAllNutritionalGoalOptions();

        // Assert
        assertEquals(2, nutritionalGoalsList.size());
        NutritionalGoalOptionsResponse firstNutritionalGoalOptionsResponse = nutritionalGoalsList.get(0);
        assertEquals("HIGH_PROTEIN", firstNutritionalGoalOptionsResponse.value());
        assertEquals("High Protein", firstNutritionalGoalOptionsResponse.label());
    }

    @Test
    void getValidNutritionalGoalValues_returnAllValues() {
        // Arrange
        when(nutritionalGoalOptionsRepository.getAllNutritionalGoalOptionsValues()).thenReturn(List.of("HIGH_PROTEIN", "LOW_CARB"));

        // Act 
        List<String> validValues = nutritionalGoalOptionsService.getValidNutritionalGoalOptions();

        // Assert
        assertEquals(2, validValues.size());
        assertTrue(validValues.contains("HIGH_PROTEIN")); // first 
        assertTrue(validValues.contains("LOW_CARB")); // last
    }
}