package com.mealchemy.recipe.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;

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
    private int ownerId;

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

    @Columns(name = "serving_size", nullable = false)
    private int servingSize;

    @Columns(name = "photo_url", nullable = true)
    private String photoUrl;

    @Columns(name = "video_url", nullable = true)
    private String videoUrl;

    @Columns(name = "external_url", nullable = true)
    private String externalUrl;

    @Column(name = "is_community_published", nullable = false)
    private boolean isCommunityPublished = false;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt = OffsetDateTime.now();

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt = OffsetDateTime.now();

    /* Getters */

    /* Setters */
}