-- =============================================================================
-- V14__create_pantry_ingredients.sql

-- Each row is one ingredient a user has manually added to their pantry
--
-- Freshness will be calculated using an estimated shelf life per ingredient category and the date it was added to the pantry. 
-- =============================================================================

CREATE TABLE pantry_ingredients (
    p_ingredient_id     SERIAL           PRIMARY KEY,
    user_id             INT              NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    ing_id              INT              NOT NULL REFERENCES ingredient_catalogue(ing_id),
    quantity            DECIMAL(10,3)    NOT NULL,
    unit                VARCHAR(30),
    created_at          TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- Index for fast retrieval of all pantry items for a given user.
CREATE INDEX idx_pantry_ingredients_user_id ON pantry_ingredients(user_id);

COMMENT ON TABLE  pantry_ingredients                           IS 'Ingredients manually added to a user pantry.';
COMMENT ON COLUMN pantry_ingredients.unit                      IS 'eg.) g, ml, units, tbsp. Null if not specified.';
COMMENT ON COLUMN pantry_ingredients.updated_at                IS 'Updated when user makes a pantry update.';