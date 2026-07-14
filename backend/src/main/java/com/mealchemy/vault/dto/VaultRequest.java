package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import jakarta.validation.constraints.*;

/* Import classes */

import com.mealchemy.shared.enums.VaultType;

public record VaultRequest(
    @NotBlank VaultType vaultType,
    @NotNull String name
)
{
}