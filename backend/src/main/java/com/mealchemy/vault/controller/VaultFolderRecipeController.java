package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import java.util.*;
import jakarta.validation.Valid;

/* Import classes */
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.service.VaultFolderRecipeService;

@RestController
@RequestMapping("/recipefolders")
public class VaultFolderRecipeController
{
    private final VaultFolderRecipeService vaultFolderRecipeService;

    public VaultFolderRecipeController(VaultFolderRecipeService vaultFolderRecipeService)
    {
        this.vaultFolderRecipeService = vaultFolderRecipeService;
    }

    /* Mapping Functions */

    // Get
    @GetMapping("/recipes/{folderId}")
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(@PathVariable int folderId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.getRecipesByFolderId(folderId, Integer.parseInt(userId));
    }

    // Get
    @GetMapping("/folders/{recipeId}")
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(@PathVariable int recipeId, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.getFoldersByRecipeId(recipeId, Integer.parseInt(userId));
    }

    // Get
    @GetMapping("/{id}")
    public VaultFolderRecipeResponse getFolderRecipeById(@PathVariable int id, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.getFolderRecipeById(id, Integer.parseInt(userId));
    }

    // Post
    @PostMapping("/folder/{folderId}")
    public VaultFolderRecipeResponse createVaultFolderRecipe(@Valid @RequestBody VaultFolderRecipeRequest request, @AuthenticationPrincipal String userId, @PathVariable Integer folderId)
    {
        return vaultFolderRecipeService.createVaultFolderRecipe(request, Integer.parseInt(userId), folderId);
    }

    // Put
    @PutMapping("/{id}")
    public VaultFolderRecipeResponse updateVaultFolderRecipe(@PathVariable int id, @RequestBody VaultFolderRecipeMoveRequest request, @AuthenticationPrincipal String userId)
    {
        return vaultFolderRecipeService.updateVaultFolderRecipe(id, request, Integer.parseInt(userId));
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteVaultFolderRecipe(@PathVariable int id, @AuthenticationPrincipal String userId)
    {
        vaultFolderRecipeService.deleteVaultFolderRecipe(id, Integer.parseInt(userId));
    }
}