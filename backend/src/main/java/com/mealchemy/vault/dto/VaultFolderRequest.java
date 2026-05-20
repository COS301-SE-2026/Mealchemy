package com.mealchemy.vault.dto;

public class VaultFolderRequest {
    
    /* Variable declarations */

    private int vaultId;
    private String folderName;

    /* Getters */

    public int getVaultId()
    {
        return vaultId;
    }

    public String getFolderName()
    {
        return folderName;
    }

    /* Setters */

    public void setVaultId(int vaultIdIn)
    {
        vaultId = vaultIdIn;
    }

    public void setFolderName(String folderNameIn)
    {
        folderName = folderNameIn;
    }
}
