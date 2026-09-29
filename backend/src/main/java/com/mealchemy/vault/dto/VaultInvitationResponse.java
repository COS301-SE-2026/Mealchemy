package com.mealchemy.vault.dto;

/* Import libraries */

import java.time.OffsetDateTime;

/* Import classes */

import com.mealchemy.vault.model.VaultInvitation;
import com.mealchemy.shared.enums.InvitationStatus;

public record VaultInvitationResponse(
    Integer invitationId,
    Integer vaultId,
    String vaultName,
    String invitedEmail,
    String invitedByEmail,
    InvitationStatus status,
    OffsetDateTime createdAt,
    OffsetDateTime expiresAt,
    OffsetDateTime respondedAt
)

{
    public static VaultInvitationResponse from(VaultInvitation invitation)
    {
        return new VaultInvitationResponse(
            invitation.getInvitationId(),
            invitation.getVault().getVaultId(),
            invitation.getVault().getName(),
            invitation.getInvitedUser().getEmail(),
            invitation.getInvitedByUser().getEmail(),
            invitation.getStatus(),
            invitation.getCreatedAt(),
            invitation.getExpiresAt(),
            invitation.getRespondedAt()
        );
    }
}