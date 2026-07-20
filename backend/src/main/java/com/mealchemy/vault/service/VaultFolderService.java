package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.List;

/* Import classes */
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;

@Service
public class VaultFolderService {
    private final VaultFolderRepository vaultFolderRepository;
    
    private final UserRepository userRepository;
    
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
        Vault vaultForCheck = vaultRepository.findByVaultId(userId).orElseThrow(() -> new RuntimeException("Vault not found."));

        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vaultId, userId).orElseThrow(() -> new RuntimeException("Vault member not found."));

        boolean isOwner = vaultForCheck.getOwnerId().equals(userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only vault a member/owner can view the folders.");
        }

        List<VaultFolderResponse> vaultFoldersForReturn = vaultFolderRepository.findByVault_VaultId(vaultId).stream().map(VaultFolderResponse::from).collect(Collectors.toList());

        return vaultFoldersForReturn;
    }

    // Get a single folder by name
    public VaultFolderResponse getVaultFolderByName(String name, Integer vaultId, Integer userId)
    {
        Vault vaultForCheck = vaultRepository.findByVaultId(userId).orElseThrow(() -> new RuntimeException("Vault not found."));

        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vaultId, userId).orElseThrow(() -> new RuntimeException("Vault member not found."));

        boolean isOwner = vaultForCheck.getOwnerId().equals(userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only vault a member/owner can view the folders.");
        }

        VaultFolder vaultFolderForReturn = vaultFolderRepository.findByFolderName(name).orElseThrow(() -> new RuntimeException("Folder not found."));
        
        return VaultFolderResponse.from(vaultFolderForReturn);
    }

    // Get a single folder by id
    public VaultFolderResponse getVaultFolderById(int id)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(id).orElseThrow(() -> new RuntimeException("Folder not found."));
        return VaultFolderResponse.from(vaultFolderForReturn);
    }

    // Post to create a new vault folder
    public VaultFolderResponse createVaultFolder(VaultFolderRequest request)
    {
        VaultFolder vaultFolderForReturn = mapRequestToEntity(request);
        return VaultFolderResponse.from(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Put to update an existing folder
    public VaultFolderResponse updateVaultFolder(int id, VaultFolderRequest request)
    {
        VaultFolder vaultFolderForReturn = vaultFolderRepository.findById(id).orElseThrow(() -> new RuntimeException("Folder not found."));
        
        vaultFolderForReturn.setVaultId(request.getVaultId());
        vaultFolderForReturn.setFolderName(request.getFolderName());

        return VaultFolderResponse.from(vaultFolderRepository.save(vaultFolderForReturn));
    }

    // Delete a specific folder using id
    public void deleteVaultFolder(int id)
    {
        vaultFolderRepository.deleteById(id);
    }

    /* Mapping functions */

    private VaultFolder mapRequestToEntity(VaultFolderRequest request)
    {
        VaultFolder vaultFolder = new VaultFolder();

        vaultFolder.setVaultId(request.getVaultId());
        vaultFolder.setFolderName(request.getFolderName());

        return vaultFolder;
    }

}
