package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.util.*;
import java.time.OffsetDateTime;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/* Import classes */

import com.mealchemy.auth.model.User;

@Entity
@Table(name = "recipe_edit_locks")
public class RecipeEditLock {
    /* Declaring fields */

    @Id
    @Column(name = "recipe_id")
    private Integer recipeId; // PK enforces one lock per recipe

    @ManyToOne
    @JoinColumn(name = "locked_by_user_id", nullable = false) 
    private User lockedBy;

    @CreationTimestamp
    @Column(name = "acquired_at", nullable = false)
    private OffsetDateTime acquiredAt;

    @Column(name = "expires_at", nullable = false)
    private OffsetDateTime expiresAt;

    /* Getters */

    public Integer getRecipeId()
    {
        return recipeId;
    }

    public User getLockedByUser()
    {
        return lockedBy;
    }

    public OffsetDateTime getAcquiredAt()
    {
        return acquiredAt;
    }

    public OffsetDateTime getExpiresAt()
    {
        return expiresAt;
    }


    /* Setters */

    public void setRecipeId(Integer recipeId)
    {
        this.recipeId = recipeId;
    }

    public void setLockedByUser(User lockedBy)
    {
        this.lockedBy = lockedBy;
    }

    public void setExpiresAt(OffsetDateTime expiresAt)
    {
        this.expiresAt = expiresAt;
    }
}
