package com.mealchemy.tags.model;

/* Import classes */
import com.mealchemy.recipe.model.Recipe;

/* Import libraries */
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;

@Entity
@Table(name = "recipe_tags")
public class RecipeTags {
    /* Declaring fields */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "recipe_id")
    private Recipe recipe;

    @ManyToOne
    @JoinColumn(name = "tag_id")
    private Tags tag;

    /* Getters */

    public Integer getId()
    {
        return id;
    }

    public Recipe getRecipe()
    {
        return recipe;
    }

    public Tags getTag()
    {
        return tag;
    }

    /* Setters */

    public void setRecipe(Recipe recipeIn)
    {
        this.recipe = recipeIn;
    }

    public void setTag(Tags tagIn)
    {
        this.tag = tagIn;
    }
}
