package com.mealchemy.vault.dto;

/* Import libraries */
import java.time.OffsetDateTime;

public class VaultFolderResponse {
    
    /* Variable declarations */

    private int folderId;
    private int vaultId;
    private String folderName;
    private OffsetDateTime createdAt;

    /* Getters */

    public int getFolderId()
    {
        return folderId;
    }

    public int getVaultId()
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

    public void setFolderId(int folderIdIn)
    {
        folderId = folderIdIn;
    }

    public void setVaultId(int vaultIdIn)
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
