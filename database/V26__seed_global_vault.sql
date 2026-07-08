-- =============================================================================
-- V26__seed_global_vault.sql
--
-- Seeds the single global vault used by the community discovery page
--
-- The global vault:
--   1. Has no owner (owner_id = NULL)
--   2. Is of type 'GLOBAL'
--   3. Must only ever be one instance (Singleton)
--
-- Created at database setup and never deleted.
-- =============================================================================

INSERT INTO vaults (owner_id, vault_type, name)
SELECT NULL, 'GLOBAL'::vault_type_enum, 'Global'
WHERE NOT EXISTS (
    SELECT 1 FROM vaults WHERE vault_type = 'GLOBAL'
);