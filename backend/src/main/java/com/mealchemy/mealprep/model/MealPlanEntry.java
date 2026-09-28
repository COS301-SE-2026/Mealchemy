package com.mealchemy.mealprep.model;

/* Import libraries */
import jakarta.persistence.*;
import java.time.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/* Import classes */
import com.mealchemy.shared.enums.MealSlot;
import com.mealchemy.shared.enums.MealPlanEntrySource;

@Entity
@Table(name = "meal_plan_entries", uniqueConstraints = @UniqueConstraint(columnNames = {"plan_id", "entry_date", "meal_slot"}))
public class MealPlanEntry {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "entry_id")
    private Integer entryId;

    @ManyToOne
    @JoinColumn(name = "plan_id", nullable = false)
    private MealPlan plan;

    @Column(name = "recipe_id", nullable = false)
    private Integer recipeId;

    @Column(name = "entry_date", nullable = false)
    private LocalDate entryDate;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "meal_slot", nullable = false, columnDefinition = "meal_slot")
    private MealSlot mealSlot;

    @Column(name = "meal_time", nullable = false)
    private LocalTime mealTime;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "source", nullable = false, columnDefinition = "meal_plan_entry_source")
    private MealPlanEntrySource source = MealPlanEntrySource.MANUAL;

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

    @Column(name = "title", nullable = true)
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

    public OffsetDateTime getUpdatedAt()
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

    public void setPlan(MealPlan planIn)
    {
        plan = planIn;
    }

    public void setRecipeId(Integer recipeIdIn)
    {
        recipeId = recipeIdIn;
    }

    public void setEntryDate(LocalDate entryDateIn)
    {
        entryDate = entryDateIn;
    }

    public void setMealSlot(MealSlot mealSlotIn)
    {
        mealSlot = mealSlotIn;
    }

    public void setMealTime(LocalTime mealTimeIn)
    {
        mealTime = mealTimeIn;
    }

    public void setSource(MealPlanEntrySource sourceIn)
    {
        source = sourceIn;
    }

    public void setAddedBy(Integer addedByIn)
    {
        addedBy = addedByIn; 
    }

    public void setNote(String noteIn)
    {
        note = noteIn;
    }

    public void setTitle(String titleIn)
    {
        title = titleIn;
    }
}


