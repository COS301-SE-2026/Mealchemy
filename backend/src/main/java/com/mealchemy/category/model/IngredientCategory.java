// IngredientCategory model maps directly to ingredient_categories table - one field per column

package com.mealchemy.category.model;

import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.OffsetDateTime;
import java.math.BigDecimal;

@Entity
@Table(name = "ingredient_categories")
public class IngredientCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Integer categoryId;

    @Column(name = "name", nullable = false, unique = true, length = 60)
    private String name;

    @Column(name = "pantry_shelf_life_days")
    private Integer pantryShelfLifeInDays;

    @Column(name = "fridge_shelf_life_days")
    private Integer fridgeShelfLifeInDays;

    // Getters and setters
    public Integer getCategoryId() {
        return categoryId;
    }

    public String getCategoryName() {
        return name;
    }

    public void setCategoryName(String name) {
        this.name = name;
    }

    public Integer getPantryShelfLife() {
        return pantryShelfLifeInDays;
    }

    public void setPantryShelfLife(Integer shelfLife) {
        this.pantryShelfLifeInDays = shelfLife;
    }

    public Integer getFridgeShelfLife() {
        return fridgeShelfLifeInDays;
    }

    public void setFridgeShelfLife(Integer fridgeLife) {
        this.fridgeShelfLifeInDays = shelfLife;
    }

}
