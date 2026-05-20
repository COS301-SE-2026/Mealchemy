package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.repository.VaultFolderRepository;

@Service
public class VaultFolderService {
    private final VaultFolderRepository vaultFolderRepository;

    public VaultFolderService(VaultFolderRepository vaultFolderRepository)
    {
        this.vaultFolderRepository = vaultFolderRepository;
    }

    // Get all folders relating to one vault
    public List<VaultFolderResponse> getVaultFolderByVaultId(int vaultId)
    {
        return vaultFolderRepository.findByVaultId(vaultId).stream().map(this::mapToResponseDto).collect(Collectors.toList());
    }

    // Get a single folder by name
    public VaultFolderResponse getVaultFolderByName(String name)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findByFolderName(name).orElseThrow(() -> new RuntimeException("Folder not found."));
        return mapToResponseDto(vaultFolderForReturn);
    }

    // Get a single folder by id
    public VaultFolderResponse getVaultFolderById(int id)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(id).orElseThrow(() -> new RuntimeException("Folder not found."));
        return mapToResponseDto(vaultFolderForReturn);
    }

    // Post to create a new vault folder
    public VaultFolderResponse createVaultFolder(VaultFolderRequest request)
    {
        VaultFolder vaultFolderForReturn = mapRequestToEntity(request);
        return mapToResponseDto(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Put to update an existing folder
    public VaultFolderResponse updateVaultFolder(int id, VaultFolderRequest request)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(id).orElseThrow(() -> new RuntimeException("Folder not found."));
        
        vaultFolderForReturn.setVaultId(request.getVaultId());
        vaultFolderForReturn.setFolderName(request.getFolderName());

        return mapToResponseDto(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Delete a specific folder using id
    public void deleteVaultFolder(int id)
    {
        vaultFolderRepository.deleteById(id);
    }

    /* Mapping functions */

    private VaultFolderResponse mapToResponseDto(VaultFolder vaultFolderIn)
    {
        VaultFolderResponse response = new VaultFolderResponse();

        response.setFolderId(vaultFolderIn.getFolderId());
        response.setVaultId(vaultFolderIn.getVaultId());
        response.setFolderName(vaultFolderIn.getFolderName());
        response.setCreatedAt(vaultFolderIn.getCreatedAt());

        return response;
    }

    private VaultFolder mapRequestToEntity(VaultFolderRequest request)
    {
        VaultFolder vaultFolder = new VaultFolder();

        vaultFolder.setVaultId(request.getVaultId());
        vaultFolder.setFolderName(request.getFolderName());

        return vaultFolder;
    }

}
