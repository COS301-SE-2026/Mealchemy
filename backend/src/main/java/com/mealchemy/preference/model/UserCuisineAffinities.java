package com.mealchemy.preference.model;

/* Import classes */

/* Import libraries */

import jakarta.persistence.*;
import org.hibernate.annotations.UpdateTimestamp;
import java.time.OffsetDateTime;
import java.math.BigDecimal;

@Entity
@Table(name = "user_cuisine_affinities", uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "cuisine_value"}))
public class UserCuisineAffinities {
    
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "affinity_id")
    private Integer affinityId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "cuisine_value", nullable = false)
    private String cuisineValue;

    @Column(name = "affinity_score", precision = 4, scale = 3, nullable = false)
    private BigDecimal affinityScore;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    /* Getters */

    public Integer getAffinityId()
    {
        return affinityId;
    }

    public Integer getUserId()
    {
        return userId;
    }

    public String getCuisineValue()
    {
        return cuisineValue;
    }

    public BigDecimal getAffinityScore()
    {
        return affinityScore;
    }

    public OffsetDateTime getUpdatedAt()
    {
        return updatedAt;
    }

    /* Setters */

    public void setUserId(Integer userIdIn)
    {
        this.userId = userIdIn;
    }

    public void setCuisineValue(String cuisineValueIn)
    {
        this.cuisineValue = cuisineValueIn;
    }

    public void setAffinityScore(BigDecimal affinityScoreIn)
    {
        this.affinityScore = affinityScoreIn;
    }

}
