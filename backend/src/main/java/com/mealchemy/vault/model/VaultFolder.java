package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.vault.model.Vault;

@Entity
@Table(name = vault_folders)
public class VaultFolder {
    
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "folder_id")
    private Long folderId;

    @ManyToOne
    @JoinColumn(name = "vault_id", nullable = false)
    private Vault vault;

    @Column(name = "name", nullable = false, length = 100)
    private String folderName;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt = OffsetDateTime.now();

    /* Getters */

    public Long getFolderId()
    {
        return folderId;
    }
    
    public Vault getVault()
    {
        return vault;
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

    public void setVault(Vault vaultIn)
    {
        vault = vaultIn;
    }

    public void setFolderName(String folderNameIn)
    {
        folderName = folderNameIn;
    }
}
