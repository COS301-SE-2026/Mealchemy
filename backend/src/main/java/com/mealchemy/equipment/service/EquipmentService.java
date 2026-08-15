package com.mealchemy.equipment.service;

// model
import com.mealchemy.equipment.model.Equipment;
// repository
import com.mealchemy.equipment.repository.EquipmentRepository;
// dto
import com.mealchemy.equipment.dto.EquipmentResponse;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service 
public class EquipmentService {

    private final EquipmentRepository equipmentRepository;
    
    public EquipmentService(EquipmentRepository equipmentRepository) {
        this.equipmentRepository = equipmentRepository;
    }

    // GET - all equipment available
    public List<EquipmentResponse> getAllEquipmentOptions() {
        return equipmentRepository.getAllEquipment();
    }
}