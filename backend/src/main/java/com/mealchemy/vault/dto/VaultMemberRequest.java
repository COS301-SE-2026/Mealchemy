package com.mealchemy.vault.dto;

/* Import libraries */

import jakarta.validation.constraints.*;

/* Import classes */

public record VaultMemberRequest(
    @NotBlank @Email String email
){}