package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public record VaultResponse(
    Integer vaultId,
    Integer ownerId,
    VaultType vaultType,
    String name,
    OffsetDateTime createdAt
) 
{
    public static VaultResponse from (Vault vault) 
    {
        return new VaultResponse(
            vault.getVaultId(),
            vault.getOwnerId(),
            vault.getVaultType(),
            vault.getName(),
            vault.getCreatedAt()
        );
    }
}