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
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.auth.repository.UserRepository;

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
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new RuntimeException("Vault not found."));

        boolean isOwner = vaultForCheck.getOwnerId().equals(userId);
        boolean isMember = vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(vaultId, userId);

        if (!isOwner && !isMember)
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only a member/owner of the vault can view its members.");
        }

        List<VaultMemberResponse> vaultMembersForReturn = vaultMemberRepository.findByVault_VaultId(vaultId).stream().map(VaultMemberResponse::from).collect(Collectors.toList());
       
        return vaultMembersForReturn;
    }

    // Post to add a vaultMember
    public VaultMemberResponse addVaultMember(Integer vaultId, VaultMemberRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new RuntimeException("Vault not found."));

        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the vault can add a new member.");
        }

        User userToAdd = userRepository.findByEmail(request.email()).orElseThrow(() -> new RuntimeException("User not found."));

        VaultMember vaultMemberToAdd = mapRequestToEntity(userToAdd, vaultForCheck);

        return VaultMemberResponse.from(vaultMemberRepository.save(vaultMemberToAdd));
    }

    // Delete to remove a vaultMember
    public void removeVaultMember(Integer vaultId, VaultMemberRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new RuntimeException("Vault not found."));

        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the owner of the vault can remove a member.");
        }

        User userToRemove = userRepository.findByEmail(request.email()).orElseThrow(() -> new RuntimeException("User not found."));

        VaultMember rowToRemove = vaultMemberRepository.findByVault_VaultIdAndUser_UserId(vaultId, userToRemove.getUserId()).orElseThrow(() -> new RuntimeException("VaultMember row not found."));

        vaultMemberRepository.delete(rowToRemove);
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
