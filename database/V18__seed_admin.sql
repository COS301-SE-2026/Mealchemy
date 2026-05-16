-- =============================================================================
-- V18__seed_admin.sql
--
-- Seeds the default admin account
-- Only the admin is seeded - other users will register through app (so passwords are correctly salted and hashed)
--
-- Hash generated with BCrypt cost factor 12.
-- Change password after registration is up and running
-- =============================================================================

WITH inserted_user AS (
    INSERT INTO users (email, password_hash, role_id)
    VALUES (
        'admin@mealchemy.com',
        '$2b$12$FCqc84bIoMfMKxomm9E66OVKA.VPdvbQm6QwJc3k5G1.JQ6GNlE5m',
        (SELECT role_id FROM roles WHERE role_name = 'admin')
    )
    RETURNING user_id
),
inserted_profile AS (
    INSERT INTO user_profile (user_id, display_name, preferred_unit, equipment)
    SELECT
        user_id,
        'Admin',
        'metric',
        '["oven", "airfryer", "blender"]'::jsonb
    FROM inserted_user
    RETURNING user_id
)
INSERT INTO user_preferences (user_id, dietary_restrictions, allergies, disliked_ingredients, flavour_profile)
SELECT
    user_id,
    '[]'::jsonb,
    '[]'::jsonb,
    '[]'::jsonb,
    '["italian", "asian", "mediterranean", "mexican"]'::jsonb
FROM inserted_user;