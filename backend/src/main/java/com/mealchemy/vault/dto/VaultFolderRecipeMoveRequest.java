package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;
import jakarta.validation.constraints.*;

/* Import classes */

public record VaultFolderRecipeMoveRequest(
    @NotNull Integer folderId
){
}