package com.mealchemy.vault.dto;

/* Import libraries */
import java.time.OffsetDateTime;

public record VaultFolderResponse(
    int folderId,
    int vaultId,
    String folderName,
    OffsetDateTime createdAt
)
{
    public static VaultFolderResponse from (VaultFolder vaultFolder) 
    {
        return new VaultFolderResponse(
            vaultFolder.getFolderId(),
            vaultFolder.getVaultId(),
            vaultFolder.getFolderId(),
            vaultFolder.getCreatedAt()
        );
    }
}