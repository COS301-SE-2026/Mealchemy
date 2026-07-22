package com.mealchemy.vault.service;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/* Importing classes */
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.shared.enums.VaultType;

@ExtendWith(MockitoExtension.class)
public class VaultServiceTest
{
    @Mock
    private VaultRepository vaultRepository;

    @InjectMocks
    private VaultService vaultService;

    private Vault vault;
    private VaultRequest request;

    @BeforeEach
    void setUp()
    {
        vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.PRIVATE);
        vault.setName("Test Vault");

        request = new VaultRequest(VaultType.PRIVATE, "Test Vault");
    }

    @Test
    void getVault_returnsVault_whenFound()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        VaultResponse result = vaultService.getVault(1);

        assertNotNull(result);
        assertEquals("Test Vault", result.name());
    }

    @Test
    void getVault_throwsException_whenNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultService.getVault(99));
        assertEquals("Vault not found.", ex.getMessage());
    }
}