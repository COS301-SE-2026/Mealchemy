package com.mealchemy.recipe.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.*;
import org.hibernate.annotations.*;

/* Import Classes */

@Entity
@Table(name = "recipes")
public class Recipe
{
    /* Declaring fields */
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "recipe_id")
    private int recipeId;

    @Column(name = "owner_id", nullable = false)
    private Integer ownerId;

    @Column(name = "title", length = 200, nullable = false)
    private String title;

    @Column(name = "description", nullable = false)
    private String description;

    @Column(name = "cuisine_type", length = 40, nullable = false)
    private String cuisineType;

    @Column(name = "prep_time_mins", nullable = false)
    private int prepTimeMins;

    @Column(name = "cooking_time_mins", nullable = false)
    private int cookingTimeMins;

    @Column(name = "serving_size", nullable = false)
    private int servingSize;

    @Column(name = "photo_url", nullable = true)
    private String photoUrl;

    @Column(name = "video_url", nullable = true)
    private String videoUrl;

    @Column(name = "external_url", nullable = true)
    private String externalUrl;

    @Column(name = "is_community_published", nullable = false)
    private boolean isCommunityPublished = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt = OffsetDateTime.now();

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt = OffsetDateTime.now();

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeIngredient> ingredients = new ArrayList<>();

    @OneToMany(mappedBy = "recipe", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<RecipeStep> steps = new ArrayList<>();

    @ManyToOne
    @JoinColumn(name = "parent_recipe_id")
    private Recipe parentRecipe;

    /* Getters */
    
    public int getRecipeId()
    {
        return recipeId;
    }

    public Integer getOwnerId()
    {
        return ownerId;
    }

    public String getTitle()
    {
        return title;
    }

    public String getDescription()
    {
        return description;
    }

    public String getCuisineType()
    {
        return cuisineType;
    }

    public int getPrepTimeMins()
    {
        return prepTimeMins;
    }

    public int getCookingTimeMins()
    {
        return cookingTimeMins;
    }

    public int getServingSize()
    {
        return servingSize;
    }

    public String getPhotoUrl()
    {
        return photoUrl;
    }

    public String getVideoUrl()
    {
        return videoUrl;
    }

    public String getExternalUrl()
    {
        return externalUrl;
    }

    public boolean getIsCommunityPublished()
    {
        return isCommunityPublished;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt()
    {
        return updatedAt;
    }

    public List<RecipeIngredient> getIngredients()
    {
        return ingredients;
    }

    public List<RecipeStep> getSteps()
    {
        return steps;
    }

    public Recipe getParentRecipe()
    {
        return parentRecipe;
    }

    /* Setters */

    public void setOwnerId(Integer ownerIdIn)
    {
        ownerId = ownerIdIn;
    }

    public void setTitle(String titleIn)
    {
        title = titleIn;
    }

    public void setDescription(String descriptionIn)
    {
        description = descriptionIn;
    }

    public void setCuisineType(String cuisineTypeIn)
    {
        cuisineType = cuisineTypeIn;
    }

    public void setPrepTimeMins(int prepTimeMinsIn)
    {
        prepTimeMins = prepTimeMinsIn;
    }

    public void setCookingTimeMins(int cookingTimeMinsIn)
    {
        cookingTimeMins = cookingTimeMinsIn;
    }

    public void setServingSize(int servingSizeIn)
    {
        servingSize = servingSizeIn;
    }

    public void setPhotoUrl(String photoUrlIn)
    {
        photoUrl = photoUrlIn;
    }

    public void setVideoUrl(String videoUrlIn)
    {
        videoUrl = videoUrlIn;
    }

    public void setExternalUrl(String externalUrlIn)
    {
        externalUrl = externalUrlIn;
    }

    public void setIsCommunityPublished(boolean isCommunityPublishedIn)
    {
        isCommunityPublished = isCommunityPublishedIn;
    }

    public void setUpdatedAt(OffsetDateTime updatedAtIn)
    {
        updatedAt = updatedAtIn;
    }

    public void setIngredients(List<RecipeIngredient> ingredientsIn)
    {
        ingredients = ingredientsIn;
    }

    public void setSteps(List<RecipeStep> stepsIn)
    {
        steps = stepsIn;
    }

    public void setParentRecipe(Recipe parentRecipeIn)
    {
        parentRecipe = parentRecipeIn;
    }
}