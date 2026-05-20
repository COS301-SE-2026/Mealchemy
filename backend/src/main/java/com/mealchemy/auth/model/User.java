// User model maps directly to user table - one field per column

package com.mealchemy.auth.model;

import jakarta.persistence.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long userId;

    @Column(nullable = false, unique = true) //email field can't be null and must be unique
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;  //don't store raw text

    @Column(name = "role_id", nullable = false)
    private Long roleId;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt; //postgres sets it

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    // Getters and setters
    public Long getUserId() {
        return userId;
    }

    public String getEmail() {
        return email; 
    }

    public void setEmail(String email) {
        this.email = email; 
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String p) {
        this.passwordHash = p;
    }

    public Long getRoleId() {
        return roleId; 
    }
    
    public void setRoleId(Long roleId) {
        this.roleId = roleId;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getDeletedAt() {
        return deletedAt; 
    }

    public void setDeletedAt(OffsetDateTime t) {
        this.deletedAt = t;
    }
}
