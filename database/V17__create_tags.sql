-- =============================================================================
-- V17__create_tags.sql
-- 
-- Lookup table for dietary and lifestyle tags that can be applied to recipes
-- Tags mirror DIETARY_RESTRICTION_OPTIONS values where applicable.
-- =============================================================================

CREATE TABLE tags (
    tag_id      SERIAL      PRIMARY KEY,
    tag_name    VARCHAR(50) NOT NULL UNIQUE,
    is_active   BOOLEAN     NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE tags   IS 'Dietary and lifestyle tags applied to recipes. Used in the hard filter phase of the recommendation engine.';
COMMENT ON COLUMN tags.tag_name     IS 'eg.) vegan, halal, gluten free - Mirrors applicable dietary_restriction_options.value.';
COMMENT ON COLUMN tags.is_active IS 'False - hide a tage without deleting existing recipe_tags rows.';