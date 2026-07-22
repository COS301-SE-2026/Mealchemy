-- =============================================================================
-- V6__create_vaults.sql
--
-- Top-level container for recipe folders.
-- Each user gets one private vault created automatically at registration (Springboot registration service)
-- One global - discovery/community page
-- =============================================================================

CREATE TABLE vaults (
    vault_id    SERIAL          PRIMARY KEY,

    -- Null for the global vault (it has no individual owner).
    -- Private and shared vaults always reference a user.
    owner_id    INT             REFERENCES users(user_id) ON DELETE CASCADE,

    vault_type  vault_type_enum NOT NULL,
    name        VARCHAR(100)    NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  vaults            IS 'Top-level recipe container.';
COMMENT ON COLUMN vaults.owner_id   IS 'Null for the global vault. Private and shared vaults always have an owner.';
COMMENT ON COLUMN vaults.vault_type IS 'private, shared, global - only private active for demo 1.';