package com.mealchemy.recipe.service;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.mealchemy.recipe.dto.RecipeVideoUploadRequest;
import com.mealchemy.recipe.dto.RecipeVideoUploadResponse;
import com.mealchemy.recipe.event.RecipeVideoCleanupEvent;
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
public class RecipeVideoServiceTest
{
    @Mock
    private Storage storage;

    @Mock
    private RecipeRepository recipeRepository;

    private RecipeVideoService recipeVideoService;
    private Recipe recipe;

    @BeforeEach
    void setUp()
    {
        recipeVideoService = new RecipeVideoService(
            storage,
            recipeRepository,
            "recipe-photo-bucket",
            Duration.ofMinutes(10),
            DataSize.ofMegabytes(50)
        );
        recipe = new Recipe();
        recipe.setOwnerId(1);
        ReflectionTestUtils.setField(recipe, "recipeId", 10);
    }

    @Test
    void createVideoUploadUrl_returnsSignedUploadDetails_whenRequestIsValid() throws Exception
    {
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest("video/mp4", 4096L);
        URL signedUrl = new URL("https://storage.googleapis.com/signed-video-upload");

        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));
        when(storage.signUrl(
            any(BlobInfo.class),
            eq(600L),
            eq(TimeUnit.SECONDS),
            any(Storage.SignUrlOption.class),
            any(Storage.SignUrlOption.class),
            any(Storage.SignUrlOption.class)
        )).thenReturn(signedUrl);

        RecipeVideoUploadResponse response = recipeVideoService.createVideoUploadUrl(
            10,
            request,
            1
        );

        assertEquals(signedUrl.toString(), response.uploadUrl());
        assertTrue(response.videoUrl().startsWith(
            "https://storage.googleapis.com/recipe-photo-bucket/recipes/10/videos/"
        ));
        assertTrue(response.videoUrl().endsWith(".mp4"));
        assertEquals("video/mp4", response.requiredHeaders().get("Content-Type"));
        assertEquals("4096", response.requiredHeaders().get("Content-Length"));
    }

    @Test
    void createVideoUploadUrl_throws404_whenRecipeDoesNotExist()
    {
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest("video/mp4", 4096L);
        when(recipeRepository.findById(99)).thenReturn(Optional.empty());

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipeVideoService.createVideoUploadUrl(99, request, 1)
        );

        assertEquals(HttpStatus.NOT_FOUND, exception.getStatusCode());
        assertEquals("Recipe not found.", exception.getReason());
    }

    @Test
    void createVideoUploadUrl_throws403_whenUserDoesNotOwnRecipe()
    {
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest("video/mp4", 4096L);
        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipeVideoService.createVideoUploadUrl(10, request, 2)
        );

        assertEquals(HttpStatus.FORBIDDEN, exception.getStatusCode());
        assertEquals(
            "Only the owner of this recipe can upload a video.",
            exception.getReason()
        );
    }

    @Test
    void createVideoUploadUrl_throws400_whenContentTypeIsUnsupported()
    {
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest("video/webm", 4096L);

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipeVideoService.createVideoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        assertEquals("Video must be an MP4 file.", exception.getReason());
        verifyNoInteractions(recipeRepository, storage);
    }

    @Test
    void createVideoUploadUrl_throws400_whenFileIsTooLarge()
    {
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest(
            "video/mp4",
            DataSize.ofMegabytes(50).toBytes() + 1
        );

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> recipeVideoService.createVideoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.BAD_REQUEST, exception.getStatusCode());
        assertEquals(
            "Video size must be greater than zero and no more than 50 MB.",
            exception.getReason()
        );
        verifyNoInteractions(recipeRepository, storage);
    }

    @Test
    void createVideoUploadUrl_throws503_whenBucketIsNotConfigured()
    {
        RecipeVideoService unconfiguredService = new RecipeVideoService(
            storage,
            recipeRepository,
            "",
            Duration.ofMinutes(10),
            DataSize.ofMegabytes(50)
        );
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest("video/mp4", 4096L);
        when(recipeRepository.findById(10)).thenReturn(Optional.of(recipe));

        ResponseStatusException exception = assertThrows(
            ResponseStatusException.class,
            () -> unconfiguredService.createVideoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, exception.getStatusCode());
        assertEquals("Recipe video storage is not configured.", exception.getReason());
        verifyNoInteractions(storage);
    }

    @Test
    void createVideoUploadUrl_throws503_whenUrlSigningFails()
    {
        RecipeVideoUploadRequest request = new RecipeVideoUploadRequest("video/mp4", 4096L);
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
            () -> recipeVideoService.createVideoUploadUrl(10, request, 1)
        );

        assertEquals(HttpStatus.SERVICE_UNAVAILABLE, exception.getStatusCode());
        assertEquals(
            "Recipe video upload is temporarily unavailable.",
            exception.getReason()
        );
    }

    @Test
    void deleteVideoAfterCommit_deletesManagedRecipeVideo()
    {
        String objectName = "recipes/10/videos/old.mp4";
        RecipeVideoCleanupEvent event = new RecipeVideoCleanupEvent(
            10,
            "https://storage.googleapis.com/recipe-photo-bucket/" + objectName
        );

        recipeVideoService.deleteVideoAfterCommit(event);

        verify(storage).delete(BlobId.of("recipe-photo-bucket", objectName));
    }

    @Test
    void deleteVideoAfterCommit_ignoresExternalOrWrongRecipeUrl()
    {
        recipeVideoService.deleteVideoAfterCommit(new RecipeVideoCleanupEvent(
            10,
            "https://example.com/video.mp4"
        ));
        recipeVideoService.deleteVideoAfterCommit(new RecipeVideoCleanupEvent(
            10,
            "https://storage.googleapis.com/recipe-photo-bucket/recipes/20/videos/video.mp4"
        ));

        verifyNoInteractions(storage);
    }

    @Test
    void deleteVideoAfterCommit_doesNotThrow_whenStorageDeleteFails()
    {
        String objectName = "recipes/10/videos/old.mp4";
        RecipeVideoCleanupEvent event = new RecipeVideoCleanupEvent(
            10,
            "https://storage.googleapis.com/recipe-photo-bucket/" + objectName
        );
        when(storage.delete(BlobId.of("recipe-photo-bucket", objectName)))
            .thenThrow(new IllegalStateException("Delete failed"));

        assertDoesNotThrow(() -> recipeVideoService.deleteVideoAfterCommit(event));
    }
}