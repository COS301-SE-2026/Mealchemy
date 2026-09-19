package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.util.*;
import java.time.OffsetDateTime;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.mealchemy.shared.enums.InvitationStatus;

/* Import classes */

import com.mealchemy.auth.model.User;

@Entity
@Table(name = "vault_invitations")
public class VaultInvitation {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "invitation_id")
    private Integer invitationId;

    @ManyToOne
    @JoinColumn(name = "vault_id", nullable = false)
    private Vault vault;
    
    @ManyToOne
    @JoinColumn(name = "invited_user_id", nullable = false)
    private User invitedUser;

    @ManyToOne
    @JoinColumn(name = "invited_by_user_id", nullable = false)
    private User invitedBy;

    @Enumerated(EnumType.STRING)
    @Column(name = "invitation_status", nullable = false)
    private InvitationStatus status = InvitationStatus.PENDING;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "expires_at", nullable = false)
    private OffsetDateTime expiresAt;

    @Column(name = "responded_at")
    private OffsetDateTime respondedAt;


    /* Getters */

    public Integer getInvitationId()
    {
        return invitationId;
    }

    public Vault getVault()
    {
        return vault;
    }

    public User getInvitedUser()
    {
        return invitedUser;
    }

    public User getInvitedByUser()
    {
        return invitedBy;
    }

    public InvitationStatus getStatus()
    {
        return status;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }

    public OffsetDateTime getExpiresAt()
    {
        return expiresAt;
    }

    public OffsetDateTime getRespondedAt()
    {
        return respondedAt;
    }


    /* Setters */

    public void setInvitationId(Integer invitationId)
    {
        this.invitationId = invitationId;
    }

    public void setVault(Vault vault)
    {
        this.vault = vault;
    }

    public void setInvitedUser(User invitedUser)
    {
        this.invitedUser = invitedUser;
    }

    public void setInvitedByUser(User invitedBy)
    {
        this.invitedBy = invitedBy;
    }

    public void setStatus(InvitationStatus status)
    {
        this.status = status;
    }

    public void setExpiresAt(OffsetDateTime expiresAt)
    {
        this.expiresAt = expiresAt;
    }

    public void setRespondedAt(OffsetDateTime respondedAt)
    {
        this.respondedAt = respondedAt;
    }

}
