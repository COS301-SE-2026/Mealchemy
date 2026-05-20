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
    public List<VaultFolderResponse> getVaultFolderByVaultId(@PathVariable int vaultId)
    {
        return vaultFolderService.getVaultFolderByVaultId(vaultId);
    }

    // Get
    @GetMapping("/{name}")
    public VaultFolderResponse getVaultFolderByName(@PathVariable String name)
    {
        return vaultFolderService.getVaultFolderByName(name);
    }

    // Get
    @GetMapping("/{id}")
    public VaultFolderResponse getVaultFolderById(@PathVariable int id)
    {
        return vaultFolderService.getVaultFolderById(id);
    }

    // Post
    @PostMapping
    public VaultFolderResponse createVaultFolder(@RequestBody VaultFolderRequest request)
    {
        return vaultFolderService.createVaultFolder(response);
    }

    // Put
    @PutMapping("/{id}")
    public VaultFolderResponse updateVaultFolder(@PathVariable int id, @RequestBody VaultFolderRequest request)
    {
        return vaultFolderService.updateVaultFolder(id, request);
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteVaultFolder(@PathVariable int id)
    {
        vaultFolderService.deleteVaultFolder(id);
    }
}