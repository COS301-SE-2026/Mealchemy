-- =============================================================================
-- V12__create_ingredient_catalogue.sql
--
-- Each row is an ingredient from the USDA api - preload N number of most popular ingredients
-- =============================================================================

CREATE TABLE ingredient_catalogue (
    ing_id          SERIAL          PRIMARY KEY,
    category_id     INT             NOT NULL REFERENCES ingredient_categories(category_id) ON DELETE CASCADE,
    name            VARCHAR(200)    NOT NULL UNIQUE,
    calories_kcal   SMALLINT        NOT NULL,
    protein_g       DECIMAL(6,2)    NOT NULL,
    carbs_g         DECIMAL(6,2)    NOT NULL,
    fat_g           DECIMAL(6,2)    NOT NULL,
    fibre_g         DECIMAL(6,2),
    sodium_mg       DECIMAL(6,2),
    source_api      VARCHAR(40),
    source_id       VARCHAR(100),
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  ingredient_catalogue                 IS 'One row is an ingredient from the USDA api';
COMMENT ON COLUMN ingredient_catalogue.calories_kcal   IS 'Calories of that ingredient per 100g.';
COMMENT ON COLUMN ingredient_catalogue.protein_g       IS 'Protien of that ingredient per 100g.';
COMMENT ON COLUMN ingredient_catalogue.carbs_g         IS 'Carbs of that ingredient per 100g.';
COMMENT ON COLUMN ingredient_catalogue.fat_g           IS 'Fat of that ingredient per 100g.';
COMMENT ON COLUMN ingredient_catalogue.fibre_g         IS 'Fibre of that ingredient per 100g.';
COMMENT ON COLUMN ingredient_catalogue.sodium_mg       IS 'Sodium of that ingredient per 100g.';
COMMENT ON COLUMN ingredient_catalogue.source_api      IS 'url link of the api the ingredient is from.';
COMMENT ON COLUMN ingredient_catalogue.source_id       IS 'external api id for re-syncing.';