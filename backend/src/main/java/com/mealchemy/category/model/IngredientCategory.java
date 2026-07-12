// IngredientCategory model maps directly to ingredient_categories table - one field per column

package com.mealchemy.category.model;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

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
    private Short pantryShelfLifeInDays;

    @Column(name = "fridge_shelf_life_days")
    private Short fridgeShelfLifeInDays;

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

    public Short getPantryShelfLife() {
        return pantryShelfLifeInDays;
    }

    public void setPantryShelfLife(Short shelfLife) {
        this.pantryShelfLifeInDays = shelfLife;
    }

    public Short getFridgeShelfLife() {
        return fridgeShelfLifeInDays;
    }

    public void setPantryFridgeLife(Short fridgeLife) {
        this.fridgeShelfLifeInDays = fridgeLife;
    }

}
