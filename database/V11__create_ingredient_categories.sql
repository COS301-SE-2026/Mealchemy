-- =============================================================================
-- V11__create_ingredient_categories.sql
--
-- Each row is a category an ingredient must belong to, eg.) dairy, meat, poultry
--
-- =============================================================================

CREATE TABLE ingredient_categories (
    category_id                 SERIAL      PRIMARY KEY,
    name                        VARCHAR(60) NOT NULL UNIQUE, -- eg.) Poultry, Canned Goods
    pantry_shelf_life_days      SMALLINT,
    fridge_shelf_life_days      SMALLINT
);

COMMENT ON TABLE ingredient_categories                            IS 'Each row is a category an ingredient must belong to, eg.) dairy, meat, poultry.';
COMMENT ON COLUMN ingredient_categories.name                      IS 'The name of the category eg.) Poutry, Canned goods.';
COMMENT ON COLUMN ingredient_categories.pantry_shelf_life_days    IS 'The estimated days stored of ingredients that belong to the catory when kept in the pantry.';
COMMENT ON COLUMN ingredient_categories.fridge_shelf_life_days    IS 'The estimated days stored of ingredients that belong to the catory when kept in the fridge.';