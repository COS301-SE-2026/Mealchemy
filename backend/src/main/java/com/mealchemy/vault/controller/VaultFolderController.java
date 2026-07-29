package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

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
    @GetMapping("/vault/private")
    public List<VaultFolderResponse> getPrivateVaultFolders(@AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getPrivateVaultFolders(Integer.parseInt(userId));
    }

    // Get
    @GetMapping("/vault/{vaultId}")
    public List<VaultFolderResponse> getVaultFolderByVaultId(@PathVariable int vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getVaultFolderByVaultId(vaultId, Integer.parseInt(userId));
    }

    // Get
    @GetMapping("/{vaultId}/folder/name/{name}")
    public VaultFolderResponse getVaultFolderByName(@PathVariable String name, @PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getVaultFolderByName(name, vaultId, Integer.parseInt(userId));
    }

    // Get
    @GetMapping("/{vaultId}/folder/{id}")
    public VaultFolderResponse getVaultFolderById(@PathVariable int id, @PathVariable Integer vaultId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderService.getVaultFolderById(id, vaultId, Integer.parseInt(userId));
    }

    // Post
    @PostMapping
    public VaultFolderResponse createVaultFolder(@Valid @RequestBody VaultFolderRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultFolderService.createVaultFolder(request, Integer.parseInt(ownerId));
    }

    // Put
    @PutMapping("/{id}")
    public VaultFolderResponse updateVaultFolder(@PathVariable int id, @Valid @RequestBody VaultFolderRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultFolderService.updateVaultFolder(id, request, Integer.parseInt(ownerId));
    }

    // Delete
    @DeleteMapping("/vault/{vaultId}/folder/{id}")
    public void deleteVaultFolder(@PathVariable int id, @PathVariable Integer vaultId, @AuthenticationPrincipal String ownerId)
    {
        vaultFolderService.deleteVaultFolder(id, vaultId, Integer.parseInt(ownerId));
    }
}