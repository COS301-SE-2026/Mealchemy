package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.vault.model.VaultMember;

public record VaultMemberResponse(
    Integer id,
    Integer vaultId,
    Integer userId,
    OffsetDateTime joinedAt
)
{
    public static VaultMemberResponse from (VaultMember vaultMember)
    {
        return new VaultMemberResponse(
            vaultMember.getId(),
            vaultMember.getVault().getVaultId(),
            vaultMember.getUser().getUserId(),
            vaultMember.getJoinedAt()
        );
    }
}