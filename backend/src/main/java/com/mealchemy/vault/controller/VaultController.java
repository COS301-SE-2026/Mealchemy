package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;

/* Import classes */
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.sto.VaultRequest;
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
    @GetMapping("/owner/{ownerId}")
    public List<VaultResponse> getVaultsByOwnerId(@PathVariable Long ownerId)
    {
        return vaultService.getVaultsByOwnerId(ownerId);
    }

    // Get
    @GetMapping("/{id}")
    public VaultResponse getVault(@PathVariable Long id)
    {
        return vaultService.getVault(id);
    }

    // Post
    @PostMapping
    public VaultResponse createVault(@RequestBody VaultRequest request)
    {
        return vaultService.createVault(request);
    }

    // Put
    @PutMapping("/{id}")
    public VaultResponse updateVault(@PathVariable Long id, @RequestBody VaultRequest request)
    {
        return vaultService.updateVault(id, request);
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteVault(@PathVariable Long id)
    {
        vaultService.deleteVault(id);
    }
}