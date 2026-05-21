package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import java.util.Arrays;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public class VaultRequest
{
    /* Variable declarations */
    private Integer ownerId;
    private VaultType vaultType;
    private String name;

    /* Getters */

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

    /* Setters */

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
}