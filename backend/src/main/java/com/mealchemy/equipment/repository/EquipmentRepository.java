// talks to equipment_options db table
package com.mealchemy.equipment.repository;

import com.mealchemy.equipment.model.Equipment;
import com.mealchemy.equipment.dto.EquipmentResponse;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

import org.springframework.data.jpa.repository.Query;

public interface EquipmentRepository extends JpaRepository<Equipment, Integer> {
    // built-in types

    @Query("""
            SELECT new com.mealchemy.equipment.dto.EquipmentResponse(
                e.equipmentId,
                e.value,
                e.label
            )
            FROM Equipment e
        """)
        List<EquipmentResponse> getAllEquipment();
}
