// FlaggedRecipe model maps directly to the flagged_recipes table 

package com.mealchemy.moderation.model;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;

@Entity 
@Table(name = "flagged_recipes")
public class FlaggedRecipe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "flagged_id")
    private Integer flaggedId;

    @Column(name = "recipe_id", nullable = false)
    private Integer recipeId;

    @Column(name = "flagged_by_user_id", nullable = false)
    private Integer userId;

    @Column(name = "reason", nullable = false)
    private String reason;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "status", nullable = false, columnDefinition = "flagged_status_enum")
    private FlagStatus status;

    @CreationTimestamp
    @Column(name = "flagged_at", nullable = false, updatable = false)
    private OffsetDateTime flaggedAt;


    // Getters
    public Integer getFlaggedId() {
        return flaggedId;
    }

    public Integer getRecipeId() {
        return recipeId;
    }

    public Integer getFlaggedByUserId() {
        return userId;
    }
    
    public String getReason() {
        return reason;
    }

    public FlagStatus getStatus() {
        return status; 
    }
    
    public OffsetDateTime getFlaggedAt() {
        return flaggedAt;
    }
    

    // Setters
    public void setRecipeId(Integer recipeId) {
        this.recipeId = recipeId;
    }

    public void setFlaggedByUserId(Integer userId) {
        this.userId = userId;
    }
    
    public void setReason(String reason) {
        this.reason = reason;
    }
    
    public void setStatus(FlagStatus status) {
        this.status = status;
    }
}
