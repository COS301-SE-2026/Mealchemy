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

import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

/* Importing classes */
import com.mealchemy.vault.dto.VaultRequest;
import com.mealchemy.vault.dto.VaultResponse;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
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
        vault.setVaultType(VaultType.SHARED);
        vault.setName("Test Vault");

        request = new VaultRequest(VaultType.SHARED, "Test Vault");
    }

    @Test
    void getVault_returnsVault_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        VaultResponse result = vaultService.getVault(1, 1);

        assertNotNull(result);
        assertEquals("Test Vault", result.name());
    }

    @Test
    void getVault_returnsVaultWhenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 2)).thenReturn(true);

        VaultResponse result = vaultService.getVault(1, 2);
        
        assertNotNull(result);
        assertEquals("Test Vault", result.name());
    }

    @Test
    void getVault_throwsException_whenNotVaultOwnerOrMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.getVault(1, 3));
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault member/owner can view it.", ex.getReason());
    }

    @Test
    void getVault_throwsException_whenNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.getVault(99, 1));
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
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
        when(userRepository.findById(1)).thenReturn(Optional.of(new User()));

        VaultResponse result = vaultService.createVault(request, 1);

        assertNotNull(result);
        assertEquals("Test Vault", result.name());
        verify(vaultRepository, times(1)).save(any(Vault.class));
    }

    @Test
    void createVault_throwsException_whenVaultTypeIsPrivate()
    {
        when(userRepository.findById(1)).thenReturn(Optional.of(new User()));

        VaultRequest privateRequest = new VaultRequest(VaultType.PRIVATE, "Test Private Vault");

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.createVault(privateRequest, 1));
        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Users only get one private vault.", ex.getReason());
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

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.updateVault(99, request, 1));
        
        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void updateVault_throwsException_whenNotVaultOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.updateVault(1, request, 2));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Vault can only be edited by the owner.", ex.getReason());
    }

    @Test
    void updateVault_throwsException_whenVaultTypeIsPrivate()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        VaultRequest privateRequest = new VaultRequest(VaultType.PRIVATE, "Test Private Vault");

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.updateVault(1, privateRequest, 1));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Users only get one private vault.", ex.getReason());
    }

    @Test
    void deleteVault_callsDeleteById_whenOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        doNothing().when(vaultRepository).deleteById(1);

        vaultService.deleteVault(1, 1);

        verify(vaultRepository, times(1)).deleteById(1);
    }

    @Test
    void deleteVault_throwsException_whenNotOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.deleteVault(1, 2));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Vaults can only be deleted be the owner.", ex.getReason());
    } 

    @Test
    void deleteVault_throwsException_whenVaultTypeIsPrivate()
    {
        vault.setVaultType(VaultType.PRIVATE);
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultService.deleteVault(1, 1));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Private vaults can't be deleted.", ex.getReason());
    }
}