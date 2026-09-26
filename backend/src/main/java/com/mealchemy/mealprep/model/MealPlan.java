package com.mealchemy.mealprep.model;

/* Import libraries */
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/* Import classes */

public class MealPlan
{
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "plan_id")
    private Integer planId;

    @Column(name = "vault_id")
    private Integer vaultId;

    @Column(name = "created_by")
    private Integer createdBy;

    @CreationTimestamp
    @Column(name = "created_at")
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @JoinColumn(mappedBy = "plan")
    private List<MealPlanEntry> entries;

    /* Getters */

    public Integer getPlanId()
    {
        return planId;
    }

    public Integer getVaultId()
    {
        return vaultId;
    }

    public Integer getCreatedBy()
    {
        return createdBy;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt()
    {
        return updatedAt;
    }

    public List<MealPlanEntry> getEntries()
    {
        return entries;
    }

    /* Setters */

    public void setEntries(List<MealPlanEntry> entriesIn)
    {
        entries = entriesIn;
    }
}