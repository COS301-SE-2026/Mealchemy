package com.mealchemy.vault.service;

/* Import libraries */
import org.springframework.stereotype.Service;
import java.util.stream.Collectors;
import java.util.*;
import org.springframework.web.server.*;
import org.springframework.http.*;
import java.util.stream.Stream;

/* Import classes */
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.shared.enums.VaultType;

@Service
public class VaultService
{   
    private final VaultRepository vaultRepository;

    private final VaultMemberRepository vaultMemberRepository;

    private final UserRepository userRepository;

    public VaultService(VaultRepository vaultRepository, VaultMemberRepository vaultMemberRepository, UserRepository userRepository)
    {
        this.vaultRepository = vaultRepository;
        this.vaultMemberRepository = vaultMemberRepository;
        this.userRepository = userRepository;
    }

    // Get all vaults that belong to ownerId
    public List<VaultResponse> getVaultsByOwnerId(Integer ownerId)
    {
        return vaultRepository.findByOwnerId(ownerId).stream().map(VaultResponse::from).collect(Collectors.toList());
    }

    // Get a single vault using id
    public VaultResponse getVault(int id, Integer userId)
    {
        Vault vaultForReturn = vaultRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        boolean isOwner = vaultForReturn.getOwnerId().equals(userId);
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(id, userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a vault member/owner can view it.");
        }

        return VaultResponse.from(vaultForReturn);
    }

    // Get all vaults available to the user
    public List<VaultResponse> getAccessibleVaults(Integer userId)
    {
        List<Vault> owned = vaultRepository.findByOwnerId(userId); 

        List<Vault> memberVaults = vaultMemberRepository.findByUser_UserId(userId).stream().map(VaultMember::getVault).toList();

        return Stream.concat(owned.stream(), memberVaults.stream()).collect(Collectors.toMap(Vault::getVaultId, v -> v, (a, b) -> a)).values().stream().map(VaultResponse::from).collect(Collectors.toList());    
    }

    // Post to create a new vault
    public VaultResponse createVault(VaultRequest request, Integer userId)
    {
        User userToCheck = userRepository.findById(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));
        
        if(request.vaultType().equals(VaultType.PRIVATE))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Users only get one private vault.");
        }

        Vault vaultForReturn = mapRequestToEntity(request, userId);
        return VaultResponse.from(vaultRepository.save(vaultForReturn));
    }

    // Put to update an existing vault
    public VaultResponse updateVault(int id, VaultRequest request, Integer ownerId)
    {
        Vault vaultForReturn = vaultRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!vaultForReturn.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Vault can only be edited by the owner.");
        }

        if(request.vaultType().equals(VaultType.PRIVATE))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Users only get one private vault.");
        }

        vaultForReturn.setOwnerId(ownerId);
        vaultForReturn.setVaultType(request.vaultType());
        vaultForReturn.setName(request.name());

        return VaultResponse.from(vaultRepository.save(vaultForReturn));
    }

    // Delete a specific vault using id
    public void deleteVault(int id, Integer ownerId)
    {
        Vault vaultToCheck = vaultRepository.findById(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!vaultToCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Vaults can only be deleted be the owner.");
        }

        if (vaultToCheck.getVaultType().equals(VaultType.PRIVATE))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Private vaults can't be deleted.");
        }

        vaultRepository.deleteById(id);
    }

    /* Mapping functions */

    private Vault mapRequestToEntity(VaultRequest request, Integer ownerId)
    {
        Vault vault = new Vault();

        vault.setOwnerId(ownerId);
        vault.setVaultType(request.vaultType());
        vault.setName(request.name());

        return vault;
    }
}