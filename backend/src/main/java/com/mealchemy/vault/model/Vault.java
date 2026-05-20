package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.Arrays;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

@Entity
@Table(name = "vaults")
public class Vault
{

    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "vault_id")
    private int vaultId;
    
    @Column(name = "owner_id")
    private int ownerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "vault_type", nullable = false)
    private VaultType vaultType = VaultType.PRIVATE;

    @Column(nullable = false)
    private String name = "My Vault";

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    /* Getters */

    public int getVaultId()
    {
        return vaultId;
    }

    public int getOwnerId()
    {
        return ownerId;
    }

    public String getVaultType()
    {
        return vaultType;
    }

    public String getName()
    {
        return name;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }

    /* Setters */

    public void setOwnerId(int ownerIdIn)
    {
        ownerId = ownerIdIn;
    }

    public void setVaultType(String vaultTypeIn)
    {
        if(Arrays.stream(VaultType.values()).map(Enum::name).anyMatch(vaultTypeIn::equals))
        {
            vaultType = vaultTypeIn;
        }
    }

    public void setName(String nameIn)
    {
        name = nameIn;
    }
}