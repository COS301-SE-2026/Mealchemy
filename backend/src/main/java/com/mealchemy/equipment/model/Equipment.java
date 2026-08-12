// Equipment model maps directly to equipment_options table - one field per column

package com.mealchemy.equipment.model;

import jakarta.persistence.*;

@Entity
@Table(name = "equipment_options")
public class Equipment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer equipmentId;

    @Column(name = "value", nullable = false, unique = true)
    private String value;

    @Column(name = "label", nullable = false)
    private String label;


    // Getters and Setters
    public Integer getEquipmentId() {
        return equipmentId;
    }

    public String getEquipmentValue() {
        return value;
    }

    public void setEquipmentValue(String value) {
        this.value = value;
    }

    public String getEquipmentLabel() {
        return label;
    }

    public void setEquipmentLabel(String label) {
        this.label = label;
    }



}
