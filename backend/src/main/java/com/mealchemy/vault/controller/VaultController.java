package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import java.util.List;

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
    @GetMapping("/owner/{ownerId}")
    public List<VaultResponse> getVaultsByOwnerId(@PathVariable int ownerId)
    {
        return vaultService.getVaultsByOwnerId(ownerId);
    }

    // Get
    @GetMapping("/{id}")
    public VaultResponse getVault(@PathVariable int id)
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
    public VaultResponse updateVault(@PathVariable int id, @RequestBody VaultRequest request)
    {
        return vaultService.updateVault(id, request);
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteVault(@PathVariable int id)
    {
        vaultService.deleteVault(id);
    }
}