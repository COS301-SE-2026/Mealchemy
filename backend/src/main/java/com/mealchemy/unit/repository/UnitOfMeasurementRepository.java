// talks to units_of_measurement db table
package com.mealchemy.unit.repository;

import com.mealchemy.unit.model.UnitOfMeasurement;
import org.springframework.data.jpa.repository.JpaRepository;
import com.mealchemy.shared.enums.MeasurementSystem;

import java.util.Optional;
import java.util.List;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UnitOfMeasurementRepository extends JpaRepository<UnitOfMeasurement, Integer> {
    // built-in types

    @Query("""
            SELECT u FROM UnitOfMeasurement u WHERE u.system = :system OR u.system IS NULL
            """)
    List<UnitOfMeasurement> findBySystemOrGeneral(@Param("system") MeasurementSystem system);
    
}
