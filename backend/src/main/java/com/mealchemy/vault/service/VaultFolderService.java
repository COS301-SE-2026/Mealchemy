package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;

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


    /* Mapping functions */

    private VaultFolderResponse mapToResponseDto(VaultFolder vaultFolderIn)
    {
        VaultFolderResponse response = new VaultFolderResponse();

        response.setFolderId(vaultFolderIn.getFolderId())
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
