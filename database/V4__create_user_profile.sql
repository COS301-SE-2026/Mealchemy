-- =============================================================================
-- V4__create_user_profile.sql
--
-- User settings - display name, profile picture. Updated when user edits their profile
-- One row per user
-- Created at registration
-- =============================================================================

CREATE TABLE user_profile (
    profile_id      SERIAL              PRIMARY KEY,
    user_id         INT                 NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE, -- ON DELETE CASCADE: removing a user removes their profile. Unique - enforces 1:1
    display_name    VARCHAR(80),
    avatar_url      TEXT,
    preferred_unit  preferred_unit_enum NOT NULL DEFAULT 'metric',
    equipment       JSONB               NOT NULL DEFAULT '[]'::jsonb, -- Array of available cooking appliances that user has. eg) ["oven", "airfryer", "blender", "stovetop"]
    updated_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    -- Nice to have fields - not active for demo 1
    font_size           SMALLINT,   -- accessibility: text size preference
    text_to_speech_rate SMALLINT    -- voice cooking: speech rate (words per minute)
);

COMMENT ON TABLE  user_profile                      IS 'One user per row. User settings - display name, profile picture. Created when user registers, updated when user edits their profile.';
COMMENT ON COLUMN user_profile.user_id              IS 'UNIQUE constraint enforces the one-to-one relationship with users.';
COMMENT ON COLUMN user_profile.avatar_url           IS 'URL to Firebase Storage object. Null until the user uploads a photo.';
COMMENT ON COLUMN user_profile.equipment            IS 'jsonb array of users available cooking appliances, e.g. ["oven", "airfryer"].';
COMMENT ON COLUMN user_profile.updated_at           IS 'Updated when user edits profile';
COMMENT ON COLUMN user_profile.font_size            IS 'Not active for demo 1. accessibility feature.';
COMMENT ON COLUMN user_profile.text_to_speech_rate  IS 'Not active for demo 1. voice-controlled cooking feature.';