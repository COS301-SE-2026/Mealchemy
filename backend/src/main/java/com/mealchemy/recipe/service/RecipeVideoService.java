package com.mealchemy.recipe.service;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.HttpMethod;
import com.google.cloud.storage.Storage;
import com.mealchemy.recipe.dto.RecipeVideoUploadRequest;
import com.mealchemy.recipe.dto.RecipeVideoUploadResponse;
import com.mealchemy.recipe.event.RecipeVideoCleanupEvent;
import com.mealchemy.recipe.model.Recipe;
import com.mealchemy.recipe.repository.RecipeRepository;
import java.net.URL;
import java.time.Duration;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Lazy;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.util.unit.DataSize;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RecipeVideoService
{
    private static final Logger log = LoggerFactory.getLogger(RecipeVideoService.class);
    private static final String VIDEO_CONTENT_TYPE = "video/mp4";

    private final Storage storage;
    private final RecipeRepository recipeRepository;
    private final String bucketName;
    private final Duration uploadUrlExpiry;
    private final long maxFileSizeBytes;

    public RecipeVideoService(
        @Lazy Storage storage,
        RecipeRepository recipeRepository,
        @Value("${recipe.photo.bucket-name:}") String bucketName,
        @Value("${recipe.video.upload-url-expiry}") Duration uploadUrlExpiry,
        @Value("${recipe.video.max-file-size}") DataSize maxFileSize
    )
    {
        this.storage = storage;
        this.recipeRepository = recipeRepository;
        this.bucketName = bucketName;
        this.uploadUrlExpiry = uploadUrlExpiry;
        this.maxFileSizeBytes = maxFileSize.toBytes();
    }

    public RecipeVideoUploadResponse createVideoUploadUrl(
        Integer recipeId,
        RecipeVideoUploadRequest request,
        Integer ownerId
    )
    {
        String contentType = request.contentType().trim().toLowerCase(Locale.ROOT);
        if (!VIDEO_CONTENT_TYPE.equals(contentType))
        {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Video must be an MP4 file."
            );
        }

        long fileSizeBytes = request.fileSizeBytes();
        if (fileSizeBytes <= 0 || fileSizeBytes > maxFileSizeBytes)
        {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Video size must be greater than zero and no more than 50 MB."
            );
        }

        Recipe recipe = recipeRepository.findById(recipeId).orElseThrow(
            () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.")
        );
        if (!recipe.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Only the owner of this recipe can upload a video."
            );
        }
        if (bucketName.isBlank())
        {
            throw new ResponseStatusException(
                HttpStatus.SERVICE_UNAVAILABLE,
                "Recipe video storage is not configured."
            );
        }

        String objectName = String.format(
            "recipes/%d/videos/%s.mp4",
            recipeId,
            UUID.randomUUID()
        );
        Map<String, String> requiredHeaders = Map.of(
            "Content-Type", contentType,
            "Content-Length", String.valueOf(fileSizeBytes)
        );
        BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(bucketName, objectName))
            .setContentType(contentType)
            .build();

        URL uploadUrl;
        try
        {
            uploadUrl = storage.signUrl(
                blobInfo,
                uploadUrlExpiry.toSeconds(),
                TimeUnit.SECONDS,
                Storage.SignUrlOption.httpMethod(HttpMethod.PUT),
                Storage.SignUrlOption.withExtHeaders(requiredHeaders),
                Storage.SignUrlOption.withV4Signature()
            );
        }
        catch (RuntimeException exception)
        {
            log.error("Failed to generate a recipe video upload URL", exception);
            throw new ResponseStatusException(
                HttpStatus.SERVICE_UNAVAILABLE,
                "Recipe video upload is temporarily unavailable."
            );
        }

        OffsetDateTime expiresAt = OffsetDateTime.now(ZoneOffset.UTC).plus(uploadUrlExpiry);
        String videoUrl = String.format(
            "https://storage.googleapis.com/%s/%s",
            bucketName,
            objectName
        );
        return new RecipeVideoUploadResponse(
            uploadUrl.toString(),
            videoUrl,
            requiredHeaders,
            expiresAt
        );
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void deleteVideoAfterCommit(RecipeVideoCleanupEvent event)
    {
        if (bucketName.isBlank() || event.videoUrl() == null || event.videoUrl().isBlank())
        {
            return;
        }

        String bucketUrlPrefix = String.format(
            "https://storage.googleapis.com/%s/",
            bucketName
        );
        if (!event.videoUrl().startsWith(bucketUrlPrefix))
        {
            return;
        }

        String objectName = event.videoUrl().substring(bucketUrlPrefix.length());
        String recipeObjectPrefix = String.format("recipes/%d/videos/", event.recipeId());
        if (!objectName.startsWith(recipeObjectPrefix)
            || objectName.length() == recipeObjectPrefix.length())
        {
            return;
        }

        try
        {
            storage.delete(BlobId.of(bucketName, objectName));
        }
        catch (RuntimeException exception)
        {
            log.error(
                "Failed to delete an old video for recipe {}",
                event.recipeId(),
                exception
            );
        }
    }
}
