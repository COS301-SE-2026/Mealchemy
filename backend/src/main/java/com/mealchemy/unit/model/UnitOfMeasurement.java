// IngredientCategory model maps directly to ingredient_categories table - one field per column

package com.mealchemy.unit.model;

import com.mealchemy.shared.enums.MeasurementSystem;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import jakarta.persistence.*;

@Entity
@Table(name = "units_of_measurement")
public class UnitOfMeasurement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "unit_id")
    private Integer unitId;

    @Column(name = "name", nullable = false, unique = true)
    private String name;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "system", columnDefinition = "measurement_system_enum")
    private MeasurementSystem system;

    // Getters and setters
    public Integer getUnitId() {
        return unitId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public MeasurementSystem getMeasurementSystem() {
        return system; 
    }
    
    public void setMeasurementSystem(MeasurementSystem system) {
        this.system = system;
    }


}
