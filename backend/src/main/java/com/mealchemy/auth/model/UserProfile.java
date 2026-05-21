// UserProfile model maps directly to user_profile table - one field per column

package com.mealchemy.auth.model;

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
    @Column(name = "preferred_unit", nullable = false, columnDefinition = "preferred_unit_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private PreferredUnit preferredUnit = PreferredUnit.METRIC;

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
    
    public void setAvatarUrl(String url) { 
        this.avatarUrl = url; 
    }
    
    public PreferredUnit getPreferredUnit() { 
        return preferredUnit; 
    }
    
    public void setPreferredUnit(PreferredUnit u) { 
        this.preferredUnit = u; 
    }
    
    public List<String> getEquipment() { 
        return equipment; 
    }
    
    public void setEquipment(List<String> e) { 
        this.equipment = e; 
    }
    
    public OffsetDateTime getUpdatedAt() { 
        return updatedAt; 
    }
    
    public void setUpdatedAt(OffsetDateTime t) { 
        this.updatedAt = t; 
    }
}