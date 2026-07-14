package com.mealchemy.recipe.model;

/* Import libraries */

import jakarta.persistence.*;

/* Import classes */

@Entity
@Table(name = recipe_ingredients)
public class RecipeIngredient
{
    /* Declaring fields */
    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ingredient_id")
    private int ingredientId;
    
    @Column(name = "recipe_id", nullable = false)
    private int recipeId;

    @Column(name = "ing_id", nullable = false)
    private int ingId;

    @Column(name = "quantity", precision = 10, scale = 3, nullable = false)
    private BigDecimal quantity;

    @Column(name = "unit", length = 30, nullable = false)
    private String unit;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;  

    /* Getters */

    /* Setters */
}
