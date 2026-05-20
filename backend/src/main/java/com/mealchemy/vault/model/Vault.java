// Vault model maps directly to vaults table - one field per column

package com.mealchemy.vault.model;

import com.mealchemy.shared.enums.VaultType;
import jakarta.persistence.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "vaults")
public class Vault {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vault_id")
    private Long vaultId;

    @Column(name = "owner_id") 
    private Long ownerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "vault_type", nullable = false)
    private VaultType vaultType = VaultType.PRIVATE;

    @Column(nullable = false)
    private String name = "My Vault";

    @Column(name = "created_at", nullable = false) //Postgres sets it
    private OffsetDateTime createdAt;

    // Getters and setters
    public Long getVaultId() { 
        return vaultId; 
    }

    public Long getOwnerId() { 
        return ownerId; 
    }

    public void setOwnerId(Long id) { 
        this.ownerId = id; 
    }

    public VaultType getVaultType() { 
        return vaultType; 
    }

    public void setVaultType(VaultType type) { 
        this.vaultType = type; 
    }

    public String getName() { 
        return name; 
    }

    public void setName(String name) { 
        this.name = name; 
    }

    public OffsetDateTime getCreatedAt() { 
        return createdAt; 
    }
}