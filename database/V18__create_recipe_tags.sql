-- =============================================================================
-- V18__create_recipe_tags.sql
-- 
-- Links tags to recipes - allows multiple tags to be allocated to one recipe
-- Tags are assign at recipe creation by user
-- Used in phase one (hard filtering) of the recommendation engine
-- =============================================================================

CREATE TABLE recipe_tags (
    id          SERIAL  PRIMARY KEY,
    recipe_id   INT     NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    tag_id      INT     NOT NULL REFERENCES tags(tag_id),

    CONSTRAINT recipe_tags_unique UNIQUE (recipe_id, tag_id)
);

CREATE INDEX idx_recipe_tags_recipe_id  ON recipe_tags(recipe_id);
CREATE INDEX idx_recipe_tags_tag_id ON recipe_tags(tag_id);

COMMENT ON TABLE recipe_tags IS 'Links recipes to dietary tags - used in recommendation hard filtering.';