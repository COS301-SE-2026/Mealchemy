-- =============================================================================
-- V24__seed_pantry.sql
--
-- Seeds the admin's pantry
--
-- Where an ingredient appears in more than one recipe, quantities are combined.
-- price_paid_zar_cents is NULL for all seeded items
-- =============================================================================

INSERT INTO pantry_ingredients (user_id, name, category, quantity, unit, is_out_of_stock, price_paid_zar_cents)
VALUES

-- Proteins
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Chicken breasts',          'meat',                 680,    'g',        FALSE,  NULL
),

-- Dairy & Eggs 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Eggs',                     'dairy',                4,      NULL,       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Heavy cream',              'dairy',                120,    'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Mini mozzarella balls',    'dairy',                150,    'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Pecorino cheese',          'dairy',                50,     'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Parmesan cheese',          'dairy',                NULL,   NULL,       FALSE,  NULL
),

--  Produce
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Broccoli',                 'produce',              2,      'heads',    FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Scallions',                'produce',              4,      NULL,       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Cherry tomatoes',          'produce',              450,    'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Red onion',                'produce',              65,     'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Yellow onion',             'produce',              1,      NULL,       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Garlic',                   'produce',              5,      'cloves',   FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Fresh lemon juice',        'produce',              30,     'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Fresh basil',              'produce',              40,     'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Fresh parsley',            'produce',              NULL,   NULL,       FALSE,  NULL
),

--  Grains 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Cooked brown rice',        'grains',               740,    'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Cavatappi pasta',          'grains',               225,    'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Penne',                    'grains',               450,    'g',        FALSE,  NULL
),

--  Canned & Jarred 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Tomato paste',             'canned_and_jarred',    170,    'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Whole peeled tomatoes',    'canned_and_jarred',    400,    'g',        FALSE,  NULL
),

--  Condiments & Oils
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Extra-virgin olive oil',   'condiments_and_oils',  110,    'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Sesame oil',               'condiments_and_oils',  30,     'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Honey',                    'condiments_and_oils',  60,     'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Sriracha sauce',           'condiments_and_oils',  60,     'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Seasoned rice vinegar',    'condiments_and_oils',  10,     'ml',       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Balsamic vinegar',         'condiments_and_oils',  15,     'ml',       FALSE,  NULL
),

--  Spices 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Kosher salt',              'spices',               12,     'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Sea salt',                 'spices',               7.5,    'g',        FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Black pepper',             'spices',               NULL,   NULL,       FALSE,  NULL
),
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Red pepper flakes',        'spices',               2.5,    'g',        FALSE,  NULL
),

--  Nuts & Seeds 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Black and white sesame seeds', 'nuts_and_seeds',   10,     'g',        FALSE,  NULL
),

--  Baking Supplies 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Corn starch',              'baking_supplies',      60,     'g',        FALSE,  NULL
),

--  Beverages 
(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Vodka',                    'beverages',            60,     'ml',       FALSE,  NULL
);