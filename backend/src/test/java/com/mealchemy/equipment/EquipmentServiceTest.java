// equipment testing for shopping list

package com.mealchemy.equipment;

//dtos
import com.mealchemy.equipment.dto.EquipmentResponse;
//models
import com.mealchemy.equipment.model.Equipment;
//repositories
import com.mealchemy.equipment.repository.EquipmentRepository;


import com.mealchemy.equipment.service.EquipmentService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class EquipmentServiceTest {
    // @Mock - create fake version of dependency
    @Mock private EquipmentRepository equipmentRepository;

    // @InjectMocks creates the real EquipmentService and injects the mocks above into it 
    @InjectMocks
    private EquipmentService equipmentService;

    
    // GET all equipment options
    @Test
    void getAllEquipmentOptions_valid_returns200() {
        // Arrange 

        EquipmentResponse oven = new EquipmentResponse(
            1, 
            "OVEN", 
            "Oven"
        );

        EquipmentResponse microwave = new EquipmentResponse(
            2, 
            "MICROWAVE", 
            "Microwave"
        );

        EquipmentResponse airfryer = new EquipmentResponse(
            3, 
            "AIRFRYER", 
            "Airfryer"
        );

        EquipmentResponse blender = new EquipmentResponse(
            4, 
            "BLENDER", 
            "Blender"
        );

        when(equipmentRepository.getAllEquipment()).thenReturn(List.of(oven, microwave, airfryer, blender));

        // Act
        List<EquipmentResponse> equipmentList = equipmentService.getAllEquipmentOptions();

        // Assert
        assertEquals(4, equipmentList.size());
        EquipmentResponse firstEquipmentResponse = equipmentList.get(0);
        assertEquals("OVEN", firstEquipmentResponse.value());
        assertEquals("Oven", firstEquipmentResponse.label());
    }

    @Test
    void getValidEquipmentValues_returnAllValues() {
        // Arrange
        when(equipmentRepository.getAllEquipmentValues()).thenReturn(List.of("OVEN", "MICROWAVE", "AIRFRYER", "BLENDER"));

        // Act 
        List<String> validValues = equipmentService.getValidEquipmentValues();

        // Assert
        assertEquals(4, validValues.size());
        assertTrue(validValues.contains("OVEN")); // first 
        assertTrue(validValues.contains("BLENDER")); // last
    }
}