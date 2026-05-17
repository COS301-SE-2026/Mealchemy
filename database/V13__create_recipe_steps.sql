-- =============================================================================
-- V13__create_recipe_steps.sql
-- 
-- Each row is one numbered step in a recipe's method
--
-- Steps are stored as individual rows rather than a single text blob so that:
--   1. The frontend can render a step-by-step view with navigation
--   2. The voice-controlled cooking feature can read each step aloud individually
-- =============================================================================

CREATE TABLE recipe_steps (
    step_id     SERIAL      PRIMARY KEY,
    recipe_id   INT         NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    step_nr     SMALLINT    NOT NULL,
    content     TEXT        NOT NULL,
   
    CONSTRAINT recipe_steps_unique UNIQUE (recipe_id, step_nr) -- Recipe step numbers cannot be repeated
);

-- Index for fast retrieval of all steps for a given recipe.
CREATE INDEX idx_recipe_steps_recipe_id ON recipe_steps(recipe_id);

COMMENT ON TABLE  recipe_steps         IS 'One row per step per recipe. Stored separately to support step-by-step display and voice-controlled cooking.';
COMMENT ON COLUMN recipe_steps.step_nr IS 'Step number within the recipe (1, 2, 3...). Must be unique per recipe.';