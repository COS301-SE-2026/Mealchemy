package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public record VaultRequest(
    @NotNull Integer ownerId,
    @NotBlank VaultType vaultType,
    @NotNull String name
)
{
}