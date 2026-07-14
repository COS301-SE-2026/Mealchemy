package com.mealchemy.recipe.model;

/* Import libraries */

import jakarta.persistence.*;
import java.math.BigDecimal;

/* Import classes */

@Entity
@Table(name = "recipe_ingredients")
public class RecipeIngredient
{
    /* Declaring fields */
    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ingredient_id")
    private int ingredientId;
    
    @ManyToOne
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @Column(name = "ing_id", nullable = false)
    private int ingId;

    @Column(name = "quantity", precision = 10, scale = 3, nullable = false)
    private BigDecimal quantity;

    @Column(name = "unit", length = 30, nullable = false)
    private String unit;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;  

    /* Getters */

    public int getIngredientId()
    {
        return ingredientId;
    }

    public Recipe getRecipe()
    {
        return recipe;
    }

    public int getIngId()
    {
        return ingId;
    }

    public BigDecimal getQuantity()
    {
        return quantity;
    }

    public String getUnit()
    {
        return unit;
    }

    public int getSortOrder()
    {
        return sortOrder;
    }

    /* Setters */

    public void setRecipe(Recipe recipeIn)
    {
        recipe = recipeIn;
    }

    public void setQuantity(BigDecimal quantityIn)
    {
        quantity = quantityIn;
    }

    public void setUnit(String unitIn)
    {
        unit = unitIn;
    }

    public void setSortOrder(int sortOrderIn)
    {
        sortOrder = sortOrderIn;
    }
}
