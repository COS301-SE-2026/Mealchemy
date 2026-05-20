-- =============================================================================
-- V2__create_enums.sql
-- Creating custom enums that will be used in other tables
--
-- Can alter later but never drop
-- =============================================================================

-- Vault types: private (per user), shared (multi-user), global (community/discovery).
CREATE TYPE vault_type_enum AS ENUM (
    'private',
    'shared',
    'global'
);

-- User's preferred unit of measurement
CREATE TYPE preferred_unit_enum AS ENUM (
    'metric',
    'imperial'
);

-- Pantry ingredient categories. Used in pantry_ingredients.category.
CREATE TYPE pantry_category_enum AS ENUM (
    'produce',      -- fresh fruit and vegetables
    'dairy',        -- milk, cheese, yoghurt, eggs
    'dairy_alternatives', -- almond milk, vegan cheese
    'meat',         -- beef, pork, lamb
    'poultry',      -- chicken, turkey
    'seafood',      -- fish, shellfish
    'grains',       -- rice, pasta, bread
    'legumes',      -- beans, lentils, chickpeas
    'spices',       -- herbs, spices, seasonings
    'condiments_and_oils',   -- sauces, oils, vinegars
    'canned_and_jarred', -- pickles, tuna, tomato puree
    'nuts_and_seeds', -- peanuts, chai seeds, flax seeds
    'plant_based',  -- tofu, vegan substitutes
    'beverages',    -- drinks, juices
    'frozen',       -- frozen goods
    'baking_supplies', -- flour, sugar, baking powder, vanilla extract
    'snacks',       -- packaged snack foods
    'sweets',       -- for desserts
    'other'         -- anything not covered above
);

-- Cuisine types used to classify recipes.
CREATE TYPE cuisine_type_enum AS ENUM (
    'african',
    'american',
    'asian',
    'caribbean',
    'chinese',
    'french',
    'greek',
    'indian',
    'italian',
    'japanese',
    'mediterranean',
    'mexican',
    'southeast_asian',
    'middle_eastern',
    'south_african',
    'thai',
    'other'
);