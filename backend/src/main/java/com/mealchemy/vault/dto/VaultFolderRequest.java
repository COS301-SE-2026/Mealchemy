package com.mealchemy.vault.dto;

public class VaultFolderRequest {
    
    /* Variable declarations */

    private Long vaultId;
    private String folderName;

    /* Getters */

    public Long getVaultId()
    {
        return vaultId;
    }

    public String getFolderName()
    {
        return folderName;
    }

    /* Setters */

    public void setVaultId(Long vaultIdIn)
    {
        vaultId = vaultIdIn;
    }

    public void setFolderName(String folderNameIn)
    {
        folderName = folderNameIn;
    }
}
