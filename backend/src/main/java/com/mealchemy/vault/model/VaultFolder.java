package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;

/* Import classes */

@Entity
@Table(name = vault_folders)
public class VaultFolder {
    
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "folder_id")
    private int folderId;

    @Column(name = "vault_id", nullable = false)
    private int vaultId;

    @Column(name = "name", nullable = false, length = 100)
    private String folderName;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt = OffsetDateTime.now();

    /* Getters */

    public int getFolderId()
    {
        return folderId;
    }
    
    public Vault getVaultId()
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

    public void setVaultId(int vaultIdIn)
    {
        vaultId = vaultIdIn;
    }

    public void setFolderName(String folderNameIn)
    {
        folderName = folderNameIn;
    }
}
