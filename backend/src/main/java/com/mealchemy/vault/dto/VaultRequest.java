package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import java.util.Arrays;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public class VaultRequest
{
    /* Variable declarations */
    private Long ownerId;
    private VaultType vaultType;
    private String name;

    /* Getters */

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

    /* Setters */

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
}