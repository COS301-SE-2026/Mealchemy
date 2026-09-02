// unit testing for shopping list

package com.mealchemy.unit;

//dtos
import com.mealchemy.unit.dto.UnitOfMeasurementResponse;
//models
import com.mealchemy.unit.model.UnitOfMeasurement;
import com.mealchemy.profile.model.UserProfile;
//repositories
import com.mealchemy.unit.repository.UnitOfMeasurementRepository;
import com.mealchemy.profile.repository.UserProfileRepository;

//enum for shopping list status
import com.mealchemy.shared.enums.MeasurementSystem;
import com.mealchemy.shared.enums.PreferredUnit;

import com.mealchemy.unit.service.UnitOfMeasurementService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class UnitOfMeasurementServiceTest {
    // @Mock - create fake version of dependency
    @Mock private UnitOfMeasurementRepository unitOfMeasurementRepository;
    @Mock private UserProfileRepository userProfileRepository;

    // @InjectMocks creates the real PantryService and injects the mocks above into it - actually testing ShoppingListService
    @InjectMocks
    private UnitOfMeasurementService unitOfMeasurementService;

    private UserProfile metricUser;
    private UserProfile imperialUser;

    @BeforeEach
    void setup() {
        metricUser = new UserProfile();
        metricUser.setPreferredUnit(PreferredUnit.METRIC);

        imperialUser = new UserProfile();
        imperialUser.setPreferredUnit(PreferredUnit.IMPERIAL);
    }

    // GET all units of measurement
    @Test
    void getUnitsForUser_metric_valid_returns200() {
        // Arrange 
        UnitOfMeasurement unit1 = new UnitOfMeasurement();
        unit1.setName("g");
        unit1.setMeasurementSystem(MeasurementSystem.METRIC);

        UnitOfMeasurement unit2 = new UnitOfMeasurement();
        unit2.setName("kg");
        unit2.setMeasurementSystem(MeasurementSystem.METRIC);

        UnitOfMeasurement unit3 = new UnitOfMeasurement();
        unit3.setName("pinch");
        unit3.setMeasurementSystem(null);

        when(userProfileRepository.findByUserId(1)).thenReturn(Optional.of(metricUser));
        when(unitOfMeasurementRepository.findBySystemOrGeneral(MeasurementSystem.METRIC)).thenReturn(List.of(unit1, unit2, unit3));

        // Act
        List<UnitOfMeasurementResponse> unitsList = unitOfMeasurementService.getUnitsForUser(1);

        // Assert
        assertEquals(3, unitsList.size());
        UnitOfMeasurementResponse firstUnitResponse = unitsList.get(0);
        assertEquals("g", firstUnitResponse.name());
        assertEquals(MeasurementSystem.METRIC, firstUnitResponse.system());
    }

    @Test
    void getUnitsForUser_imperial_valid_returns200() {
        // Arrange 
        UnitOfMeasurement unit1 = new UnitOfMeasurement();
        unit1.setName("oz");
        unit1.setMeasurementSystem(MeasurementSystem.IMPERIAL);

        UnitOfMeasurement unit2 = new UnitOfMeasurement();
        unit2.setName("lb");
        unit2.setMeasurementSystem(MeasurementSystem.IMPERIAL);

        UnitOfMeasurement unit3 = new UnitOfMeasurement();
        unit3.setName("pinch");
        unit3.setMeasurementSystem(null);

        when(userProfileRepository.findByUserId(2)).thenReturn(Optional.of(imperialUser));
        when(unitOfMeasurementRepository.findBySystemOrGeneral(MeasurementSystem.IMPERIAL)).thenReturn(List.of(unit1, unit2, unit3));

        // Act
        List<UnitOfMeasurementResponse> unitsList = unitOfMeasurementService.getUnitsForUser(2);

        // Assert
        assertEquals(3, unitsList.size());
        UnitOfMeasurementResponse firstUnitResponse = unitsList.get(0);
        assertEquals("oz", firstUnitResponse.name());
        assertEquals(MeasurementSystem.IMPERIAL, firstUnitResponse.system());
    }
}