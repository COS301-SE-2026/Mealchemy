package com.mealchemy.vault.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;
import org.springframework.web.server.*;
import org.springframework.http.*;

/* Import classes */

import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRoleRequest;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.shared.enums.VaultType;
import com.mealchemy.shared.enums.VaultMemberRole;

@Service
public class VaultMemberService {
    private final VaultMemberRepository vaultMemberRepository;

    private final UserRepository userRepository;

    private final VaultRepository vaultRepository;

    public VaultMemberService(VaultMemberRepository vaultMemberRepository, UserRepository userRepository, VaultRepository vaultRepository)
    {
        this.vaultMemberRepository = vaultMemberRepository;
        this.userRepository = userRepository;
        this.vaultRepository = vaultRepository;
    }

    // Get all vault members
    public List<VaultMemberResponse> getVaultMembersByVaultId(Integer vaultId, Integer userId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        boolean isOwner = vaultForCheck.getOwnerId().equals(userId);
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vaultId, userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a member/owner of the vault can view its members.");
        }

        List<VaultMemberResponse> vaultMembersForReturn = vaultMemberRepository.findByVault_VaultId(vaultId).stream().map(VaultMemberResponse::from).collect(Collectors.toList());
       
        // include owner is vault member list - therefor prepend owner
        User owner = userRepository.findById(vaultForCheck.getOwnerId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault owner not found."));

        vaultMembersForReturn.add(0, VaultMemberResponse.forOwner(vaultForCheck, owner));

        return vaultMembersForReturn;
    }

    // Post to add a vaultMember
    public VaultMemberResponse addVaultMember(Integer vaultId, VaultMemberRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the vault can add a new member.");
        }

        if (vaultForCheck.getVaultType().equals(VaultType.PRIVATE))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Members can't be added to a private vault.");
        }

        User userToAdd = userRepository.findByEmail(request.email()).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found."));

        VaultMember vaultMemberToAdd = mapRequestToEntity(userToAdd, vaultForCheck);

        return VaultMemberResponse.from(vaultMemberRepository.save(vaultMemberToAdd));
    }

    // Delete to remove a vaultMember
    public void removeVaultMember(Integer vaultId, Integer targetUserId, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the vault can remove a member.");
        }

        VaultMember rowToRemove = vaultMemberRepository.findByVault_VaultIdAndUser_UserId(vaultId, targetUserId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "VaultMember row not found."));

        vaultMemberRepository.delete(rowToRemove);
    }

    // Change shared vault member's role
    public VaultMemberResponse changeRole(Integer vaultId, Integer targetUserId, VaultMemberRoleRequest request, Integer ownerId)
    {
        // check vault exists
        Vault vaultForCheck = vaultRepository.findById(vaultId)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        // check owner
        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the vault can change a member's role.");
        }

        if (request.role() == VaultMemberRole.OWNER) 
        {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Only one owner per vault.");
        }

        VaultMember selectedMember = vaultMemberRepository.findByVault_VaultIdAndUser_UserId(vaultId, targetUserId)
                            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault member not found."));
        
        // owner is not in members table (implicit via vault ownerId)
        
        selectedMember.setRole(request.role());
        VaultMember saved = vaultMemberRepository.save(selectedMember);
        
        // TODO: Notification role changed

        return VaultMemberResponse.from(saved);
        
    }

    /* Mapping functions */

    public VaultMember mapRequestToEntity(User user, Vault vault)
    {        
        VaultMember member = new VaultMember();

        member.setVault(vault);
        member.setUser(user);

        return member;
    }
}
