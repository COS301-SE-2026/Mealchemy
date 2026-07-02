-- =============================================================================
-- V19__create_flagged_recipes.sql
-- 
-- This table holds all the recipes that have been reported by users from the global vault - where recipes violate community guidelines such as inappropriate language
-- Admins will review flagged recipes and decide whether or not to remove them
-- One row per report - a recipe can be reported by multiple users
-- =============================================================================

CREATE TABLE flagged_recipes (
    flagged_id          SERIAL              PRIMARY KEY,
    recipe_id           INT                 NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    flagged_by_user_id  INT                 NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    reason              TEXT,
    status              flagged_status_enum NOT NULL DEFAULT 'PENDING',
    flagged_at          TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_flagged_recipe_id ON flagged_recipes(recipe_id);

COMMENT ON TABLE flagged_recipes                    IS 'Shows the recipes that have been flagged by a user as a violation of community guideline in the global repository.';
COMMENT ON COLUMN flagged_recipes.recipe_id         IS 'The recipe being flagged.';
COMMENT ON COLUMN flagged_recipes.flagged_by_user   IS 'Which user flagged the recipe.';
COMMENT ON COLUMN flagged_recipes.reason            IS 'Why the user flagged the recipe eg.) Inappropriate language.';
COMMENT ON COLUMN flagged_recipes.status            IS 'pending, reviewed, removed.';