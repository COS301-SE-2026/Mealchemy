// UserProfile model maps directly to user_profile table - one field per column

package com.mealchemy.profile.model;

import com.mealchemy.shared.enums.PreferredUnit;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import java.time.OffsetDateTime;
import java.util.List;

@Entity
@Table(name = "user_profile")
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "profile_id")
    private Integer profileId;

    @Column(name = "user_id", nullable = false, unique = true)
    private Integer userId;

    @Column(name = "display_name")
    private String displayName;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "preferred_unit", columnDefinition = "preferred_unit_enum") //METRIC / IMPERIAL
    private PreferredUnit preferredUnit;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "equipment", columnDefinition = "jsonb")
    private List<String> equipment = List.of();

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt = OffsetDateTime.now();

    // Getters and setters
    public Integer getProfileId() { 
        return profileId; 
    }


    public Integer getUserId() { 
        return userId; 
    }

    public void setUserId(Integer id) { 
        this.userId = id; 
    }

    public String getDisplayName() { 
        return displayName; 
    }

    public void setDisplayName(String name) {
        this.displayName = name;
    }
    
    public String getAvatarUrl() { 
        return avatarUrl; 
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public PreferredUnit getPreferredUnit() {
        return preferredUnit;
    }

    public void setPrefrRedUnit(PreferredUnit preferredUnit) {
        this.preferredUnit = preferredUnit;
    }

    public List<String> getEquipment() { 
        return equipment; 
    }
    
    public void setEquipment(List<String> equipment) { 
        this.equipment = equipment; 
    }
    
    public OffsetDateTime getUpdatedAt() { 
        return updatedAt; 
    }

    public void setUpdatedAt(OffsetDateTime time) { 
        this.updatedAt = time; 
    }
}