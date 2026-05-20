package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import java.util.Arrays;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public class Vault
{
    /* Variable declarations */

    private Long vaultId;
    private Long ownerId;
    private VaultType vaultType;
    private String name;
    private OffsetDateTime createdAt;

    /* Getters */

    public Long getVaultId()
    {
        return vaultId;
    }

    public Long getOwnerId()
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

    public void setVaultId(Long vaultIdIn)
    {
        vaultId = vaultIdIn;
    }

    public void setOwnerId(Long ownerIdIn)
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

    public void setCreatedAt(OffsetDateTime createdAtIn)
    {
        createdAt = createdAtIn;
    }
}