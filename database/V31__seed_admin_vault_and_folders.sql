-- =============================================================================
-- V31__seed_admin_vault_and_folders.sql
--
-- Creates the admin's private vault and a General folder inside it
-- All 5 mock recipes will be placed in the General folder
-- =============================================================================

WITH private_vault AS (
    INSERT INTO vaults (owner_id, vault_type, name)
    VALUES (
        (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
        'PRIVATE'::vault_type_enum,
        'My Vault'
    )
    RETURNING vault_id
)
INSERT INTO vault_folders (vault_id, name)
SELECT vault_id, 'General'
FROM private_vault;