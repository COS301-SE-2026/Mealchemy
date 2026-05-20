package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;

@Service
public class VaultFolderRecipeService {
    private final VaultFolderRecipeRepository vaultFolderRecipeRepository;

    public VaultFolderRecipeService(VaultFolderRecipeRepository vaultFolderRecipeRepository)
    {
        this.vaultFolderRecipeRepository = vaultFolderRecipeRepository;
    }


    /* Mapping functions */

    private VaultFolderRecipeResponse mapToResponseDto(VaultFolderRecipe vaultFolderRecipeIn)
    {
        VaultFolderRecipeResponse response = new VaultFolderRecipeResponse();

        response.setId(vaultFolderRecipeIn.getId())
        response.setFolderId(vaultFolderRecipeIn.getFolderId);
        response.setRecipeId(vaultFolderRecipeIn.getRecipeId());
        response.setAddedAt(vaultFolderRecipeIn.getAddedAt());

        return response;
    }
}
