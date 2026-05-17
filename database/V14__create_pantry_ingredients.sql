-- =============================================================================
-- V14__create_pantry_ingredients.sql

-- Each row is one ingredient a user has manually added to their pantry
-- price_paid: stored in ZAR cents as INTEGER to avoid floating-point errors (R19.99 is stored as 1999.)
--
-- potentially add expiry date
-- =============================================================================

CREATE TABLE pantry_ingredients (
    p_ingredient_id            SERIAL              PRIMARY KEY,
    user_id                    INT                 NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    name                       VARCHAR(200)        NOT NULL,
    category                   pantry_category_enum,
    quantity                   DECIMAL(10,3),
    unit                       VARCHAR(30),
    is_out_of_stock            BOOLEAN             NOT NULL DEFAULT FALSE,
    
    price_paid_zar_cents      INTEGER, -- Stored in ZAR cents. R19.99 = 1999.

    created_at                 TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at                 TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

-- Index for fast retrieval of all pantry items for a given user.
CREATE INDEX idx_pantry_ingredients_user_id ON pantry_ingredients(user_id);

COMMENT ON TABLE  pantry_ingredients                           IS 'Ingredients manually added to a user pantry.';
COMMENT ON COLUMN pantry_ingredients.name                      IS 'Ingredient name as entered by the user.';
COMMENT ON COLUMN pantry_ingredients.unit                      IS 'eg.) g, ml, units, tbsp. Null if not specified.';
COMMENT ON COLUMN pantry_ingredients.is_out_of_stock           IS 'True when the user marks an item as depleted. Default false.';
COMMENT ON COLUMN pantry_ingredients.price_paid_zar_cents      IS 'ZAR cents. R19.99 stored as 1999. Rename to price_paid_zar_cents before production.';
COMMENT ON COLUMN pantry_ingredients.updated_at                IS 'Updated when user makes a pantry update.';