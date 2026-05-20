package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;

/* Import classes */
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.service.VaultFolderService;

public class VaultFolderController
{
    private final VaultFolderService vaultFolderService;

    public VaultFolderController(VaultFolderService vaultFolderService)
    {
        this.vaultFolderService = vaultFolderService;
    }    
}