-- =============================================================================
-- V47__alter_tables_for_engine.sql
--
-- alter the tables as necessary for the recommendation engine to function correctly
-- =============================================================================

-- add storage_location on pantry ingredients

CREATE TYPE storage_location_enum AS ENUM ('PANTRY', 'FRIDGE');

ALTER TABLE pantry_ingredients ADD COLUMN storage_location storage_location_enum;

COMMENT ON COLUMN pantry_ingredients.storage_location IS 'Selects which shelf life column applies from ingredient_categories. Uses COALESCE(fridge_shelf_life_days, pantry_shelf_life_days) as fallsback if NULL.';

-- adding is_dietary boolean on dietary_restrictions

ALTER TABLE tags ADD COLUMN is_dietary BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE tags SET is_dietary = TRUE WHERE tag_name IN (
    'VEGETARIAN','VEGAN','PESCATARIAN','HALAL','KOSHER','GLUTEN_FREE',
    'DAIRY_FREE','KETO','PALEO','NUT_FREE','DIABETIC'
);

UPDATE tags SET tag_name = 'DIABETES_Friendly' WHERE tag_name = 'DIABETIC';

-- normalize cuisine_type in recipes table to uppercase

UPDATE recipes SET cuisine_type = UPPER(cuisine_type) WHERE cuisine_type IS NOT NULL;

ALTER TABLE recipes
    ADD CONSTRAINT recipes_cuisine_type_fk
    FOREIGN KEY (cuisine_type) REFERENCES flavour_profile_options(value);

ALTER TABLE user_cuisine_affinities
    ADD CONSTRAINT user_cuisine_affinities_cuisine_fk
    FOREIGN KEY (cuisine_value) REFERENCES flavour_profile_options(value);