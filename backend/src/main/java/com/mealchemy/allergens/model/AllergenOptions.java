package com.mealchemy.allergens.model;

// import libraries
import jakarta.persistence.*;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;

@Entity
@Table(name = "allergen_options")
public class AllergenOptions
{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "value", nullable = false, unique = true)
    private String value;

    @Column(name = "label", nullable = false)
    private String label;

    @Column(name = "description")
    private String description;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;


    /* Getters */
    public int getId() {
        return id;
    }

    public String getValue() {
        return value;
    }

    public String getLabel() {
        return label;
    }
    
    public String getDescription() {
        return description;
    }
    
    public Boolean getIsActive() {
        return isActive;
    }
    
    /* Setters */
    public void setValue(String valueIn) {
        value = valueIn;
    }

    public void setLabel(String labelIn) {
        label = labelIn;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }
}