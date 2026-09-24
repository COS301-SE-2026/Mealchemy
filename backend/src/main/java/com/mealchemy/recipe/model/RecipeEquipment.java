package com.mealchemy.recipe.model;

/* Import libraries */

import jakarta.persistence.*;

/* Import classes */
import com.mealchemy.equipment.model.Equipment;


@Entity
@Table(name = "recipe_equipment")
public class RecipeEquipment
{
    /* Declaring fields */
    @Id 
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int recipeEquipmentId;
    
    @ManyToOne
    @JoinColumn(name = "recipe_id", nullable = false)
    private Recipe recipe;

    @ManyToOne
    @JoinColumn(name = "equipment_id", nullable = false)
    private Equipment equipment;


    /* Getters */

    public int getRecipeEquipmentId()
    {
        return recipeEquipmentId;
    }

    public Recipe getRecipe()
    {
        return recipe;
    }

    public Equipment getEquipment()
    {
        return equipment;
    }


    /* Setters */

    public void setRecipe(Recipe recipeIn)
    {
        recipe = recipeIn;
    }

    public void setEquipment(Equipment equipmentIn)
    {
        equipment = equipmentIn;
    }
}
