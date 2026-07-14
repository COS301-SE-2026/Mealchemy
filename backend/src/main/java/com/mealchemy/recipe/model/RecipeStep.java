package com.mealchemy.recipe.model;

/* Import libraries */

import jakarta.persistence.*;

/* Import classes */

@Entity
@Table(name = recipe_steps)
public class RecipeStep
{
    /* Declaring fields */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "step_id")
    private int stepId;

    @Column(name = "recipe_id", nullable = false)
    private int recipeId;

    @Column(name = "step_nr", nullable = false)
    private int stepNr;

    @Column(name = "content", nullable = false)
    private String content;

    /* Getters */

    public int getStepId()
    {
        return stepId;
    }

    public int getRecipeId()
    {
        return recipeId;
    }

    public int getStepNr()
    {
        return stepNr;
    }

    public String getContent()
    {
        return content;
    }

    /* Setters */

    public void setStepNr(int stepNrIn)
    {
        stepNr = stepNrIn;
    }

    public void setContent(String contentIn)
    {
        content = contentIn;
    }
}