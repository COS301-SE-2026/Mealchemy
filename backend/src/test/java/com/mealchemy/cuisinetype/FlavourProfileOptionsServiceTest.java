// allergens testing for shopping list

package com.mealchemy.cuisinetype;

//dtos
import com.mealchemy.cuisinetype.dto.FlavourProfileOptionsResponse;
//models
import com.mealchemy.cuisinetype.model.FlavourProfileOptions;
//repositories
import com.mealchemy.cuisinetype.repository.FlavourProfileOptionsRepository;


import com.mealchemy.cuisinetype.service.FlavourProfileOptionsService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class FlavourProfileOptionsServiceTest {
    // @Mock - create fake version of dependency
    @Mock private FlavourProfileOptionsRepository flavourProfileOptionsRepository;

    // @InjectMocks creates the real FlavourProfileOptions service and injects the mocks above into it 
    @InjectMocks
    private FlavourProfileOptionsService flavourProfileOptionsService;

    
    // GET all flavour profile options
    @Test
    void getAllFlavourProfileOptions_valid_returns200() {
        // Arrange 
        FlavourProfileOptions italian = new FlavourProfileOptions();
        italian.setValue("ITALIAN"); 
        italian.setLabel("Italian");
    
        FlavourProfileOptions mexican = new FlavourProfileOptions();
        mexican.setValue("MEXICAN"); 
        mexican.setLabel("Mexican");

        FlavourProfileOptions caribbean = new FlavourProfileOptions();
        caribbean.setValue("CARIBBEAN"); 
        caribbean.setLabel("Caribbean");

        // check
        when(flavourProfileOptionsRepository.findAll()).thenReturn(List.of(italian, mexican, caribbean));

        // Act 
        List<FlavourProfileOptionsResponse> flavourProfileOptionsList = flavourProfileOptionsService.getAllCuisineTypes();

        // Assert
        assertEquals(3, flavourProfileOptionsList.size());
        FlavourProfileOptionsResponse firstFlavourProfileOptionsResponse = flavourProfileOptionsList.get(0);
        assertEquals("ITALIAN", firstFlavourProfileOptionsResponse.value());
        assertEquals("Italian", firstFlavourProfileOptionsResponse.label());
    }

    @Test
    void getValidFlavourProfileOptionValues_returnAllValues() {
        // Arrange
        when(flavourProfileOptionsRepository.getAllValues()).thenReturn(List.of("ITALIAN", "MEXICAN", "CARIBBEAN"));

        // Act 
        List<String> validValues = flavourProfileOptionsService.getValidCuisineTypes();

        // Assert
        assertEquals(3, validValues.size());
        assertTrue(validValues.contains("ITALIAN")); // first 
        assertTrue(validValues.contains("CARIBBEAN")); // last
    }
}