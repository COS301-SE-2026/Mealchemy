// Vault model maps directly to vaults table - one field per column

package com.mealchemy.vault.model;

import com.mealchemy.shared.enums.VaultType;
import jakarta.persistence.*;
import java.time.OffsetDateTime;

import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "vaults")
public class Vault {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vault_id")
    private Integer vaultId;

    @Column(name = "owner_id") 
    private Integer ownerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "vault_type", nullable = false, columnDefinition = "vault_type_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    private VaultType vaultType = VaultType.PRIVATE;

    @Column(nullable = false)
    private String name = "My Vault";

    @Column(name = "created_at", nullable = false) //Postgres sets it
    private OffsetDateTime createdAt = OffsetDateTime.now();

    // Getters and setters
    public Integer getVaultId() { 
        return vaultId; 
    }

    public Integer getOwnerId() { 
        return ownerId; 
    }

    public void setOwnerId(Integer id) { 
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