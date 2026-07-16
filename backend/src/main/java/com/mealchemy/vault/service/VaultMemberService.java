package com.mealchemy.vault.service;

/* Import libraries */

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.*;

/* Import classes */

import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.auth.repository.UserRepository;

@Service
public class VaultMemberService {
    private final VaultMemberRepository vaultMemberRepository;

    private final UserRepository userRepository;

    public VaultMemberService(VaultMemberRepository vaultMemberRepository, UserRepository userRepository)
    {
        this.vaultMemberRepisitory = vaultMemberRepository;
        this.userRepository = userRepository;
    }

    // Get all vault members
    public List<VaultMemberResponse> getAllVaultMembers()
    {
        return vaultMemberRepository.findAll().map(VaultMemberResponse::from).collect(Collectors.toList());
    }



    /* Mapping functions */

    public VaultMember mapRequestToEntity(VaultMemberRequest request, Integer userIdIn)
    {
        VaultMember member = new VaultMember();

        member.setVaultId(request.vaultId());
        member.setUserId(userIdIn);

        return member;
    }
}
