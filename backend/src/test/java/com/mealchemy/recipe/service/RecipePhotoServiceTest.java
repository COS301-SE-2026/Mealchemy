package com.mealchemy.recipe.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.mealchemy.recipe.dto.RecipePhotoUploadRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadResponse;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import java.net.URL;
import java.time.Duration;
import java.util.Optional;
import java.util.concurrent.TimeUnit;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.util.unit.DataSize;
import org.springframework.web.server.ResponseStatusException;

@ExtendWith(MockitoExtension.class)
public class RecipePhotoServiceTest
{
    @Mock
    private Storage storage;

    @Mock
    private RecipeRepository recipeRepository;

    private RecipePhotoService recipePhotoService;
    private Recipe recipe;

    @BeforeEach
    void setUp()
    {
        recipePhotoService = new RecipePhotoService(
            storage,
            recipeRepository,
            "recipe-photo-bucket",
            Duration.ofMinutes(10),
            DataSize.ofMegabytes(5)
        );

        recipe = new Recipe();
        recipe.setOwnerId(1);
        ReflectionTestUtils.setField(recipe, "recipeId", 10);
    }

    @Test
    void createPhotoUploadUrl_returnsSignedUploadDetails_whenRequestIsValid() throws Exception
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest(
            "image/jpeg",
            2048L
        );
        URL signedUrl = new URL("https://storage.googleapis.com/signed-upload");

        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));
        when(storage.signUrl(
            any(BlobInfo.class),
            eq(600L),
            eq(TimeUnit.SECONDS),
            any(Storage.SignUrlOption.class),
            any(Storage.SignUrlOption.class),
            any(Storage.SignUrlOption.class)
        )).thenReturn(signedUrl);

        RecipePhotoUploadResponse response = recipePhotoService.createPhotoUploadUrl(
            10,
            request,
            1
        );

        assertEquals(signedUrl.toString(), response.uploadUrl());
        assertTrue(response.photoUrl().startsWith(
            "https://storage.googleapis.com/recipe-photo-bucket/recipes/10/"
        ));
        assertTrue(response.photoUrl().endsWith(".jpg"));
        assertEquals("image/jpeg", response.requiredHeaders().get("Content-Type"));
        assertEquals("2048", response.requiredHeaders().get("Content-Length"));
    }

    @Test
    void createPhotoUploadUrl_throws404_whenRecipeDoesNotExist()
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest("image/png", 2048L);
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipePhotoService.createPhotoUploadUrl(99, request, 1)
        );

        assertEquals(HttpStatus.NOT_FOUND, exception.getStatusCode());
        assertEquals("Recipe not found.", exception.getReason());
    }

    @Test
    void createPhotoUploadUrl_throws403_whenUserDoesNotOwnRecipe()
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest("image/png", 2048L);
        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipePhotoService.createPhotoUploadUrl(10, request, 2)
        );

        assertEquals(HttpStatus.FORBIDDEN, exception.getStatusCode());
        assertEquals(
            "Only the owner of this recipe can upload a photo.",
            exception.getReason()
        );
    }

    @Test
    void createPhotoUploadUrl_throws400_whenContentTypeIsUnsupported()
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest("image/gif", 2048L);

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipePhotoService.createPhotoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        assertEquals("Photo must be a JPEG, PNG, or WebP image.", exception.getReason());
        verifyNoInteractions(recipeRepository, storage);
    }

    @Test
    void createPhotoUploadUrl_throws400_whenFileIsTooLarge()
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest(
            "image/jpeg",
            DataSize.ofMegabytes(5).toBytes() + 1
        );

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipePhotoService.createPhotoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        assertEquals(
            "Photo size must be greater than zero and no more than 5 MB.",
            exception.getReason()
        );
        verifyNoInteractions(recipeRepository, storage);
    }

    @Test
    void createPhotoUploadUrl_throws400_whenFileSizeIsNotPositive()
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest("image/jpeg", 0L);

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipePhotoService.createPhotoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        verifyNoInteractions(recipeRepository, storage);
    }

    @Test
    void createPhotoUploadUrl_throws503_whenBucketIsNotConfigured()
    {
        RecipePhotoService unconfiguredService = new RecipePhotoService(
            storage,
            recipeRepository,
            "",
            Duration.ofMinutes(10),
            DataSize.ofMegabytes(5)
        );
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest("image/webp", 2048L);
        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> unconfiguredService.createPhotoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, exception.getStatusCode());
        assertEquals("Recipe photo storage is not configured.", exception.getReason());
        verifyNoInteractions(storage);
    }

    @Test
    void createPhotoUploadUrl_throws503_whenUrlSigningFails()
    {
        RecipePhotoUploadRequest request = new RecipePhotoUploadRequest("image/jpeg", 2048L);
        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));
        when(storage.signUrl(
            any(BlobInfo.class),
            eq(600L),
            eq(TimeUnit.SECONDS),
            any(Storage.SignUrlOption.class),
            any(Storage.SignUrlOption.class),
            any(Storage.SignUrlOption.class)
        )).thenThrow(new IllegalStateException("Signing failed"));

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipePhotoService.createPhotoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, exception.getStatusCode());
        assertEquals(
            "Recipe photo upload is temporarily unavailable.",
            exception.getReason()
        );
    }
}
