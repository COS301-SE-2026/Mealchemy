package com.mealchemy.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ImpersonatedCredentials;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;
import java.io.IOException;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;

//bucket name configured, 10 minute expirary, 5MB limit

@Configuration
public class RecipePhotoStorageConfig
{
    //google cloud api authorization. allows generated credentials to call google cloud apis. IAM still controls what service accounts can do, does not grant IAM permission.
    private static final String CLOUD_PLATFORM_SCOPE =
        "https://www.googleapis.com/auth/cloud-platform";

    @Bean
    @Lazy
    //bean makes GCS storage cluent avaiulable for injection into future photo services
    //lazy delays creating it util photo feature actually needs it. therefore normal startup and unlreated tests do not need google credentials.
    public Storage recipePhotoStorage(
        @Value("${recipe.photo.signing-service-account:}") String signingServiceAccount
    ) throws IOException
    {
        GoogleCredentials sourceCredentials = GoogleCredentials.getApplicationDefault()
            .createScoped(List.of(CLOUD_PLATFORM_SCOPE));
        GoogleCredentials storageCredentials = sourceCredentials;

        if (!signingServiceAccount.isBlank())
        {
            //impersonate lets google perform signBlob securely
            //backend asks google IAM to act as signing identity
            //3600s is max lifetime of temp impersonated credentials
            storageCredentials = ImpersonatedCredentials.create(
                sourceCredentials,
                signingServiceAccount,
                null,
                List.of(CLOUD_PLATFORM_SCOPE),
                3600
            );
        }

        //creates offical GCS client
        //used to generate signed upload URLS, inspect objects, delete old photos.
        return StorageOptions.newBuilder()
            .setCredentials(storageCredentials)
            .build()
            .getService();
    }
}