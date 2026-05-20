package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import java.util.Arrays;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public class VaultResponse
{
    /* Variable declarations */

    private int vaultId;
    private Integer ownerId;
    private VaultType vaultType;
    private String name;
    private OffsetDateTime createdAt;

    /* Getters */

    public int getVaultId()
    {
        return vaultId;
    }

    public Integer getOwnerId()
    {
        return ownerId;
    }

    public VaultType getVaultType()
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

    public void setVaultId(int vaultIdIn)
    {
        vaultId = vaultIdIn;
    }

    public void setOwnerId(Integer ownerIdIn)
    {
        ownerId = ownerIdIn;
    }

    public void setVaultType(VaultType vaultTypeIn)
    {
        vaultType = vaultTypeIn;
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