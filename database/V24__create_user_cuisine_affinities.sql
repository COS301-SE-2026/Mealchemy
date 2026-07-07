-- =============================================================================
-- V24__create_user_cuisine_affinities.sql
-- 
-- Per-user, per-cuisine affinity score between 0.0 and 1.0.
-- One row per user per cuisine, seeded at 0.5 (neutral) on registration.
-- Updated by the engine after every LIKED or DISLIKED swipe.
-- Will use EMA to update scores.
-- =============================================================================

CREATE TABLE user_cuisine_affinities (
    affinity_id     SERIAL          PRIMARY KEY,
    user_id         INT             NOT NULL REFERENCES users(user_id)  ON DELETE CASCADE,
    cuisine_value   VARCHAR(50)     NOT NULL,
    affinity_score  DECIMAL(4,3)    DEFAULT 0.500, -- scale from 0 to 1 therefore 5 is neutral
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT user_cuisine_affinities_unique UNIQUE (user_id, cuisine_value)
);

CREATE INDEX idx_user_cuisine_affinities_user_id ON user_cuisine_affinities(user_id);
COMMENT ON TABLE  user_cuisine_affinities                IS 'Per-user per-cuisine affinity score. Drives cuisine signal and Phase 3 slot allocation.';
COMMENT ON COLUMN user_cuisine_affinities.cuisine_value  IS 'References flavour_profile_options.value. eg.) italian, japanese.';