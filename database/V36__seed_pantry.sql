-- =============================================================================
-- V36__seed_pantry.sql
--
-- Seeds the admin's pantry
--
-- Where an ingredient appears in more than one recipe, quantities are combined.
-- =============================================================================

WITH admin_user AS (
    SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'
)
INSERT INTO pantry_ingredients (user_id, ing_id, quantity, unit)
-- Proteins
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Chicken, breast, boneless, skinless, raw'),       680,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Fish, salmon, Atlantic, farmed, raw'),                       600,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Eggs, Grade A, Large, egg white'),                           4,     NULL     FROM admin_user UNION ALL
-- Dairy
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cream, fluid, heavy whipping'),                             120,   'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cheese, mozzarella, whole milk'),                           150,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cheese, parmesan, hard'),                                   50,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cream, sour, reduced fat, cultured'),                       100,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Butter, salted'),                                           100,   'g'      FROM admin_user UNION ALL
-- Vegetables
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Broccoli, raw'),                                            2,     'heads'  FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomatoes, grape, raw'),                                     450,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, red, raw'),                                         2,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, yellow, raw'),                                      1,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Garlic, raw'),                                              10,    'cloves' FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, spring or scallions (includes tops and bulb), raw'),4,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Peppers, sweet, red, raw'),                                 2,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Peppers, sweet, yellow, raw'),                              1,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Squash, summer, zucchini, includes skin, raw'),             2,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Avocados, raw, all commercial varieties'),                  2,     NULL     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Corn, sweet, yellow, raw'),                                 300,   'g'      FROM admin_user UNION ALL
-- Grains & Legumes
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Rice, brown, long-grain, cooked (Includes foods for USDA''s Food Distribution Program)'), 740, 'g' FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Pasta, cooked, enriched, without added salt'),             450,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Beans, black, mature seeds, cooked, boiled, without salt'), 400,  'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cornstarch'),                                               60,    'g'      FROM admin_user UNION ALL
-- Oils & Condiments
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, olive, salad or cooking'),                            200,   'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, sesame, salad or cooking'),                           50,    'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Honey'),                                                    60,    'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Soy sauce made from soy (tamari)'),                        100,   'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Sauce, hot chile, sriracha'),                               60,    'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Vinegar, balsamic'),                                        50,    'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Vinegar, red wine'),                                        30,    'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomato products, canned, paste, without salt added (Includes foods for USDA''s Food Distribution Program)'), 170, 'g' FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomatoes, canned, red, ripe, diced'),                      400,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Alcoholic beverage, distilled, vodka, 80 proof'),          200,   'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Lemon juice, raw'),                                         60,    'ml'     FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Lime juice, raw'),                                          30,    'ml'     FROM admin_user UNION ALL
-- Herbs & Spices
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Salt, table'),                                              200,   'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, pepper, black'),                                    50,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, cumin seed'),                                       30,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, paprika'),                                          30,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, garlic powder'),                                    20,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, oregano, dried'),                                   15,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, thyme, dried'),                                     15,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, pepper, red or cayenne'),                           10,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Basil, fresh'),                                             40,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Parsley, fresh'),                                           20,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Coriander (cilantro) leaves, raw'),                        15,    'g'      FROM admin_user UNION ALL
SELECT user_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Seeds, sesame seeds, whole, dried'),                        30,    'g'      FROM admin_user;