-- =============================================================================
-- V13__create_recipe_ingredients.sql
--
-- Each row is one ingredient line in a recipe, eg.) "200g chicken breast"
-- References an ingredient from the ingredient catalogue - where you can find all ingredient information
-- =============================================================================

CREATE TABLE recipe_ingredients (
    ingredient_id   SERIAL          PRIMARY KEY,
    recipe_id       INT             NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    ing_id          INT             NOT NULL REFERENCES ingredient_catalogue(ing_id),
    quantity        DECIMAL(10,3),
    unit            VARCHAR(30),

    -- Controls the display order of ingredients in the recipe view
    -- Frontend must take this into account
    sort_order      SMALLINT        NOT NULL DEFAULT 0
);

-- Index for fast retrieval of all ingredients for a given recipe.
CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);

COMMENT ON TABLE  recipe_ingredients            IS 'One row per ingredient line per recipe. Name is found in ingredient_catalogue';
COMMENT ON COLUMN recipe_ingredients.unit       IS 'eg.) g, ml, cups, tbsp. Null if not specified.';
COMMENT ON COLUMN recipe_ingredients.sort_order IS 'Display order. Frontend must sort by this field when rendering ingredients.';