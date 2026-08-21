package com.mealchemy.unit.service;

// model
import com.mealchemy.unit.model.UnitOfMeasurement;
// repository
import com.mealchemy.unit.repository.UnitOfMeasurementRepository;
// dto
import com.mealchemy.unit.dto.UnitOfMeasurementResponse;
// enum
import com.mealchemy.shared.enums.MeasurementSystem;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service 
public class UnitOfMeasurementService {

    private final UnitOfMeasurementRepository unitOfMeasurementRepository;
    
    UnitOfMeasurementService(UnitOfMeasurementRepository unitOfMeasurementRepository) {
        this.unitOfMeasurementRepository = unitOfMeasurementRepository;
    }

    // GET - all units
    public List<UnitOfMeasurementResponse> getAllUnits() {
        List<UnitOfMeasurement> units = unitOfMeasurementRepository.findAll();

        // build response
        return units.stream()
                    .map(unit -> new UnitOfMeasurementResponse(
                        unit.getUnitId(),
                        unit.getName(),
                        unit.getMeasurementSystem()
                    ))
                    .collect(Collectors.toList());
    }


//     // GET - find by system (IMPERIAL OR METRIC)
//     public List<UnitOfMeasurementResponse> getUnitByMeasurementSystem(MeasurementSystem system) {
//         List<UnitOfMeasurement> units = unitOfMeasurementRepository.findByMeasurementSystem(system);

//         // build response
//         return units.stream()
//                     .map(unit -> new UnitOfMeasurementResponse(
//                         unit.getUnitId(),
//                         unit.getName(),
//                         unit.getMeasurementSystem()
//                     ))
//                     .collect(Collectors.toList());
//     }
}