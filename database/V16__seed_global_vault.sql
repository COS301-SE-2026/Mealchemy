-- =============================================================================
-- V16__seed_global_vault.sql
--
-- Seeds the single global vault used by the community discovery page
--
-- The global vault:
--   1. Has no owner (owner_id = NULL)
--   2. Is of type 'global'
--   3. Must only ever be one instance (Singleton)
--
-- Created at database setup and never deleted.
-- =============================================================================

INSERT INTO vaults (owner_id, vault_type, name)
VALUES (NULL, 'global', 'Global');