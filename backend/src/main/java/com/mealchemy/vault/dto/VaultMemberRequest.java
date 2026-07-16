package com.mealchemy.vault.dto;

/* Import libraries */

/* Import classes */

public record VaultMemberRequest(
    @NotNull Integer VaultId,
    @NotNull Integer UserId
){}