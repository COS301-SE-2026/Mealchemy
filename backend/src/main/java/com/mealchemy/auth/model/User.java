// User model maps directly to user table - one field per column

package com.mealchemy.auth.model;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @Column(name = "user_id")
    private String userId; //UUID stored as string

    @Column(nullable = false, unique = true) //email field can't be null and must be unique
    private String email;

    @Column(name = "hashed_password", nullable = false)
    private String hashedPassword;  //don't store raw text

    // Getters and setters
    public String getUserId() {
        return userId;
    }

    public void setUserId(String id) {
        this.userId = id; 
    }

    public String getEmail() {
        return email; 
    }

    public void setEmail(String email) {
        this.email = email; 
    }

    public String getHashedPassword() {
        return hashedPassword;
    }

    public void setHashedPassword(String p) {
        this.hashedPassword = p;
    }
}
