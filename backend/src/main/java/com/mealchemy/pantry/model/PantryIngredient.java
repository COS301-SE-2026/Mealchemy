// PantryIngredient model maps directly to pantry_ingredients table - one field per column

package com.mealchemy.pantry.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.OffsetDateTime;
import java.math.BigDecimal;
import java.util.Optional;

@Entity
@Table(name = "pantry_ingredients")
public class PantryIngredient {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "p_ingredient_id")
    private Integer pIngredientId;

    @Column(name = "user_id", nullable = false) //a user will appear more than once in the table (user1 has apples, oranges etc)
    private Integer userId;

    @Column(name = "ing_id", nullable = false) //can have the same ingredient from ingredient catalogue appear more than once
    private Integer ingId;

    @Column(name = "quantity", nullable = false) 
    private BigDecimal quantity;

    @Column(name = "unit") //CHECK
    private String unit;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "storage_location")
    private String storageLocation;

    // Getters and setters
    public Integer getPIngredientId() {
        return pIngredientId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer id) {
        this.userId = id;
    }

    public Integer getIngredientId() {
        return ingId;
    }

    public void setIngredientId(Integer id) {
        this.ingId = id;
    }

    public BigDecimal getQuantity() {
        return quantity;
    }

    public void setQuantity(BigDecimal quant) {
        this.quantity = quant;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unt) {
        this.unit = unt;
    }

    public OffsetDateTime getCreatedAt() { 
        return createdAt; 
    }

    public OffsetDateTime getUpdatedAt() { 
        return updatedAt; 
    }

    public String getStorageLocation()
    {
        return storageLocation;
    }

    public void setStorageLocation(String storageLocationIn)
    {
        this.storageLocation = storageLocationIn;
    }

}