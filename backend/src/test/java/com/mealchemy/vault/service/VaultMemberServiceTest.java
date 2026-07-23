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

/* Import classes */
import com.mealchemy.vault.dto.VaultMemberResponse;
import com.mealchemy.vault.dto.VaultMemberRequest;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.shared.enums.VaultType;


@ExtendWith(MockitoExtension.class)
public class VaultMemberServiceTest {
    @Mock
    private VaultMemberRepository vaultMemberRepository;

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
}
