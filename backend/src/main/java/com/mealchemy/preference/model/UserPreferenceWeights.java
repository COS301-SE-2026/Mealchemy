package com.mealchemy.preference.model;

/* Importing classes */

/* Importing libraries */

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;
import java.util.List;
import java.math.BigDecimal;

public class UserPreferenceWeights {
    /* Declaring variables */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "weight_id")
    private Integer weightId;

    @Column(name = "user_id", unique = true, nullable = false)
    private Integer userId;

    @Column(name = "pantry_match", precision = 5, scale = 4, nullable = false)
    private BigDecimal pantryMatch;

    @Column(name = "cuisine", precision = 5, scale = 4, nullable = false)
    private BigDecimal cuisine;

    @Column(name = "nutrition", precision = 5, scale = 4, nullable = false)
    private BigDecimal nutrition;

    @Column(name = "freshness", precision = 5, scale = 4, nullable = false)
    private BigDecimal freshness;

    @Column(name = "novelty", precision = 5, scale = 4, nullable = false)
    private BigDecimal novelty;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    /* Getters */
    
    public Integer getWeightId()
    {
        return weightId;
    }

    public Integer getUserId()
    {
        return userId;
    }

    public BigDecimal getPantryMatch()
    {
        return pantryMatch;
    }

    public BigDecimal getCuisine()
    {
        return cuisine;
    }

    public BigDecimal getNutrition()
    {
        return nutrition;
    }

    public BigDecimal getFreshness()
    {
        return freshness;
    }

    public BigDecimal getNovelty()
    {
        return novelty;
    }

    public OffsetDateTime getUpdatedAt()
    {
        return updateAt;
    }

    /* Setters */
}
