package com.mealchemy.swipes.model;

/* Import classes */
import com.mealchemy.shared.enums.SwipeAction;
import com.mealchemy.engine.dto.SignalScoresResponse;

/* Import libraries */
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "discovery_swipes")
public class Swipe {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "swipe_id")
    private Integer swipeId;

    @Column(name = "user_id")
    private Integer userId;

    @Column(name = "recipe_id")
    private Integer recipeId;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "action")
    private SwipeAction action;

    @CreationTimestamp
    @Column(name = "swiped_at")
    private OffsetDateTime swipedAt;
    
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "weights_snapshot", columnDefinition = "jsonb")
    private SignalScoresResponse weightsSnapshot;

    @Column(name = "flushed", nullable = false)
    private Boolean flushed = false;

    @Column(name = "cuisine_value")
    private String cuisineValue;

    /* Getters */
    public Integer getSwipeId()
    {
        return swipeId;
    }

    public Integer getUserId()
    {
        return userId;
    }

    public Integer getRecipeId()
    {
        return recipeId;
    }

    public SwipeAction getAction()
    {
        return action;
    }

    public OffsetDateTime getSwipedAt()
    {
        return swipedAt;
    }

    public SignalScoresResponse getWeightsSnapshot()
    {
        return weightsSnapshot;
    }

    public Boolean getFlushed()
    {
        return flushed; 
    }

    public String getCuisineValue()
    {
        return cuisineValue;
    }

    /* Setters */

    public void setUserId(Integer userIdIn)
    {
        this.userId = userIdIn;
    }

    public void setRecipeId(Integer recipeIdIn)
    {
        this.recipeId = recipeIdIn;
    }

    public void setAction(SwipeAction actionIn)
    {
        this.action = actionIn;
    }

    public void setWeightsSnapshot(SignalScoresResponse weightsSnapshotIn)
    {
        this.weightsSnapshot = weightsSnapshotIn;
    }

    public void setFlushed(Boolean flushedIn)
    { 
        this.flushed = flushedIn; 
    }

    public void setCuisineValue(String cuisineValueIn)
    {
        this.cuisineValue = cuisineValueIn;
    }
}
