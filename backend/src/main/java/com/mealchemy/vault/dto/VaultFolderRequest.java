package com.mealchemy.vault.dto;

public record VaultFolderRequest(
    @NotNull int vaultId,
    @NotBlank String folderName
)
{
}