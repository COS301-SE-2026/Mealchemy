-- =============================================================================
-- V25__uppercase_enum_values.sql
--
-- changing enum vaules to uppercase to match java enum declarations
-- =============================================================================

-- preferred_unit_enum
ALTER TYPE preferred_unit_enum RENAME VALUE 'metric'   TO 'METRIC';
ALTER TYPE preferred_unit_enum RENAME VALUE 'imperial'  TO 'IMPERIAL';

-- vault_type_enum
ALTER TYPE vault_type_enum RENAME VALUE 'private' TO 'PRIVATE';
ALTER TYPE vault_type_enum RENAME VALUE 'shared'  TO 'SHARED';
ALTER TYPE vault_type_enum RENAME VALUE 'global'  TO 'GLOBAL';

-- pantry_category_enum
ALTER TYPE pantry_category_enum RENAME VALUE 'produce'             TO 'PRODUCE';
ALTER TYPE pantry_category_enum RENAME VALUE 'dairy'               TO 'DAIRY';
ALTER TYPE pantry_category_enum RENAME VALUE 'dairy_alternatives'  TO 'DAIRY_ALTERNATIVES';
ALTER TYPE pantry_category_enum RENAME VALUE 'meat'                TO 'MEAT';
ALTER TYPE pantry_category_enum RENAME VALUE 'poultry'             TO 'POULTRY';
ALTER TYPE pantry_category_enum RENAME VALUE 'seafood'             TO 'SEAFOOD';
ALTER TYPE pantry_category_enum RENAME VALUE 'grains'              TO 'GRAINS';
ALTER TYPE pantry_category_enum RENAME VALUE 'legumes'             TO 'LEGUMES';
ALTER TYPE pantry_category_enum RENAME VALUE 'spices'              TO 'SPICES';
ALTER TYPE pantry_category_enum RENAME VALUE 'condiments_and_oils' TO 'CONDIMENTS_AND_OILS';
ALTER TYPE pantry_category_enum RENAME VALUE 'canned_and_jarred'   TO 'CANNED_AND_JARRED';
ALTER TYPE pantry_category_enum RENAME VALUE 'nuts_and_seeds'      TO 'NUTS_AND_SEEDS';
ALTER TYPE pantry_category_enum RENAME VALUE 'plant_based'         TO 'PLANT_BASED';
ALTER TYPE pantry_category_enum RENAME VALUE 'beverages'           TO 'BEVERAGES';
ALTER TYPE pantry_category_enum RENAME VALUE 'frozen'              TO 'FROZEN';
ALTER TYPE pantry_category_enum RENAME VALUE 'baking_supplies'     TO 'BAKING_SUPPLIES';
ALTER TYPE pantry_category_enum RENAME VALUE 'snacks'              TO 'SNACKS';
ALTER TYPE pantry_category_enum RENAME VALUE 'sweets'              TO 'SWEETS';
ALTER TYPE pantry_category_enum RENAME VALUE 'other'               TO 'OTHER';

-- cuisine_type_enum
ALTER TYPE cuisine_type_enum RENAME VALUE 'african'         TO 'AFRICAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'american'        TO 'AMERICAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'asian'           TO 'ASIAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'caribbean'       TO 'CARIBBEAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'chinese'         TO 'CHINESE';
ALTER TYPE cuisine_type_enum RENAME VALUE 'french'          TO 'FRENCH';
ALTER TYPE cuisine_type_enum RENAME VALUE 'greek'           TO 'GREEK';
ALTER TYPE cuisine_type_enum RENAME VALUE 'indian'          TO 'INDIAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'italian'         TO 'ITALIAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'japanese'        TO 'JAPANESE';
ALTER TYPE cuisine_type_enum RENAME VALUE 'mediterranean'   TO 'MEDITERRANEAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'mexican'         TO 'MEXICAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'southeast_asian' TO 'SOUTHEAST_ASIAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'middle_eastern'  TO 'MIDDLE_EASTERN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'south_african'   TO 'SOUTH_AFRICAN';
ALTER TYPE cuisine_type_enum RENAME VALUE 'thai'            TO 'THAI';
ALTER TYPE cuisine_type_enum RENAME VALUE 'other'           TO 'OTHER';