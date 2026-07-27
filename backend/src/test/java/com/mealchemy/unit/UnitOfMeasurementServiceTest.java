// unit testing for shopping list

package com.mealchemy.unit;

//dtos
import com.mealchemy.unit.dto.UnitOfMeasurementResponse;
//models
import com.mealchemy.unit.model.UnitOfMeasurement;
//repositories
import com.mealchemy.unit.repository.UnitOfMeasurementRepository;

//enum for shopping list status
import com.mealchemy.shared.enums.MeasurementSystem;

import com.mealchemy.unit.service.UnitOfMeasurementService;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UnitOfMeasurementServiceTest {
    // @Mock - create fake version of dependency
    @Mock private UnitOfMeasurementRepository unitOfMeasurementRepository;

    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private UnitOfMeasurementService unitOfMeasurementService;

    
    // GET all units of measurement
    @Test
    void getAllUnitsOfMeasurement_valid_returns200() {
        // Arrange 
        UnitOfMeasurement unit1 = new UnitOfMeasurement();
        unit1.setName("g");
        unit1.setMeasurementSystem(MeasurementSystem.METRIC);

        UnitOfMeasurement unit2 = new UnitOfMeasurement();
        unit2.setName("kg");
        unit2.setMeasurementSystem(MeasurementSystem.METRIC);

        UnitOfMeasurement unit3 = new UnitOfMeasurement();
        unit3.setName("oz");
        unit3.setMeasurementSystem(MeasurementSystem.IMPERIAL);

        UnitOfMeasurement unit4 = new UnitOfMeasurement();
        unit4.setName("lb");
        unit4.setMeasurementSystem(MeasurementSystem.IMPERIAL);

        when(unitOfMeasurementRepository.findAll()).thenReturn(List.of(unit1, unit2, unit3, unit4));

        // Act
        List<UnitOfMeasurementResponse> unitsList = unitOfMeasurementService.getAllUnits();

        // Assert
        assertEquals(4, unitsList.size());
        UnitOfMeasurementResponse firstUnitResponse = unitsList.get(0);
        assertEquals("g", firstUnitResponse.name());
        assertEquals(MeasurementSystem.METRIC, firstUnitResponse.system());

    }
}