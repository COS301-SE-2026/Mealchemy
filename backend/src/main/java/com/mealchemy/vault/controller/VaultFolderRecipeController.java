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
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(@PathVariable Long folderId)
    {
        return vaultFolderRecipeService.getRecipesByFolderId(folderId);
    }

    // Get
    @GetMapping("/recipeId")
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(@PathVariable Long recipeId)
    {
        return vaultFolderRecipeService.getFoldersByRecipeId(recipeId);
    }
}