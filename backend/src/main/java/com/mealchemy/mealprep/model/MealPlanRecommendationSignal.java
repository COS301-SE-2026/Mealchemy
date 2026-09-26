package com.mealchemy.mealprep.model;

/* Import libraries */
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/* Import classes */

public class MealPlanEntry {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "signal_id")
    private Integer signalId;

    @Column(name = "entry_id", nullable = false)
    private Integer entryId;

    @Column(name = "recipe_id", nullable = false)
    private Integer recipeId;

    @Column(name = "cuisine", nullable = false)
    private String cuisine;

    @Column(name = "signal_scores", nullable = false)
    private Map<String, Double> signalScores;

    @CreationTimestamp
    @Column(name = "captured_at", nullable = false)
    private OffsetDateTime capturedAt;

    @Column(name = "processed_at", nullable = true)
    private OffsetDateTime processedAt;

    /* Getters */

    public Integer getSignalId()
    {
        return signalId;
    }

    public Integer getEntryId()
    {
        return entryId;
    }

    public Integer getRecipeId()
    {
        return recipeId;
    }

    public String getCuisine()
    {
        return cuisine;
    }

    public Map<String, Double> getSignalScores()
    {
        return signalScores;
    }

    public OffsetDateTime getCapturedAt()
    {
        return capturedAt;
    }

    public OffsetDateTime getProcessedAt()
    {
        return preocessedAt;
    }

    /* Setters */
}