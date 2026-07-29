package com.mealchemy.vault.dto;

/* Import libraries */
import java.time.OffsetDateTime;

/* Import classes */
import com.mealchemy.vault.model.VaultFolder;

public record VaultFolderResponse(
    Integer folderId,
    Integer vaultId,
    String folderName,
    OffsetDateTime createdAt
)
{
    public static VaultFolderResponse from (VaultFolder vaultFolder) 
    {
        return new VaultFolderResponse(
            vaultFolder.getFolderId(),
            vaultFolder.getVault().getVaultId(),
            vaultFolder.getFolderName(),
            vaultFolder.getCreatedAt()
        );
    }
}