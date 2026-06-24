package com.mealchemy.vault.service;

/* Importing libraries */
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/* Importing classes */
import com.mealchemy.vault.dto.VaultFolderRequest;
import com.mealchemy.vault.dto.VaultFolderResponse;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.vault.repository.VaultFolderRepository;

@ExtendWith(MockitoExtension.class)
public class VaultFolderServiceTest
{
    @Mock
    private VaultFolderRepository vaultFolderRepository;

    @InjectMocks
    private VaultFolderService vaultFolderService;

    private VaultFolder folder;
    private VaultFolderRequest request;

    @BeforeEach
    void setUp()
    {
        folder = new VaultFolder();
        folder.setVaultId(1);
        folder.setFolderName("General");

        request = new VaultFolderRequest();
        request.setVaultId(1);
        request.setFolderName("General");
    }

    // getVaultFolderByVaultId

    @Test
    void getVaultFolderByVaultId_returnsListOfFolders()
    {
        when(vaultFolderRepository.findByVaultId(1)).thenReturn(List.of(folder));

        List<VaultFolderResponse> result = vaultFolderService.getVaultFolderByVaultId(1);

        assertEquals(1, result.size());
        assertEquals("General", result.get(0).getFolderName());
    }

    @Test
    void getVaultFolderByVaultId_returnsEmptyList_whenNoFoldersFound()
    {
        when(vaultFolderRepository.findByVaultId(99)).thenReturn(List.of());

        List<VaultFolderResponse> result = vaultFolderService.getVaultFolderByVaultId(99);

        assertTrue(result.isEmpty());
    }

    // getVaultFolderByName

    @Test
    void getVaultFolderByName_returnsFolder_whenFound()
    {
        when(vaultFolderRepository.findByFolderName("General")).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderByName("General");

        assertNotNull(result);
        assertEquals("General", result.getFolderName());
    }

    @Test
    void getVaultFolderByName_throwsException_whenNotFound()
    {
        when(vaultFolderRepository.findByFolderName("Nonexistent")).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultFolderService.getVaultFolderByName("Nonexistent"));
        assertEquals("Folder not found.", ex.getMessage());
    }

    // getVaultFolderById

    @Test
    void getVaultFolderById_returnsFolder_whenFound()
    {
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));

        VaultFolderResponse result = vaultFolderService.getVaultFolderById(1);

        assertNotNull(result);
        assertEquals("General", result.getFolderName());
    }

    @Test
    void getVaultFolderById_throwsException_whenNotFound()
    {
        when(vaultFolderRepository.findById(99)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultFolderService.getVaultFolderById(99));
        assertEquals("Folder not found.", ex.getMessage());
    }

    // createVaultFolder

    @Test
    void createVaultFolder_returnsCreatedFolder()
    {
        when(vaultFolderRepository.save(any(VaultFolder.class))).thenReturn(folder);

        VaultFolderResponse result = vaultFolderService.createVaultFolder(request);

        assertNotNull(result);
        assertEquals("General", result.getFolderName());
        verify(vaultFolderRepository, times(1)).save(any(VaultFolder.class));
    }

    // updateVaultFolder

    @Test
    void updateVaultFolder_returnsUpdatedFolder_whenFound()
    {
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));
        when(vaultFolderRepository.save(any(VaultFolder.class))).thenReturn(folder);

        VaultFolderResponse result = vaultFolderService.updateVaultFolder(1, request);

        assertNotNull(result);
        verify(vaultFolderRepository, times(1)).save(any(VaultFolder.class));
    }

    @Test
    void updateVaultFolder_throwsException_whenNotFound()
    {
        when(vaultFolderRepository.findById(99)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultFolderService.updateVaultFolder(99, request));
        assertEquals("Folder not found.", ex.getMessage());
    }

    // deleteVaultFolder

    @Test
    void deleteVaultFolder_callsDeleteById()
    {
        doNothing().when(vaultFolderRepository).deleteById(1);

        vaultFolderService.deleteVaultFolder(1);

        verify(vaultFolderRepository, times(1)).deleteById(1);
    }
}