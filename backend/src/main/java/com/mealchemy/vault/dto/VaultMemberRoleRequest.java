package com.mealchemy.vault.dto;

import com.mealchemy.shared.enums.VaultMemberRole;

public record VaultMemberRoleRequest(
    VaultMemberRole role
) {}