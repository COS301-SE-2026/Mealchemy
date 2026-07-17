// UserPreferences model maps directly to user_preferences table - one field per column

package com.mealchemy.preference.model;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;
import java.util.List;

@Entity
@Table(name = "user_preferences")
public class UserPreferences {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "preference_id")
    private Integer preferenceId;

    @Column(name = "user_id", nullable = false, unique = true)
    private Integer userId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "dietary_restrictions", columnDefinition = "jsonb")
    private List<String> dietaryRestrictions = List.of();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "allergies", columnDefinition = "jsonb")
    private List<String> allergies = List.of();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "disliked_ingredients", columnDefinition = "jsonb")
    private List<String> dislikedIngredients = List.of();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "flavour_profile", columnDefinition = "jsonb")
    private List<String> flavourProfile = List.of();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "nutritional_goals", columnDefinition = "jsonb")
    private List<String> nutritionalGoals = List.of();

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt = OffsetDateTime.now();

    // Getters and setters
    public Integer getUserId() { 
        return userId; 
    }

    public void setUserId(Integer id) { 
        this.userId = id; 
    }

    public List<String> getDietaryRestrictions() { 
        return dietaryRestrictions; 
    }
    
    public void setDietaryRestrictions(List<String> dietRestrictions) { 
        this.dietaryRestrictions = dietRestrictions; 
    }

    public List<String> getAllergies() { 
        return allergies; 
    }
    
    public void setAllergies(List<String> allergiesList) { 
        this.allergies = allergiesList; 
    }
    
    public List<String> getDislikedIngredients() { 
        return dislikedIngredients; 
    }
    
    public void setDislikedIngredients(List<String> dislikedIngredList) { 
        this.dislikedIngredients = dislikedIngredList;
    }
    
    public List<String> getFlavourProfile() { 
        return flavourProfile; 
    }
    
    public void setFlavourProfile(List<String> flavourProfileList) { 
        this.flavourProfile = flavourProfileList; 
    }

    public List<String> getNutritionalGoals() { 
        return nutritionalGoals; 
    }
    
    public void setNutritionalGoals(List<String> nutritionalGoalsList) { 
        this.nutritionalGoals = nutritionalGoalsList; 
    }
    
    public OffsetDateTime getUpdatedAt() { 
        return updatedAt; 
    }
    
    public void setUpdatedAt(OffsetDateTime t) { 
        this.updatedAt = t; 
    }
}