package com.mealchemy.recipe.service;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.HttpMethod;
import com.google.cloud.storage.Storage;
import com.mealchemy.recipe.dto.RecipePhotoUploadRequest;
import com.mealchemy.recipe.dto.RecipePhotoUploadResponse;
import com.mealchemy.recipe.event.RecipePhotoCleanupEvent;
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

// contains upload authorization and signing logic for images
// vailidates the image, rejects unsuported types, empty files, size>5mb
// then validates recipe, checks authenticated user owns it
// generates unique object file path for bucket storagr
// builds permanent public url

@Service
public class RecipePhotoService
{
    private static final Logger log = LoggerFactory.getLogger(RecipePhotoService.class);

    private static final Map<String, String> ALLOWED_CONTENT_TYPES = Map.of(
        "image/jpeg", "jpg",
        "image/png", "png",
        "image/webp", "webp"
    );

    private final Storage storage;
    private final RecipeRepository recipeRepository;
    private final String bucketName;
    private final Duration uploadUrlExpiry;
    private final long maxFileSizeBytes;

    public RecipePhotoService(
        @Lazy Storage storage,
        RecipeRepository recipeRepository,
        @Value("${recipe.photo.bucket-name:}") String bucketName,
        @Value("${recipe.photo.upload-url-expiry}") Duration uploadUrlExpiry,
        @Value("${recipe.photo.max-file-size}") DataSize maxFileSize
    )
    {
        this.storage = storage;
        this.recipeRepository = recipeRepository;
        this.bucketName = bucketName;
        this.uploadUrlExpiry = uploadUrlExpiry;
        this.maxFileSizeBytes = maxFileSize.toBytes();
    }

    public RecipePhotoUploadResponse createPhotoUploadUrl(
        Integer recipeId,
        RecipePhotoUploadRequest request,
        Integer ownerId
    )
    {
        String contentType = request.contentType().trim().toLowerCase(Locale.ROOT);
        String fileExtension = ALLOWED_CONTENT_TYPES.get(contentType);

        if (fileExtension == null)
        {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Photo must be a JPEG, PNG, or WebP image."
            );
        }

        long fileSizeBytes = request.fileSizeBytes();
        if (fileSizeBytes <= 0 || fileSizeBytes > maxFileSizeBytes)
        {
            throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Photo size must be greater than zero and no more than 5 MB."
            );
        }

        Recipe recipe = recipeRepository.findById(recipeId).orElseThrow(
            () -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Recipe not found.")
        );

        if (!recipe.getOwnerId().equals(ownerId))
        {
            throw new ResponseStatusException(
                HttpStatus.FORBIDDEN,
                "Only the owner of this recipe can upload a photo."
            );
        }

        if (bucketName.isBlank())
        {
            throw new ResponseStatusException(
                HttpStatus.SERVICE_UNAVAILABLE,
                "Recipe photo storage is not configured."
            );
        }

        //creates the unique path where the image will be stored inside the GCS bucket
        //uses uuid gives every upload a unique name needed for replacement handling
        String objectName = String.format(
            "recipes/%d/%s.%s",
            recipeId,
            UUID.randomUUID(),
            fileExtension
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
            log.error("Failed to generate a recipe photo upload URL", exception);
            throw new ResponseStatusException(
                HttpStatus.SERVICE_UNAVAILABLE,
                "Recipe photo upload is temporarily unavailable."
            );
        }
        // format ends up being : https: //storage.googleapis.com/{bucket}/{objectName} 
        OffsetDateTime expiresAt = OffsetDateTime.now(ZoneOffset.UTC).plus(uploadUrlExpiry);
        String photoUrl = String.format(
            "https://storage.googleapis.com/%s/%s",
            bucketName,
            objectName
        );

        return new RecipePhotoUploadResponse(
            uploadUrl.toString(),
            photoUrl,
            requiredHeaders,
            expiresAt
        );
    }

    // added an after comit transaction even listener.
    // receives a cleanup event
    // validates bucket is configured, url not empty, url points to configured bucket, object is inside the correct recipe directory, object has filename after directory prefix.
    // Then calls GCS to delete object
    // if storage deletion fails - logged. The recipe update or deletion still occurs
    // worst outcome is an unused object remaining in bucket, which will be removed by a cleanup sweep later.
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void deletePhotoAfterCommit(RecipePhotoCleanupEvent event)
    {
        if (bucketName.isBlank() || event.photoUrl() == null || event.photoUrl().isBlank())
        {
            return;
        }

        String bucketUrlPrefix = String.format(
            "https://storage.googleapis.com/%s/",
            bucketName
        );
        if (!event.photoUrl().startsWith(bucketUrlPrefix))
        {
            return;
        }

        String objectName = event.photoUrl().substring(bucketUrlPrefix.length());
        String recipeObjectPrefix = String.format("recipes/%d/", event.recipeId());
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
                "Failed to delete an old photo for recipe {}",
                event.recipeId(),
                exception
            );
        }
    }
}
