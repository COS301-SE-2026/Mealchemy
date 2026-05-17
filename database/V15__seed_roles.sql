-- =============================================================================
-- V15__seed_roles.sql
-- Seeds the two required roles: 'user' (default) and 'admin'.
--
-- Replace with a proper admin assignment flow later on. (Manage roles without direct database access)
-- =============================================================================

INSERT INTO roles (role_name, permissions)
VALUES
    (
        'user',
        '{"can_upload_recipes": true, "can_manage_own_pantry": true, "can_manage_own_profile": true, "can_publish_to_community": false}'::jsonb
    ),
    (
        'admin',
        '{"can_upload_recipes": true, "can_manage_own_pantry": true, "can_manage_own_profile": true, "can_publish_to_community": true, "can_delete_community_recipes": true, "can_manage_users": true}'::jsonb
    );