package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.List;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.service.VaultService;

@RestController
@RequestMapping("/vaults")
public class VaultController
{
    private final VaultService vaultService;

    public VaultController(VaultService vaultService)
    {
        this.vaultService = vaultService;
    }

    /* Mapping Functions */

    // Get
    @GetMapping("/owner/vaults")
    public List<VaultResponse> getVaultsByOwnerId(@AuthenticationPrincipal String ownerId)
    {
        int ownerIdInt = Integer.parseInt(ownerId); 
        return vaultService.getVaultsByOwnerId(ownerIdInt);
    }

    // Get
    @GetMapping("/{id}")
    public VaultResponse getVault(@PathVariable int id, @AuthenticationPrincipal String userId)
    {
        return vaultService.getVault(id, Integer.parseInt(userId));
    }

    // Post
    @PostMapping
    public VaultResponse createVault(@Valid @RequestBody VaultRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultService.createVault(request, Integer.parseInt(ownerId));
    }

    // Put
    @PutMapping("/{id}")
    public VaultResponse updateVault(@PathVariable int id, @Valid @RequestBody VaultRequest request, @AuthenticationPrincipal String ownerId)
    {
        return vaultService.updateVault(id, request, Integer.parseInt(ownerId));
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteVault(@PathVariable int id, @AuthenticationPrincipal String ownerId)
    {
        vaultService.deleteVault(id, Integer.parseInt(ownerId));
    }
}