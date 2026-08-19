package com.mealchemy.tags.model;

/* Import classes */

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

    @Column(name = "recipe_id")
    private Integer recipeId;

    @Column(name = "tag_id")
    private Integer tagId;

    /* Getters */

    /* Setters */
}
