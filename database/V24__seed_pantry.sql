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
SELECT user_id, 'Chicken breasts',               'meat'::pantry_category_enum,                 680,    'g',         FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Eggs',                          'dairy'::pantry_category_enum,                4,      NULL,       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Heavy cream',                   'dairy'::pantry_category_enum,                120,    'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Mini mozzarella balls',         'dairy'::pantry_category_enum,                150,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Pecorino cheese',               'dairy'::pantry_category_enum,                50,     'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Parmesan cheese',               'dairy'::pantry_category_enum,                NULL,   NULL,       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Broccoli',                      'produce'::pantry_category_enum,              2,      'heads',    FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Scallions',                     'produce'::pantry_category_enum,              4,      NULL,       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Cherry tomatoes',               'produce'::pantry_category_enum,              450,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Red onion',                     'produce'::pantry_category_enum,              65,     'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Yellow onion',                  'produce'::pantry_category_enum,              1,      NULL,       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Garlic',                        'produce'::pantry_category_enum,              5,      'cloves',   FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Fresh lemon juice',             'produce'::pantry_category_enum,              30,     'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Fresh basil',                   'produce'::pantry_category_enum,              40,     'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Fresh parsley',                 'produce'::pantry_category_enum,              NULL,   NULL,       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Cooked brown rice',             'grains'::pantry_category_enum,               740,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Cavatappi pasta',               'grains'::pantry_category_enum,               225,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Penne',                         'grains'::pantry_category_enum,               450,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Tomato paste',                  'canned_and_jarred'::pantry_category_enum,    170,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Whole peeled tomatoes',         'canned_and_jarred'::pantry_category_enum,    400,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Extra-virgin olive oil',        'condiments_and_oils'::pantry_category_enum,  110,    'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Sesame oil',                    'condiments_and_oils'::pantry_category_enum,  30,     'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Honey',                         'condiments_and_oils'::pantry_category_enum,  60,     'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Sriracha sauce',                'condiments_and_oils'::pantry_category_enum,  60,     'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Seasoned rice vinegar',         'condiments_and_oils'::pantry_category_enum,  10,     'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Balsamic vinegar',              'condiments_and_oils'::pantry_category_enum,  15,     'ml',       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Kosher salt',                   'spices'::pantry_category_enum,               12,     'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Sea salt',                      'spices'::pantry_category_enum,               7.5,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Black pepper',                  'spices'::pantry_category_enum,               NULL,   NULL,       FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Red pepper flakes',             'spices'::pantry_category_enum,               2.5,    'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Black and white sesame seeds',  'nuts_and_seeds'::pantry_category_enum,       10,     'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Corn starch',                   'baking_supplies'::pantry_category_enum,      60,     'g',        FALSE, NULL::integer FROM admin_user UNION ALL
SELECT user_id, 'Vodka',                         'beverages'::pantry_category_enum,            60,     'ml',       FALSE, NULL::integer FROM admin_user;