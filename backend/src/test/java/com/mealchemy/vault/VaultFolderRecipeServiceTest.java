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
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;

@ExtendWith(MockitoExtension.class)
public class VaultFolderRecipeServiceTest
{
    @Mock
    private VaultFolderRecipeRepository vaultFolderRecipeRepository;

    @InjectMocks
    private VaultFolderRecipeService vaultFolderRecipeService;

    private VaultFolderRecipe folderRecipe;
    private VaultFolderRecipeRequest request;

    @BeforeEach
    void setUp()
    {
        folderRecipe = new VaultFolderRecipe();
        folderRecipe.setFolderId(1);
        folderRecipe.setRecipeId(1);

        request = new VaultFolderRecipeRequest();
        request.setFolderId(1);
        request.setRecipeId(1);
    }

    // getRecipesByFolderId

    @Test
    void getRecipesByFolderId_returnsListOfRecipes()
    {
        when(vaultFolderRecipeRepository.findByFolderId(1)).thenReturn(List.of(folderRecipe));

        List<VaultFolderRecipeResponse> result = vaultFolderRecipeService.getRecipesByFolderId(1);

        assertEquals(1, result.size());
        assertEquals(1, result.get(0).getFolderId());
    }

    @Test
    void getRecipesByFolderId_returnsEmptyList_whenNoRecipesFound()
    {
        when(vaultFolderRecipeRepository.findByFolderId(99)).thenReturn(List.of());

        List<VaultFolderRecipeResponse> result = vaultFolderRecipeService.getRecipesByFolderId(99);

        assertTrue(result.isEmpty());
    }

    // getFoldersByRecipeId

    @Test
    void getFoldersByRecipeId_returnsListOfFolders()
    {
        when(vaultFolderRecipeRepository.findByRecipeId(1)).thenReturn(List.of(folderRecipe));

        List<VaultFolderRecipeResponse> result = vaultFolderRecipeService.getFoldersByRecipeId(1);

        assertEquals(1, result.size());
        assertEquals(1, result.get(0).getRecipeId());
    }

    @Test
    void getFoldersByRecipeId_returnsEmptyList_whenNoFoldersFound()
    {
        when(vaultFolderRecipeRepository.findByRecipeId(99)).thenReturn(List.of());

        List<VaultFolderRecipeResponse> result = vaultFolderRecipeService.getFoldersByRecipeId(99);

        assertTrue(result.isEmpty());
    }

    // getFolderRecipeById

    @Test
    void getFolderRecipeById_returnsRecord_whenFound()
    {
        when(vaultFolderRecipeRepository.findById(1)).thenReturn(Optional.of(folderRecipe));

        VaultFolderRecipeResponse result = vaultFolderRecipeService.getFolderRecipeById(1);

        assertNotNull(result);
        assertEquals(1, result.getFolderId());
    }

    @Test
    void getFolderRecipeById_throwsException_whenNotFound()
    {
        when(vaultFolderRecipeRepository.findById(99)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultFolderRecipeService.getFolderRecipeById(99));
        assertEquals("No record found", ex.getMessage());
    }

    // createVaultFolderRecipe

    @Test
    void createVaultFolderRecipe_returnsCreatedRecord()
    {
        when(vaultFolderRecipeRepository.save(any(VaultFolderRecipe.class))).thenReturn(folderRecipe);

        VaultFolderRecipeResponse result = vaultFolderRecipeService.createVaultFolderRecipe(request);

        assertNotNull(result);
        assertEquals(1, result.getFolderId());
        verify(vaultFolderRecipeRepository, times(1)).save(any(VaultFolderRecipe.class));
    }

    // updateVaultFolderRecipe

    @Test
    void updateVaultFolderRecipe_returnsUpdatedRecord_whenFound()
    {
        when(vaultFolderRecipeRepository.findById(1)).thenReturn(Optional.of(folderRecipe));
        when(vaultFolderRecipeRepository.save(any(VaultFolderRecipe.class))).thenReturn(folderRecipe);

        VaultFolderRecipeResponse result = vaultFolderRecipeService.updateVaultFolderRecipe(1, request);

        assertNotNull(result);
        verify(vaultFolderRecipeRepository, times(1)).save(any(VaultFolderRecipe.class));
    }

    @Test
    void updateVaultFolderRecipe_throwsException_whenNotFound()
    {
        when(vaultFolderRecipeRepository.findById(99)).thenReturn(Optional.empty());

        RuntimeException ex = assertThrows(RuntimeException.class, () -> vaultFolderRecipeService.updateVaultFolderRecipe(99, request));
        assertEquals("No record found", ex.getMessage());
    }

    // deleteVaultFolderRecipe

    @Test
    void deleteVaultFolderRecipe_callsDeleteById()
    {
        doNothing().when(vaultFolderRecipeRepository).deleteById(1);

        vaultFolderRecipeService.deleteVaultFolderRecipe(1);

        verify(vaultFolderRecipeRepository, times(1)).deleteById(1);
    }
}