-- =============================================================================
-- V55__create_collaboration_enums.sql
--
-- Enum types for collaborative vault features
--
-- Do not drop but can alter
-- =============================================================================

-- Vault member's roles (Do't include OWNER - implicit through vault owner_id)
CREATE TYPE vault_member_role_enum AS ENUM (
    'EDITOR',
    'VIEWER'
);


-- Vault invitation life cycle
CREATE TYPE invitation_status_enum AS ENUM (
    'PENDING',
    'ACCEPTED',
    'DECLINED',
    'CANCELLED',
    'EXPIRED'
);


-- Notification event types
CREATE TYPE notification_type_enum AS ENUM (
    'VAULT_INVITE',
    'INVITATION_ACCEPTED',
    'INVITATION_DECLINED',
    'MEMBER_REMOVED',
    'ROLE_CHANGED',
    'RECIPE_ADDED',
    'RECIPE_EDITED',
    'RECIPE_REMOVED',
    'FOLDER_CREATED',
    'RECIPE_LOCK_STOLEN'
);