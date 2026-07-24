package com.mealchemy.vault.service;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.time.OffsetDateTime;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.shared.enums.VaultType;


@ExtendWith(MockitoExtension.class)
public class VaultMemberServiceTest {
    @Mock
    private VaultMemberRepository vaultMemberRepository;

    @Mock
    private VaultRepository vaultRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private VaultMemberService vaultMemberService;

    private Vault vault;
    private User user;
    private VaultMember vaultMember;
    private VaultMemberRequest request;

    @BeforeEach
    void setUp()
    {
        vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.PRIVATE);
        vault.setName("Test Vault");
        ReflectionTestUtils.setField(vault, "vaultId", 1);

        user = new User();
        user.setEmail("testUser@gmail.com");
        ReflectionTestUtils.setField(user, "userId", 1);

        vaultMember = new VaultMember();
        vaultMember.setVault(vault);
        vaultMember.setUser(user);

        request = new VaultMemberRequest("testUser@gmail.com");
    }

    @Test
    void getVaultMembersByVaultId_returnsListOfVaultMembers_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.findByVault_VaultId(1)).thenReturn(List.of(vaultMember));

        List<VaultMemberResponse> result = vaultMemberService.getVaultMembersByVaultId(1, 1);

        assertEquals(1, result.size());
        assertEquals(1, result.get(0).userId());
    }

    @Test
    void getVaultMembersByVaultId_returnsListOfVaultMembers_whenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 2)).thenReturn(true);
        when(vaultMemberRepository.findByVault_VaultId(1)).thenReturn(List.of(vaultMember));

        List<VaultMemberResponse> result = vaultMemberService.getVaultMembersByVaultId(1, 2);

        assertEquals(1, result.size());
        assertEquals(1, result.get(0).userId());
    }
}
