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
import com.mealchemy.shared.enums.VaultType;

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
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found.");
        }

        List<VaultMemberResponse> vaultMembersForReturn = vaultMemberRepository.findByVault_VaultId(vaultId).stream().map(VaultMemberResponse::from).collect(Collectors.toList());
       
        return vaultMembersForReturn;
    }

    // Post to add a vaultMember
    public VaultMemberResponse addVaultMember(Integer vaultId, VaultMemberRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found.");
        }

        if (vaultForCheck.getVaultType().equals(VaultType.PRIVATE))
        {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Members can't be added to a private vault.");
        }

        User userToAdd = userRepository.findByEmail(request.email()).orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to add member."));

        VaultMember vaultMemberToAdd = mapRequestToEntity(userToAdd, vaultForCheck);

        return VaultMemberResponse.from(vaultMemberRepository.save(vaultMemberToAdd));
    }

    // Delete to remove a vaultMember
    public void removeVaultMember(Integer vaultId, VaultMemberRequest request, Integer ownerId)
    {
        Vault vaultForCheck = vaultRepository.findById(vaultId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found."));

        if (!vaultForCheck.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Vault not found.");
        }

        User userToRemove = userRepository.findByEmail(request.email()).orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to remove member."));

        VaultMember rowToRemove = vaultMemberRepository.findByVault_VaultIdAndUser_UserId(vaultId, userToRemove.getUserId()).orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unable to remove member."));

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
