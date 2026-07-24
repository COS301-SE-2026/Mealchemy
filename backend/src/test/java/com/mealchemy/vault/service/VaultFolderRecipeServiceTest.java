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
import com.mealchemy.vault.model.VaultFolderRecipe;
import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.vault.model.VaultFolder;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.auth.model.User;
import com.mealchemy.vault.dto.VaultFolderRecipeResponse;
import com.mealchemy.vault.dto.VaultFolderRecipeRequest;
import com.mealchemy.vault.dto.VaultFolderRecipeMoveRequest;
import com.mealchemy.vault.repository.VaultFolderRecipeRepository;
import com.mealchemy.vault.repository.VaultMemberRepository;
import com.mealchemy.recipe.repository.RecipeRepository;
import com.mealchemy.vault.repository.VaultFolderRepository;
import com.mealchemy.auth.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
public class VaultFolderRecipeServiceTest
{
    @Mock
    private VaultFolderRecipeRepository vaultFolderRecipeRepository;

    @Mock
    private VaultMemberRepository vaultMemberRepository;

    @Mock
    private VaultFolderRepository vaultFolderRepository;

    @Mock
    private RecipeRepository recipeRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private VaultFolderRecipeService vaultFolderRecipeService;

    private VaultFolderRecipe folderRecipe;
    private Recipe recipe;
    private User user;
    private Vault vault;
    private VaultFolder folder;
    private VaultFolderRecipeRequest request;
    private VaultFolderRecipeMoveRequest moveRequest;

    @BeforeEach
    void setUp()
    {
        vault = new Vault();
        vault.setOwnerId(1);
        ReflectionTestUtils.setField(vault, "vaultId", 1);

        folder = new VaultFolder();
        folder.setVault(vault);
        ReflectionTestUtils.setField(folder, "folderId", 1);

        recipe = new Recipe();
        recipe.setOwnerId(1);
        ReflectionTestUtils.setField(recipe, "recipeId", 1);

        user = new User();
        ReflectionTestUtils.setField(user, "userId", 1);

        folderRecipe = new VaultFolderRecipe();
        folderRecipe.setFolder(folder);
        folderRecipe.setRecipe(recipe);
        folderRecipe.setAddedBy(user);
        ReflectionTestUtils.setField(folderRecipe, "id", 1);

        request = new VaultFolderRecipeRequest(1, 1);
        moveRequest = new VaultFolderRecipeMoveRequest(1);
    }

    @Test
    void getRecipesByFolderId_returnsListOfRecipes_whenFoundAndOwner()
    {
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));
        when(vaultFolderRecipeRepository.findByFolder_FolderId(1)).thenReturn(List.of(folderRecipe));

        List<VaultFolderRecipeResponse> result = vaultFolderRecipeService.getRecipesByFolderId(1, 1);

        assertNotNull(result);
        assertEquals(1, result.get(0).addedByUserId());
    }

    @Test
    void getRecipesByFolderId_returnsListOfRecipes_whenFoundAndMember()
    {
        when(vaultFolderRepository.findById(1)).thenReturn(Optional.of(folder));
        when(vaultMemberRepository.existsByVault_VaultIdAndUser_UserId(1, 3)).thenReturn(true);
        when(vaultFolderRecipeRepository.findByFolder_FolderId(1)).thenReturn(List.of(folderRecipe));

        List<VaultFolderRecipeResponse> result = vaultFolderRecipeService.getRecipesByFolderId(1, 3);

        assertNotNull(result);
        assertEquals(1, result.get(0).addedByUserId());
    }

    @Test
    void getRecipesByFolderId_throwsException_whenFolderNotFound()
    {
        when(vaultFolderRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException ex = assertThrows(ResponseStatusException.class, () -> vaultFolderRecipeService.getRecipesByFolderId(99, 1));

        assertEquals(HttpStatus.NOT_FOUND, ex.getStatusCode());
        assertEquals("Folder not found.", ex.getReason());
    }
}