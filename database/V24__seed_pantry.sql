-- =============================================================================
-- V24__seed_pantry.sql
--
-- Seeds the admin's pantry
--
-- Where an ingredient appears in more than one recipe, quantities are combined.
-- price_paid_zar_cents is NULL for all seeded items
-- =============================================================================

WITH admin_user AS (
    SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'
)

INSERT INTO pantry_ingredients (user_id, name, category, quantity, unit, is_out_of_stock, price_paid_zar_cents)
SELECT user_id, 'Chicken breasts',               'meat',                 680,    'g',         FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Eggs',                          'dairy',                4,      NULL,       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Heavy cream',                   'dairy',                120,    'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Mini mozzarella balls',         'dairy',                150,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Pecorino cheese',               'dairy',                50,     'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Parmesan cheese',               'dairy',                NULL,   NULL,       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Broccoli',                      'produce',              2,      'heads',    FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Scallions',                     'produce',              4,      NULL,       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Cherry tomatoes',               'produce',              450,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Red onion',                     'produce',              65,     'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Yellow onion',                  'produce',              1,      NULL,       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Garlic',                        'produce',              5,      'cloves',   FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Fresh lemon juice',             'produce',              30,     'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Fresh basil',                   'produce',              40,     'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Fresh parsley',                 'produce',              NULL,   NULL,       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Cooked brown rice',             'grains',               740,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Cavatappi pasta',               'grains',               225,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Penne',                         'grains',               450,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Tomato paste',                  'canned_and_jarred',    170,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Whole peeled tomatoes',         'canned_and_jarred',    400,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Extra-virgin olive oil',        'condiments_and_oils',  110,    'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Sesame oil',                    'condiments_and_oils',  30,     'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Honey',                         'condiments_and_oils',  60,     'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Sriracha sauce',                'condiments_and_oils',  60,     'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Seasoned rice vinegar',         'condiments_and_oils',  10,     'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Balsamic vinegar',              'condiments_and_oils',  15,     'ml',       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Kosher salt',                   'spices',               12,     'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Sea salt',                      'spices',               7.5,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Black pepper',                  'spices',               NULL,   NULL,       FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Red pepper flakes',             'spices',               2.5,    'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Black and white sesame seeds',  'nuts_and_seeds',       10,     'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Corn starch',                   'baking_supplies',      60,     'g',        FALSE, NULL FROM admin_user UNION ALL
SELECT user_id, 'Vodka',                         'beverages',            60,     'ml',       FALSE, NULL FROM admin_user;