package com.mealchemy.unit.service;

// model
import com.mealchemy.unit.model.UnitOfMeasurement;
import com.mealchemy.profile.model.UserProfile;
// repository
import com.mealchemy.unit.repository.UnitOfMeasurementRepository;
import com.mealchemy.profile.repository.UserProfileRepository;
// dto
import com.mealchemy.unit.dto.UnitOfMeasurementResponse;
// enum
import com.mealchemy.shared.enums.MeasurementSystem;
import com.mealchemy.shared.enums.PreferredUnit;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service 
public class UnitOfMeasurementService {

    private final UnitOfMeasurementRepository unitOfMeasurementRepository;
    private final UserProfileRepository userProfileRepository;
    
    UnitOfMeasurementService(UnitOfMeasurementRepository unitOfMeasurementRepository, UserProfileRepository userProfileRepository) {
        this.unitOfMeasurementRepository = unitOfMeasurementRepository;
        this.userProfileRepository = userProfileRepository;
    }

    // GET - all units
    public List<UnitOfMeasurementResponse> getUnitsForUser(Integer userId) {
        PreferredUnit preferredUnit = userProfileRepository.findByUserId(userId).map(UserProfile::getPreferredUnit)
                                                                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User profile not found."));

        MeasurementSystem measurementSystem = MeasurementSystem.METRIC;

        if (preferredUnit == PreferredUnit.IMPERIAL) {
            measurementSystem = MeasurementSystem.IMPERIAL;
        }

        List<UnitOfMeasurement> units = unitOfMeasurementRepository.findBySystemOrGeneral(measurementSystem);

        // build response
        return units.stream()
                    .map(unit -> new UnitOfMeasurementResponse(
                        unit.getUnitId(),
                        unit.getName(),
                        unit.getMeasurementSystem()
                    ))
                    .collect(Collectors.toList());
    }



}