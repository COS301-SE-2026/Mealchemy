package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import java.util.Arrays;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public class VaultRequest
{
    /* Variable declarations */
    private int ownerId;
    private VaultType vaultType;
    private String name;

    /* Getters */

    public int getOwnerId()
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

    public void setOwnerId(int ownerIdIn)
    {
        ownerId = ownerIdIn;
    }

    public void setVaultType(VaultType vaultTypeIn)
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