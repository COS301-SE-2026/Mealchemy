package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.vault.model.VaultMember;
import com.mealchemy.vault.model.Vault;
import com.mealchemy.auth.model.User;

import com.mealchemy.shared.enums.VaultMemberRole;

public record VaultMemberResponse(
    Integer id,
    Integer vaultId,
    Integer userId,
    OffsetDateTime joinedAt,
    VaultMemberRole role
)
{
    public static VaultMemberResponse from (VaultMember vaultMember)
    {
        return new VaultMemberResponse(
            vaultMember.getId(),
            vaultMember.getVault().getVaultId(),
            vaultMember.getUser().getUserId(),
            vaultMember.getJoinedAt(),
            vaultMember.getRole()
        );
    }

    // for OWNER because OWNER doesn't have explicit Enum
    public static VaultMemberResponse forOwner (Vault vault, User owner)
    {
        return new VaultMemberResponse(
            null,
            vault.getVaultId(),
            owner.getUserId(),
            vault.getCreatedAt(), // owner joined vault upon creation
            VaultMemberRole.OWNER
        );
    }
}