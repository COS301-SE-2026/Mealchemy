-- =============================================================================
-- V16__create_preference_lookup_tables.sql
-- 
-- Served to Flutter via GET /api/preferences/options
-- Lookup tables for USER_PREFERENCES jsonb arrays.
-- value field is what gets written into the user's jsonb arrays
-- label field is display-only for the Flutter UI
-- =============================================================================

CREATE TABLE dietary_restriction_options (
    id             SERIAL   PRIMARY KEY,
    value          TEXT     NOT NULL UNIQUE,
    label          TEXT     NOT NULL,
    description    TEXT,
    is_active      BOOLEAN  NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE dietary_restriction_options IS 'valid options for user_preferences.dietary_restrictions jsonb array.';


CREATE TABLE allergen_options (
    id             SERIAL   PRIMARY KEY,
    value          TEXT     NOT NULL UNIQUE,
    label          TEXT     NOT NULL,
    description    TEXT,
    is_active      BOOLEAN  NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE allergen_options IS 'valid options for user_preferences.allergies jsonb array.';


CREATE TABLE flavour_profile_options (
    id            SERIAL   PRIMARY KEY,
    value         TEXT     NOT NULL UNIQUE,
    label         TEXT     NOT NULL
);

CREATE TABLE equipment_options (
    id      SERIAL  PRIMARY KEY,
    value   TEXT    NOT NULL UNIQUE,
    label   TEXT    NOT NULL
);

COMMENT ON TABLE flavour_profile_options IS 'valid options for user_preferences.flavour profile jsonb array and user_cuisine_afinities.cuisine_value.';
COMMENT ON TABLE equipment_options IS 'valid options for equipmnt that users have access to. (Used in recommendation algorithm)'
