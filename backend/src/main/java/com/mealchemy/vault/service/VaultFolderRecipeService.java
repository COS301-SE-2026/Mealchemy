package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;

@Service
public class VaultFolderRecipeService {
    private final VaultFolderRecipeRepository vaultFolderRecipeRepository;

    public VaultFolderRecipeService(VaultFolderRecipeRepository vaultFolderRecipeRepository)
    {
        this.vaultFolderRecipeRepository = vaultFolderRecipeRepository;
    }

    // Get all recipes using folderId
    public List<VaultFolderRecipeResponse> getRecipesByFolderId(int folderId)
    {
        return vaultFolderRecipeRepository.findByFolderId(folderId).stream().map(this::mapToResponseDto).collect(Collectors.toList());
    }

    // Get all folders containing a recipe
    public List<VaultFolderRecipeResponse> getFoldersByRecipeId(int recipeId)
    {
        return vaultFolderRecipeRepository.findByRecipeId(recipeId).stream().map(this::mapToResponseDto).collect(Collectors.toList());
    }

    // Get a single record by id
    public VaultFolderRecipeResponse getFolderRecipeById(int id)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new RuntimeException("No record found"));
        return mapToResponseDto(vaultFolderRecipeForReturn);
    }

    // Post create a new record
    public VaultFolderRecipeResponse createVaultFolderRecipe(VaultFolderRecipeRequest request)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = mapRequestToEntity(request);
        return mapToResponseDto(vaultFolderRecipeRepository.save(vaultFolderRecipeForReturn));
    }

    // Put to update a record
    public VaultFolderRecipeResponse updateVaultFolderRecipe(int id, VaultFolderRecipeRequest request)
    {
        VaultFolderRecipe vaultFolderRecipeForReturn = vaultFolderRecipeRepository.findById(id).orElseThrow(() -> new RuntimeException("No record found"));

        vaultFolderRecipeForReturn.setFolderId(request.getFolderId());
        vaultFolderRecipeForReturn.setRecipeId(request.getRecipeId());

        return mapToResponseDto(vaultFolderRecipeRepository.save(vaultFolderRecipeForReturn));
    }

    // Delete a specific record using id
    public void deleteVaultFolderRecipe(int id)
    {
        vaultFolderRecipeRepository.deleteById(id);
    }

    /* Mapping functions */

    private VaultFolderRecipeResponse mapToResponseDto(VaultFolderRecipe vaultFolderRecipeIn)
    {
        VaultFolderRecipeResponse response = new VaultFolderRecipeResponse();

        response.setId(vaultFolderRecipeIn.getId());
        response.setFolderId(vaultFolderRecipeIn.getFolderId());
        response.setRecipeId(vaultFolderRecipeIn.getRecipeId());
        response.setAddedAt(vaultFolderRecipeIn.getAddedAt());

        return response;
    }

    private VaultFolderRecipe mapRequestToEntity(VaultFolderRecipeRequest request)
    {
        VaultFolderRecipe vaultFolderRecipe = new VaultFolderRecipe();

        vaultFolderRecipe.setFolderId(request.getFolderId());
        vaultFolderRecipe.setRecipeId(request.getRecipeId());

        return vaultFolderRecipe;
    }
}
