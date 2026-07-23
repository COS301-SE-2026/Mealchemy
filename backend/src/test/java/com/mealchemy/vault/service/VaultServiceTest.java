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
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.auth.repository.UserRepository;
import com.mealchemy.shared.enums.VaultType;

@ExtendWith(MockitoExtension.class)
public class VaultServiceTest
{
    @Mock
    private VaultRepository vaultRepository;

    @Mock
    private VaultMemberRepository vaultMemberRepository;

    @Mock
    private UserRepository userRepository;

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

        VaultResponse result = vaultService.getVault(1, 1);

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

    @Test
    void getVaultsByOwnerId_returnsListOfVaults()
    {
        when(vaultRepository.findByOwnerId(1)).thenReturn(List.of(vault));

        List<VaultResponse> result = vaultService.getVaultsByOwnerId(1);

        assertEquals(1, result.size());
        assertEquals("Test Vault", result.get(0).name());
    }

    @Test
    void getVaultsByOwnerId_returnsEmptyList_whenNoneFound()
    {
        when(vaultRepository.findByOwnerId(99)).thenReturn(List.of());

        List<VaultResponse> result = vaultService.getVaultsByOwnerId(99);

        assertTrue(result.isEmpty());
    }

    @Test
    void createVault_returnsCreatedVault()
    {
        when(vaultRepository.save(any(Vault.class))).thenReturn(vault);

        VaultResponse result = vaultService.createVault(request, 1);

        assertNotNull(result);
        assertEquals("Test Vault", result.name());
        verify(vaultRepository, times(1)).save(any(Vault.class));
    }

    @Test
    void updateVault_returnsUpdatedVault_whenFound()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultRepository.save(any(Vault.class))).thenReturn(vault);

        VaultResponse result = vaultService.updateVault(1, request, 1);

        assertNotNull(result);
        verify(vaultRepository, times(1)).save(any(Vault.class));
    }

    @Test
    void updateVault_throwsException_whenNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultService.updateVault(99, request, 1));
        assertEquals("Vault not found.", ex.getMessage());
    }

    @Test
    void deleteVault_callsDeleteById()
    {
        doNothing().when(vaultRepository).deleteById(1);

        vaultService.deleteVault(1);

        verify(vaultRepository, times(1)).deleteById(1);
    }
}