package com.mealchemy.vault.model;

/* Import libraries */

import jakarta.persistence.*;
import java.util.*;
import java.time.OffsetDateTime;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.mealchemy.shared.enums.NotificationType;

/* Import classes */

import com.mealchemy.auth.model.User;

@Entity
@Table(name = "notifications")
public class Notification {
    /* Declaring fields */

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Integer notificationId;

    @ManyToOne
    @JoinColumn(name = "recipient_user_id", nullable = false) 
    private User recipientUser;
    
    @ManyToOne
    @JoinColumn(name = "actor_user_id") // some events may not have an explicit actor
    private User actor;

    @Enumerated(EnumType.STRING)
    @Column(name = "notification_type", nullable = false)
    private NotificationType type;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    @Column(name = "message")
    private String message;

    @Column(name = "ref_vault_id")
    private Integer refVaultId;

    @Column(name = "ref_recipe_id")
    private Integer refRecipeId;

    @Column(name = "ref_invitation_id")
    private Integer refInvitationId;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;


    /* Getters */

    public Integer getNotificationId()
    {
        return notificationId;
    }

    public User getRecipientUser()
    {
        return recipientUser;
    }

    public User getActor()
    {
        return actor;
    }

    public NotificationType getType()
    {
        return type;
    }

    public Boolean getIsRead()
    {
        return isRead;
    }

    public String getMessage()
    {
        return message;
    }

    public Integer getRefVaultId()
    {
        return refVaultId;
    }

    public Integer getRefRecipeId()
    {
        return refRecipeId;
    }

    public Integer getRefInvitationId()
    {
        return refInvitationId;
    }

    public OffsetDateTime getCreatedAt()
    {
        return createdAt;
    }


    /* Setters */

    public void setNotificationId(Integer notificationId)
    {
        this.notificationId = notificationId;
    }

    public void setRecipientUser(User recipientUser)
    {
        this.recipientUser = recipientUser;
    }

    public void setActor(User actor)
    {
        this.actor = actor;
    }

    public void setType(NotificationType type)
    {
        this.type = type;
    }

    public void setIsRead(Boolean isRead)
    {
        this.isRead = isRead;
    }

    public void setMessage(String message)
    {
        this.message = message;
    }

    public void setRefVaultId(Integer refVaultId)
    {
        this.refVaultId = refVaultId;
    }

    public void setRefRecipeId(Integer refRecipeId)
    {
        this.refRecipeId = refRecipeId;
    }

    public void setRefInvitationId(Integer refInvitationId)
    {
        this.refInvitationId = refInvitationId;
    }
}
