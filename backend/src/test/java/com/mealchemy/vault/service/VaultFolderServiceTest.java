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

import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.vault.repository.VaultRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.shared.enums.VaultType;

@ExtendWith(MockitoExtension.class)
public class VaultFolderServiceTest
{
    @Mock
    private VaultFolderRepository vaultFolderRepository;

    @Mock
    private VaultRepository vaultRepository;

    @Mock
    private VaultMemberRepository vaultMemberRepository;

    @InjectMocks
    private VaultFolderService vaultFolderService;

    private VaultFolder folder;
    private Vault vault;
    private VaultFolderRequest request;

    @BeforeEach
    void setUp()
    {
        vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.SHARED);
        vault.setName("Test Vault");
        ReflectionTestUtils.setField(vault, "vaultId", 1);

        folder = new VaultFolder();
        folder.setVault(vault);
        folder.setFolderName("General");
        ReflectionTestUtils.setField(folder, "folderId", 1);

        request = new VaultFolderRequest(1, "General");
    }

    @Test
    void getVaultFolderByVaultId_returnsFolder_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findByVault_VaultId(1)).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderByVaultId(1, 1);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderByVaultId_returnsFolder_whenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(true);
        when(vaultFolderRepository.findByVault_VaultId(1)).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderByVaultId(1, 3);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderByVaultId_throwsException_whenVaultNotFound()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByVaultId(1, 1));

        assertEquals(HttpsStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void getVaultFolderByVaultId_throwsException_whenNotOwnerOrMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.empty());
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByVaultId(1, 3));

        assertEquals(HttpsStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only vault a member/owner can view the folders.", ex.getReason());
    }
    
    @Test
    void getVaultFolderByName_returnsVaultFolder_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findByFolderName("General")).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderByVaultId(1, 1);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderByName_returnsVaultFolder_whenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(true);
        when(vaultFolderRepository.findByFolderName("General")).thenReturn(Optional.of(folder));
        
        VaultFolderResponse result = vaultFolderService.getVaultFolderByVaultId(1, 3);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }
}