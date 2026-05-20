package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;

/* Import classes */
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.service.VaultFolderService;

@RestController
@RequestMapping("/folders")
public class VaultFolderController
{
    private final VaultFolderService vaultFolderService;

    public VaultFolderController(VaultFolderService vaultFolderService)
    {
        this.vaultFolderService = vaultFolderService;
    }    

    /* Mapping Functions */

    // Get
    @GetMapping("/{vaultId}")
    public List<VaultFolderResponse> getVaultFolderByVaultId(@PathVariable Long vaultId)
    {
        return vaultFolderService.getVaultFolderByVaultId(vaultId);
    }


}