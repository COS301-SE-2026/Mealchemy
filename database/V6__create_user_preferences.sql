-- =============================================================================
-- V6__create_user_preferences.sql
--
-- Food-related preferences collected on the onboarding preferences page
-- One row per user (enforced by UNIQUE on user_id)
-- Updated when a user edits their preferences settings
--
-- Potential design change later
-- =============================================================================

CREATE TABLE user_preferences (
    preference_id           SERIAL      PRIMARY KEY,
    user_id                 INT         NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,-- ON DELETE CASCADE: removing a user removes their preferences.

    -- jsonb arrays - defaults to empty array on creation.
    dietary_restrictions    JSONB       NOT NULL DEFAULT '[]'::jsonb, -- eg.) ["vegetarian", "halal", "diabetic"]
    allergies               JSONB       NOT NULL DEFAULT '[]'::jsonb, -- eg.) ["peanuts", "gluten"]
    disliked_ingredients    JSONB       NOT NULL DEFAULT '[]'::jsonb, -- eg.) ["olives", "anchovies"]
    flavour_profile         JSONB       NOT NULL DEFAULT '[]'::jsonb, -- eg.) ["Mediterranean", "Chinese"]

    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  user_preferences                       IS 'Food preferences from the onboarding page. One row per user.';
COMMENT ON COLUMN user_preferences.user_id               IS 'UNIQUE constraint enforces the one-to-one relationship with users.';
COMMENT ON COLUMN user_preferences.dietary_restrictions  IS 'jsonb array. eg.) ["vegetarian", "halal", "diabetic"].';
COMMENT ON COLUMN user_preferences.allergies             IS 'jsonb array. eg.) ["peanuts", "gluten"].';
COMMENT ON COLUMN user_preferences.disliked_ingredients  IS 'jsonb array. eg.) ["olives", "anchovies"].';
COMMENT ON COLUMN user_preferences.flavour_profile       IS 'jsonb array of cuisine style preferences. e.g. ["Mediterranean", "Chinese"].';
COMMENT ON COLUMN user_preferences.updated_at            IS 'Updated when user edits their preferences.';