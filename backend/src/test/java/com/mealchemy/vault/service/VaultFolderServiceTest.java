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
    private Vault privateVault;
    private VaultFolderRequest request;

    @BeforeEach
    void setUp()
    {
        vault = new Vault();
        vault.setOwnerId(1);
        vault.setVaultType(VaultType.SHARED);
        vault.setName("Test Vault");
        ReflectionTestUtils.setField(vault, "vaultId", 1);

        privateVault = new Vault();
        privateVault.setOwnerId(1);
        privateVault.setVaultType(VaultType.PRIVATE);
        privateVault.setName("Private Vault");
        ReflectionTestUtils.setField(privateVault, "vaultId", 2);

        folder = new VaultFolder();
        folder.setVault(vault);
        folder.setFolderName("General");
        ReflectionTestUtils.setField(folder, "folderId", 1);

        request = new VaultFolderRequest(1, "General");
    }

    @Test
    void getVaultFolderByVaultId_returnsFolders_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findByVault_VaultId(1)).thenReturn(List.of(folder));

        List<VaultFolderResponse> result = vaultFolderService.getVaultFolderByVaultId(1, 1);

        assertNotNull(result);
        assertEquals("General", result.get(0).folderName());
    }

    @Test
    void getVaultFolderByVaultId_returnsFolder_whenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(true);
        when(vaultFolderRepository.findByVault_VaultId(1)).thenReturn(List.of(folder));

        List<VaultFolderResponse> result = vaultFolderService.getVaultFolderByVaultId(1, 3);

        assertNotNull(result);
        assertEquals("General", result.get(0).folderName());
    }

    @Test
    void getVaultFolderByVaultId_throwsException_whenVaultNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByVaultId(99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void getVaultFolderByVaultId_throwsException_whenNotOwnerOrMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByVaultId(1, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault member/owner can view the folders.", ex.getReason());
    }
    
    @Test
    void getVaultFolderByName_returnsVaultFolder_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findByFolderName("General")).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderByName("General", 1, 1);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderByName_returnsVaultFolder_whenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(true);
        when(vaultFolderRepository.findByFolderName("General")).thenReturn(Optional.of(folder));
        
        VaultFolderResponse result = vaultFolderService.getVaultFolderByName("General", 1, 3);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderByName_throwsException_whenVaultNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByName("General", 99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void getVaultFolderByName_throwsException_whenNotOwnerOrMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByName("General", 1, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault member/owner can view the folders.", ex.getReason());
    }

    @Test
    void getVaultFolderByName_throwsException_whenFolderNotFound()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findByFolderName("General")).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderByName("General", 1, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Folder not found.", ex.getReason());
    }

    @Test
    void getVaultFolderById_returnsFolder_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderById(1, 1, 1);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderById_returnsFolder_whenFoundAndMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(true);
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderById(1, 1, 3);

        assertNotNull(result);
        assertEquals("General", result.folderName());
    }

    @Test
    void getVaultFolderById_throwsException_whenVaultNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderById(1, 99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void getVaultFolderById_throwsException_whenNotOwnerOrMember()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(false);

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderById(1, 1, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault member/owner can view the folders.", ex.getReason());
    }

    @Test
    void getVaultFolderById_throwsException_whenFolderNotFound()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 1)).thenReturn(false);
        when(vaultFolderRepository.findById(3)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getVaultFolderById(3, 1, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Folder not found.", ex.getReason());
    }

    @Test
    void getPrivateVaultFolders_returnsFolders_whenPrivateVaultFound()
    {
        VaultFolder privateFolder = new VaultFolder();
        privateFolder.setVault(privateVault);
        privateFolder.setFolderName("Private Folder");
        ReflectionTestUtils.setField(privateFolder, "folderId", 2);

        when(vaultRepository.findByOwnerIdAndVaultType(1, VaultType.PRIVATE)).thenReturn(Optional.of(privateVault));
        when(vaultFolderRepository.findByVault_VaultId(2)).thenReturn(List.of(privateFolder));

        List<VaultFolderResponse> result = vaultFolderService.getPrivateVaultFolders(1);

        assertEquals(1, result.size());
        assertEquals("Private Folder", result.get(0).folderName());
    }

    @Test
    void getPrivateVaultFolders_throwsException_whenPrivateVaultNotFound()
    {
        when(vaultRepository.findByOwnerIdAndVaultType(1, VaultType.PRIVATE)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.getPrivateVaultFolders(1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Private vault not found.", ex.getReason());
    }

    @Test
    void createVaultFolder_returnsCreatedVaultFolder_whenFoundAndOwner()
    {
        when(vaultRepository.findById(request.vaultId())).thenReturn(Optional.of(vault));
        when(vaultFolderRepository.save(any(VaultFolder.class))).thenReturn(folder);

        VaultFolderResponse result = vaultFolderService.createVaultFolder(request, 1);

        assertNotNull(result);
        assertEquals("General", result.folderName());
        verify(vaultFolderRepository, times(1)).save(any(VaultFolder.class));
    }

    @Test
    void createVaultFolder_throwsException_whenVaultNotFound()
    {
        when(vaultRepository.findById(request.vaultId())).thenReturn(Optional.empty());
        
        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.createVaultFolder(request, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void createVaultFolder_throwsException_whenNotOwner()
    {
        when(vaultRepository.findById(request.vaultId())).thenReturn(Optional.of(vault));
        
        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.createVaultFolder(request, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault owner can modify folders.", ex.getReason());
    }

    @Test
    void updateVaultFolder_updatesFolder_whenFoundAndOwner()
    {
        when(vaultRepository.findById(request.vaultId())).thenReturn(Optional.of(vault));
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));
        when(vaultFolderRepository.save(any(VaultFolder.class))).thenReturn(folder);

        VaultFolderRequest updateRequest = new VaultFolderRequest(1, "Updated General");

        VaultFolderResponse result = vaultFolderService.updateVaultFolder(1, updateRequest, 1);

        assertNotNull(result);
        assertEquals("Updated General", result.folderName());
        verify(vaultFolderRepository, times(1)).save(any(VaultFolder.class));
    }

    @Test 
    void updateVaultFolder_throwsException_whenVaultNotFound()
    {
        VaultFolderRequest vaultNotFoundRequest = new VaultFolderRequest(99, "General");

        when(vaultRepository.findById(vaultNotFoundRequest.vaultId())).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.updateVaultFolder(2, vaultNotFoundRequest, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void updateVaultFolder_throwsException_whenNotOwner()
    {
        when(vaultRepository.findById(request.vaultId())).thenReturn(Optional.of(vault));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.updateVaultFolder(1, request, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault owner can modify folders.", ex.getReason());
    }

    @Test
    void updateVaultFolder_throwsException_whenFolderNotFound()
    {
        when(vaultRepository.findById(request.vaultId())).thenReturn(Optional.of(vault));
        when(vaultFolderRepository.findById(99)).thenReturn(Optional.empty());       
        
        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.updateVaultFolder(99, request, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Folder not found.", ex.getReason());
    }

    @Test
    void deleteVaultFolder_callsDeleteById_whenFoundAndOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));
        doNothing().when(vaultFolderRepository).deleteById(1);

        vaultFolderService.deleteVaultFolder(1, 1, 1);

        verify(vaultFolderRepository, times(1)).deleteById(1);
    }

    @Test
    void deleteVaultFolder_throwsException_whenVaultNotFound()
    {
        when(vaultRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.deleteVaultFolder(1, 99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Vault not found.", ex.getReason());
    }

    @Test
    void deleteVaultFolder_throwsException_whenNotOwner()
    {
        when(vaultRepository.findById(1)).thenReturn(Optional.of(vault));

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderService.deleteVaultFolder(1, 1, 3));

        assertEquals(HttpStatus.FORBIDDEN, ex.getStatusCode());
        assertEquals("Only a vault owner can modify folders.", ex.getReason());
    }
}