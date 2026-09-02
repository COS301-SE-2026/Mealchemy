-- V48__alter_user_preference_weights.sql
--
-- alter the tables to add state_version column
-- =============================================================================

ALTER TABLE user_preference_weights
    ADD COLUMN state_version INTEGER NOT NULL DEFAULT 0;

COMMENT ON COLUMN user_preference_weights.state_version IS 'Optimistic-lock guard for the learning loop. Anchors the version for BOTH user_preference_weights and this user''s user_cuisine_affinities rows; the backend updates both inside one transaction guarded by this column.';