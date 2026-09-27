package com.mealchemy.shared.enums;

public enum NotificationType {
    // invitations - inbox
    VAULT_INVITE,
    INVITATION_ACCEPTED,
    INVITATION_DECLINED,
    INVITATION_CANCELLED,

    // vault membership - inbox
    MEMBER_REMOVED,
    ROLE_CHANGED,
    RECIPE_ADDED,
    RECIPE_EDITED,
    RECIPE_REMOVED,
    FOLDER_CREATED,
    FOLDER_DELETED,

    // recipe edit locks - live-only
    LOCK_ACQUIRED,
    LOCK_RELEASED
}