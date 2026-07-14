package com.mealchemy.vault.dto;

/* Import libraries */

import jakarta.validation.constraints.*;

/* Import classes */

public record VaultFolderRequest(
    @NotNull Integer vaultId,
    @NotBlank String folderName
)
{
}