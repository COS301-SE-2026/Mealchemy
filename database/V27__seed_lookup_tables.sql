-- =============================================================================
-- V27__seed_lookup_tables.sql
--
-- Seed all lookup tables used by user preferences and recommendation engine
-- Values served to flutter via GET
--
-- Tables:
-- 1. dietary_rstriction_options - user_preferences.dietary_restrictions
-- 2. allergen_options - most common food allergy options user_preferences.allergies
-- 3. flavour_profile_options - user_preferences.flavour_profile user_cuisine_affinities.cuisine_value
-- 4. tags - recipe_tags and used for recommendation engine phase 1: hard filtering
-- 5. equipment - user_profile.equipment
-- =============================================================================

-- 1. dietary_rstriction_options (written into the user_prefernces.dietary_restrictions array)

INSERT INTO dietary_restriction_options (value, label, description, is_active)
VALUES
    ('VEGETARIAN',              'Vegetarian',          'Excludes meat and seafood, includes dairy and eggs', TRUE),
    ('VEGAN',                   'Vegan',               'Excludes all animal products including dairy and eggs', TRUE),
    ('PESCATARIAN',             'Pescatarian',         'Excludes meat but includes seafood, dairy and eggs', TRUE),
    ('HALAL',                   'Halal',               'Prepared according to Islamic dietary law', TRUE),
    ('KOSHER',                  'Kosher',              'Prepared according to Jewish dietary law', TRUE),
    ('GLUTEN_FREE',             'Gluten Free',         'Excludes wheat, barley, rye and related grains', TRUE),
    ('DAIRY_FREE',              'Dairy Free',          'Excludes all milk-based products', TRUE),
    ('KETO',                    'Keto',                'Very low carbohydrate, high fat diet', TRUE),
    ('PALEO',                   'Paleo',               'Excludes grains, legumes, dairy and processed foods', TRUE),
    ('NUT_FREE',                'Nut Free',            'Excludes all tree nuts and peanuts', TRUE),
    ('DIABETES_Friendly',       'Diabetes-Friendly',   'Low in added sugars and managed refined carbohydrates', TRUE)
ON CONFLICT (value) DO NOTHING;

-- -------------------------------------------------------------------------------------------------------------

-- 2. allergen_options - most common food allergy options user_preferences.allergies (front end will show these as well as allow users to search the ingredient catalogue for more ingredient specific allergies)
-- Phase 1 - hard filtering of recommendation engine

INSERT INTO allergen_options (value, label, description, is_active)
VALUES
    ('PEANUTS',      'Peanuts',      'Includes peanut oil and peanut-derived products', TRUE),
    ('TREE_NUTS',    'Tree Nuts',    'Includes almonds, cashews, walnuts, pecans, pistachios', TRUE),
    ('GLUTEN',       'Gluten',       'Found in wheat, barley, rye and related grains', TRUE),
    ('DAIRY',        'Dairy',        'Includes milk, cheese, butter, yoghurt and cream', TRUE),
    ('EGGS',         'Eggs',         'Includes all egg-based products', TRUE),
    ('SOY',          'Soy',          'Includes soy sauce, tofu, edamame and soy-based products', TRUE),
    ('SHELLFISH',    'Shellfish',    'Includes prawns, crab, lobster and related crustaceans', TRUE),
    ('FISH',         'Fish',         'Includes all finfish species', TRUE),
    ('SESAME',       'Sesame',       'Includes sesame oil and tahini', TRUE),
    ('MUSTARD',      'Mustard',      'Includes mustard seeds, powder and prepared mustard', TRUE),
    ('CELERY',       'Celery',       'Includes celery seeds and celeriac', TRUE),
    ('SULPHITES',    'Sulphites',    'Found in wine, dried fruit and some preserved foods', TRUE),
    ('LUPIN',        'Lupin',        'Found in lupin flour and seeds used in some breads', TRUE),
    ('MOLLUSCS',     'Molluscs',     'Includes squid, mussels, oysters, scallops and clams', TRUE)   
ON CONFLICT (value) DO NOTHING;

-- -------------------------------------------------------------------------------------------------------------

-- 3. flavour_profile_options - written to user_preferences.flavour_profile and used as values in user_cuisine_affinities.cuisine_value
-- Flavour profile options at registration

INSERT INTO flavour_profile_options (value, label)
VALUES
    ('AFRICAN',         'African'),
    ('AMERICAN',        'American'),
    ('ASIAN',           'Asian'),
    ('CARIBBEAN',       'Caribbean'),
    ('CHINESE',         'Chinese'),
    ('FRENCH',          'French'),
    ('GREEK',           'Greek'),
    ('INDIAN',          'Indian'),
    ('ITALIAN',         'Italian'),
    ('JAPANESE',        'Japanese'),
    ('MEDITERRANEAN',   'Mediterranean'),
    ('MEXICAN',         'Mexican'),
    ('MIDDLE_EASTERN',  'Middle Eastern'),
    ('SOUTHEAST_ASIAN', 'Southeast Asian'),
    ('SOUTH_AFRICAN',   'South African'),
    ('THAI',            'Thai'),
    ('OTHER',           'Other')
ON CONFLICT (value) DO NOTHING;

-- -------------------------------------------------------------------------------------------------------------

-- 4. tags - applied to recipes at creation time to enable hard filtering

INSERT INTO tags (tag_name, is_active)
VALUES
    ('VEGETARIAN',  TRUE),
    ('VEGAN',       TRUE),
    ('PESCATARIAN', TRUE),
    ('HALAL',       TRUE),
    ('KOSHER',      TRUE),
    ('GLUTEN_FREE', TRUE),
    ('DAIRY_FREE',  TRUE),
    ('KETO',        TRUE),
    ('PALEO',       TRUE),
    ('NUT_FREE',    TRUE),
    ('DIABETIC',    TRUE),
    ('SPICY',       TRUE),
    ('MEAL_PREP',   TRUE),
    ('QUICK',       TRUE),  -- recipes under 30 mins total
    ('HIGH_PROTEIN',TRUE),
    ('LOW_CARB',    TRUE),
    ('COMFORT_FOOD',TRUE)
ON CONFLICT (tag_name) DO NOTHING;

--------------------------------------------------------------------------------------------------------------

-- 5. equipment_options - equipment users may have available to them in order to cook.

INSERT INTO equipment_options (value, label)
VALUES
    ('OVEN', 'Oven'),
    ('STOVETOP', 'Stovetop'),
    ('MICROWAVE', 'Microwave'),
    ('TOASTER', 'Toaster'),
    ('AIR_FRYER', 'Air Fryer'),
    ('BLENDER', 'Blender'),
    ('FOOD_PROCESSOR', 'Food Processor'),
    ('HAND_MIXER', 'Hand Mixer'),
    ('STAND_MIXER', 'Stand Mixer'),
    ('SLOW_COOKER', 'Slow Cooker'),
    ('PRESSURE_COOKER', 'Pressure Cooker'),
    ('RICE_COOKER', 'Rice Cooker'),
    ('INSTANT_POT', 'Instant Pot')
ON CONFLICT (value) DO NOTHING;