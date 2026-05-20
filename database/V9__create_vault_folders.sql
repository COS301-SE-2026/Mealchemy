-- =============================================================================
-- V9__create_vault_folders.sql
--
-- Named folders within a vault, created by users with custom names
-- eg.) Breakfast, Lunch, Dinner, Dessert, Birthday, Meal Prep.
-- Each folder belongs to exactly one vault.
-- =============================================================================

CREATE TABLE vault_folders (
    folder_id   SERIAL          PRIMARY KEY,
    vault_id    INT             NOT NULL REFERENCES vaults(vault_id) ON DELETE CASCADE,
    name        VARCHAR(100)    NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- Index for fast lookup of all folders in a vault (used on the vault page load).
CREATE INDEX idx_vault_folders_vault_id ON vault_folders(vault_id);

COMMENT ON TABLE  vault_folders      IS 'User-created named folders within a vault. eg.) Breakfast, Dinner, Meal Prep.';
COMMENT ON COLUMN vault_folders.name IS 'User-defined folder name. No uniqueness constraint - same name allowed in different vaults.';