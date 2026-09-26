package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;
import org.springframework.web.server.*;
import org.springframework.http.*;
import org.springframework.transaction.annotation.Transactional;

/* Import classes */
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;

import com.mealchemy.vault.event.NotificationEvent;

import com.mealchemy.shared.enums.VaultMemberRole;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.NotificationType;


@Service
public class VaultFolderService {
    private final VaultFolderRepository vaultFolderRepository;
    
    private final VaultMemberRepository vaultMemberRepository;
    
    private final VaultRepository vaultRepository;

    private final NotificationService notificationService; 

    public VaultFolderService(VaultFolderRepository vaultFolderRepository, VaultMemberRepository vaultMemberRepository, VaultRepository vaultRepository, NotificationService notificationService)
    {
        this.vaultFolderRepository = vaultFolderRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.vaultRepository = vaultRepository;
        this.notificationService = notificationService;
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

        VaultFolder vaultFolderForReturn = vaultFolderRepository.findByVault_VaultIdAndFolderName(vaultId, name)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

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
        
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findByVault_VaultIdAndFolderId(vaultId, id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));
        return VaultFolderResponse.from(vaultFolderForReturn);
    }

    // Post to create a new vault folder
    @Transactional
    public VaultFolderResponse createVaultFolder(VaultFolderRequest request, Integer userId)
    {
        Vault vaultForCheck = vaultRepository.findById(request.vaultId()).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
        
        isOwnerOrEditor(vaultForCheck, userId);

        VaultFolder saved = vaultFolderRepository.save(mapRequestToEntity(request, vaultForCheck));

        // Notification
        String folderMessage = notificationService.getDisplayName(userId) + " created the folder " + saved.getFolderName() + " in vault " + vaultForCheck.getName();

        notificationService.publish(new NotificationEvent(
            notificationService.getVaultParticipantIds(vaultForCheck.getVaultId(), userId), // who receives it
            userId, // actor
            NotificationType.FOLDER_CREATED,
            folderMessage,
            vaultForCheck.getVaultId(),
            null, // not a recipe
            null
        ));

        return VaultFolderResponse.from(saved);
    }

    // Put to update an existing folder
    public VaultFolderResponse updateVaultFolder(int id, VaultFolderRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(request.vaultId()).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
        
        isOwnerOrEditor(vaultForCheck, ownerId);

        VaultFolder vaultFolderForReturn = vaultFolderRepository.findByVault_VaultIdAndFolderId(request.vaultId(), id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        vaultFolderForReturn.setFolderName(request.folderName());

        return VaultFolderResponse.from(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Delete a specific folder using id
    @Transactional
    public void deleteVaultFolder(int id, Integer vaultId, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));
        
        isOwnerOrEditor(vaultForCheck, ownerId);


        // Notification 
        VaultFolder folder = vaultFolderRepository.findByVault_VaultIdAndFolderId(vaultId, id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Folder not found."));

        String folderName = folder.getFolderName();

        vaultFolderRepository.deleteById(id);

        String deleteMessage = notificationService.getDisplayName(ownerId) + " deleted the folder " + folderName + " from " + vaultForCheck.getName();

        notificationService.publish(new NotificationEvent(
            notificationService.getVaultParticipantIds(vaultId, ownerId), // who receives it
            ownerId, // actor
            NotificationType.FOLDER_DELETED,
            deleteMessage,
            vaultId,
            null, // not a recipe
            null
        ));

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
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found.");
        }
    }

    private void isOwnerOrEditor(Vault vault, Integer userId) 
    {
        boolean isOwner = vault.getOwnerId().equals(userId);

        if (isOwner)
        {
            return;
        }

        // owner returns above because owner doesn't have a role in vaultMember
        VaultMember member = vaultMemberRepository.findByVault_VaultIdAndUser_UserId(vault.getVaultId(), userId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner/editor can modify folders."));
        
        boolean isEditor = member.getRole().equals(VaultMemberRole.EDITOR);

        if (!isEditor)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault owner/editor can modify the folders.");
        }
    }
}
