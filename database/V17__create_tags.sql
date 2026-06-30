-- =============================================================================
-- V16__create_preference_lookup_tables.sql
-- 
-- Served to Flutter via GET /api/preferences/options
-- Lookup tables for USER_PREFERENCES jsonb arrays.
-- value field is what gets written into the user's jsonb arrays
-- label field is display-only for the Flutter UI
-- =============================================================================

CREATE TABLE tags (
    tag_id      SERIAL      PRIMARY KEY,
    tag_name    VARCHAR(50) NOT NULL UNIQUE,
    is_active   BOOLEAN     NOT NULL DEFAULT TRUE
);

