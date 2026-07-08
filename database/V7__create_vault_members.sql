-- =============================================================================
-- V7__create_vault_members.sql
--
-- Tracks which users have access to a shared vault.
-- Not implemented for demo 1 - but to avoid structure changes
-- =============================================================================

CREATE TABLE vault_members (
    id          SERIAL      PRIMARY KEY,
    vault_id    INT         NOT NULL REFERENCES vaults(vault_id) ON DELETE CASCADE,
    user_id     INT         NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    joined_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- A user can only be a member of a given vault once.
    CONSTRAINT vault_members_unique UNIQUE (vault_id, user_id)
);

COMMENT ON TABLE vault_members IS 'Members of shared vaults. Not active for demo 1.';