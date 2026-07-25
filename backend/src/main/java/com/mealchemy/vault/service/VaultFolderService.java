package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;

import com.mealchemy.shared.enums.VaultType;

@Service
public class VaultFolderService {
    private final VaultFolderRepository vaultFolderRepository;
    
    private final VaultMemberRepository vaultMemberRepository;
    
    private final VaultRepository vaultRepository;

    public VaultFolderService(VaultFolderRepository vaultFolderRepository, VaultMemberRepository vaultMemberRepository, VaultRepository vaultRepository)
    {
        this.vaultFolderRepository = vaultFolderRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.vaultRepository = vaultRepository;
    }

    // Get all folders relating to one vault
    public List<VaultFolderResponse> getVaultFolderByVaultId(Integer vaultId, Integer userId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        isOwnerOrMember(vaultForCheck, userId);

        List<VaultFolderResponse> vaultFoldersForReturn = vaultFolderRepository.findByVault_VaultId(vaultId).stream().map(VaultFolderResponse::from).collect(Collectors.toList());

        return vaultFoldersForReturn;
    }

    // Get a single folder by name
    public VaultFolderResponse getVaultFolderByName(String name, Integer vaultId, Integer userId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        isOwnerOrMember(vaultForCheck, userId);

        VaultFolder vaultFolderForReturn = vaultFolderRepository.findByFolderName(name).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        return VaultFolderResponse.from(vaultFolderForReturn);
    }

    // Get private vault folders
    public List<VaultFolderResponse> getPrivateVaultFolders(Integer userId)
    {
        Vault privateVault = vaultRepository.findByOwnerIdAndVaultType(userId, VaultType.PRIVATE).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Private vault not found."));

        return vaultFolderRepository.findByVault_VaultId(privateVault.getVaultId()).stream().map(VaultFolderResponse::from).collect(Collectors.toList());
    }

    // Get a single folder by id
    public VaultFolderResponse getVaultFolderById(int id, Integer vaultId, Integer userId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        isOwnerOrMember(vaultForCheck, userId);
        
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));
        return VaultFolderResponse.from(vaultFolderForReturn);
    }

    // Post to create a new vault folder
    public VaultFolderResponse createVaultFolder(VaultFolderRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(request.vaultId()).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
        
        isOwner(vaultForCheck, ownerId);

        VaultFolder vaultFolderForReturn = mapRequestToEntity(request, vaultForCheck);
        return VaultFolderResponse.from(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Put to update an existing folder
    public VaultFolderResponse updateVaultFolder(int id, VaultFolderRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(request.vaultId()).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
        
        isOwner(vaultForCheck, ownerId);

        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));
        
        vaultFolderForReturn.setVault(vaultForCheck);
        vaultFolderForReturn.setFolderName(request.folderName());

        return VaultFolderResponse.from(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Delete a specific folder using id
    public void deleteVaultFolder(int id, Integer vaultId, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
        
        isOwner(vaultForCheck, ownerId);

        vaultFolderRepository.deleteById(id);
    }

    /* Mapping functions */

    private VaultFolder mapRequestToEntity(VaultFolderRequest request, Vault vault)
    {
        VaultFolder vaultFolder = new VaultFolder();

        vaultFolder.setVault(vault);
        vaultFolder.setFolderName(request.folderName());

        return vaultFolder;
    }

    /* Helpers */
    private void isOwnerOrMember(Vault vault, Integer userId)
    {
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId);

        boolean isOwner = vault.getOwnerId().equals(userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault member/owner can view the folders.");
        }
    }

    private void isOwner(Vault vault, Integer ownerId)
    {
        if (!vault.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner can modify folders.");
        }
    }
}
