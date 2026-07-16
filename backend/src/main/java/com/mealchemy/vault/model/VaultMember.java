package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.util.*;
import java.time.OffsetDateTime;
import org.hibernate.annotations.*;
import org.hibernate.type.SqlType;

/* Import classes */

import com.mealchemy.auth.model.User;

@Entity
@Table(name = "vault_members")
public class VaultMember {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @ManyToOne
    @JoinColumn(name = "vault_id", nullable = false)
    private Vault vault;
    
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @CreationTimestamp
    @Column(name = "joined_at", nullable = false)
    private OffsetDateTime joinedAt;

    /* Getters */

    /* Setters */
}
