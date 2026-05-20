package com.mealchemy.vault.controller;

/* Import libraries */
import org.springframework.web.bind.annotation.*;

/* Import classes */
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.service.VaultFolderRecipeService;

@RestController
@RequestMapping("/folder/recipes")
public class VaultFolderRecipeController
{
    private final VaultFolderRecipeService vaultFolderRecipeService;

    public VaultFolderRecipeController(VaultFolderRecipeService vaultFolderRecipeService)
    {
        this.vaultFolderRecipeService = vaultFolderRecipeService;
    }

    /* Mapping Functions */

    // Get
    @GetMapping("/folderId")
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(@PathVariable int folderId)
    {
        return vaultFolderRecipeService.getRecipesByFolderId(folderId);
    }

    // Get
    @GetMapping("/recipeId")
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(@PathVariable int recipeId)
    {
        return vaultFolderRecipeService.getFoldersByRecipeId(recipeId);
    }

    // Get
    @GetMapping("/{id}")
    public VaultFolderRecipeResponse getFolderRecipeById(@PathVariabl int id)
    {
        return vaultFolderRecipeService.getFolderRecipeById(id);
    }

    // Post
    @PostMapping
    public VaultFolderRecipeResponse createVaultFolderRecipe(@RequestBody vaultFolderRecipeRequest request)
    {
        return vaultFolderRecipeService.createVaultFolderRecipe(request);
    }

    // Put
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