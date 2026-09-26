package com.mealchemy.mealprep.model;

/* Import libraries */
import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.MealPlanEntrySource;

@Entity
@Table(name = "meal_plan_entry")
public class MealPlanEntry {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "entry_id")
    private Integer entryId;

    @Column(name = "plan", nullable = false)
    private MealPlan plan;

    @Column(name = "recipe_id", nullable = false)
    private Integer recipeId;

    @Column(name = "entry_date", nullable = false)
    private LocalDate entryDate;

    @Column(name = "meal_slot", nullable = false)
    private MealSlot mealSlot;

    @Column(name = "meal_time", nullable = false)
    private LocalTime mealTime;

    @Column(name = "source", nullable = false)
    private MealPlanEntrySource source;

    @Column(name = "added_by", nullable = false)
    private Integer addedBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "note", nullable = true)
    private String note;

    @Column(name = "title", nullable = false)
    private String title;

    /* Getters */

    public Integer getEntryId()
    {
        return entryId;        
    }

    public MealPlan getPlan()
    {
        return plan;
    }

    public Integer getRecipeId()
    {
        return recipeId;
    }

    public LocalDate getEntryDate()
    {
        return entryDate;
    }

    public MealSlot getMealSlot()
    {
        return mealSlot;
    }

    public LocalTime getMealTime()
    {
        return mealTime;
    }

    public MealPlanEntrySource getSource()
    {
        return source;
    }

    public Integer getAddedBy()
    {
        return addedBy;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }

    public OffsetDateTime getupdatedAt()
    {
        return updatedAt;
    }

    public String getNote()
    {
        return note;
    }

    public String getTitle()
    {
        return title;
    }

    /* Setters */
}


