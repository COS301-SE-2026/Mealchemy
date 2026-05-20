package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;
import java.util.List;

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
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(@PathVariable int folderId)
    {
        return vaultFolderRecipeService.getRecipesByFolderId(folderId);
    }

    // Get
    @GetMapping("/folders/{recipeId}")
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(@PathVariable int recipeId)
    {
        return vaultFolderRecipeService.getFoldersByRecipeId(recipeId);
    }

    // Get
    @GetMapping("/{id}")
    public VaultFolderRecipeResponse getFolderRecipeById(@PathVariable int id)
    {
        return vaultFolderRecipeService.getFolderRecipeById(id);
    }

    // Post
    @PostMapping
    public VaultFolderRecipeResponse createVaultFolderRecipe(@RequestBody VaultFolderRecipeRequest request)
    {
        return vaultFolderRecipeService.createVaultFolderRecipe(request);
    }

    // Put
    @PutMapping("/{id}")
    public VaultFolderRecipeResponse updateVaultFolderRecipe(@PathVariable int id, @RequestBody VaultFolderRecipeRequest request)
    {
        return vaultFolderRecipeService.updateVaultFolderRecipe(id, request);
    }

    // Delete
    @DeleteMapping("/{id}")
    public void deleteVaultFolderRecipe(@PathVariable int id)
    {
        vaultFolderRecipeService.deleteVaultFolderRecipe(id);
    }
}