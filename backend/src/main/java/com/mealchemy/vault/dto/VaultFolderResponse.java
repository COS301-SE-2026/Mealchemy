package com.mealchemy.vault.dto;

/* Import libraries */
import java.time.OffsetDateTime;

public class VaultFolderResponse {
    
    /* Variable declarations */

    private Long folderId;
    private Long vaultId;
    private String folderName;
    private OffsetDateTime createdAt;

    /* Getters */

    public Long getFolderId()
    {
        return folderId;
    }

    public Long getVaultId()
    {
        return vaultId;
    }

    public String getFolderName()
    {
        return folderName;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }

    /* Setters */

    public void setFolderId(Long folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setVaultId(Long vaultIdIn)
    {
        vaultId = vaultIdIn;
    }

    public void setFolderName(String folderNameIn)
    {
        folderName = folderNameIn;
    }

    public void setCreatedAt(OffsetDatetime createdAtIn)
    {
        createdAt = createdAtIn;
    }
}
