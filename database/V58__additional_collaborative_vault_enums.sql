-- =============================================================================
-- V58__additional_collaborative_vault_enums.sql
--
-- Notification event types updated
--
-- Do not drop but can alter
-- =============================================================================

ALTER TYPE notification_type_enum ADD VALUE 'INVITATION_CANCELLED' AFTER 'INVITATION_DECLINED';

ALTER TYPE notification_type_enum ADD VALUE 'MEMBER_ADDED' BEFORE 'MEMBER_REMOVED';

ALTER TYPE notification_type_enum ADD VALUE 'FOLDER_DELETED' AFTER 'FOLDER_CREATED';

ALTER TYPE notification_type_enum RENAME VALUE 'RECIPE_LOCK_STOLEN' TO 'LOCK_RELEASED';

ALTER TYPE notification_type_enum ADD VALUE 'LOCK_ACQUIRED' BEFORE 'LOCK_RELEASED';