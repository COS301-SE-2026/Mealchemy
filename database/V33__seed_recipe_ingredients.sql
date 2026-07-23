-- =============================================================================
-- V33__seed_recipe_ingredients.sql
--
-- Seeds all ingredients for all 5 recipes
-- sort_order controls the display sequence in the app - frontend must adhere to this
-- NULL quantity/unit where the recipe does not specify an exact amount
-- =============================================================================

-- Recipe 1: Honey Sriracha Chicken and Broccoli 

WITH recipe_1 AS (SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli')
INSERT INTO recipe_ingredients (recipe_id, ing_id, quantity, unit, sort_order)
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, olive, salad or cooking'),                              NULL,  NULL,    1 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Chicken, breast, boneless, skinless, raw'),       680,   'g',     2 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Eggs, Grade A, Large, egg white'),                           2,     NULL,    3 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cornstarch'),                                                60,    'g',     4 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Salt, table'),                                               12,    'g',     5 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Broccoli, raw'),                                             2,     'heads', 6 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, sesame, salad or cooking'),                             20,    'ml',    7 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Rice, brown, long-grain, cooked (Includes foods for USDA''s Food Distribution Program)'), 740, 'g', 8 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Honey'),                                                     60,    'ml',    9 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Sauce, hot chile, sriracha'),                                60,    'ml',    10 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Vinegar, red wine'),                                         10,    'ml',    11 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Soy sauce made from soy (tamari)'),                          30,    'ml',    12 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, spring or scallions (includes tops and bulb), raw'), 4,     NULL,    13 FROM recipe_1 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Seeds, sesame seeds, whole, dried'),                         10,    'g',     14 FROM recipe_1;

-- Recipe 2: Caprese Pasta Salad 

WITH recipe_2 AS (SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad')
INSERT INTO recipe_ingredients (recipe_id, ing_id, quantity, unit, sort_order)
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Pasta, cooked, enriched, without added salt'),        225,  'g',   1 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, olive, salad or cooking'),                           80,   'ml',  2 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Lemon juice, raw'),                                   30,   'ml',  3 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Vinegar, balsamic'),                                  15,   'ml',  4 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cheese, parmesan, hard'),                             50,   'g',   5 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Garlic, raw'),                                        2,    NULL,  6 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Salt, table'),                                        5,    'g',   7 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, pepper, black'),                              NULL, NULL,  8 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomatoes, grape, raw'),                               450,  'g',   9 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cheese, mozzarella, whole milk'),                     150,  'g',   10 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, red, raw'),                                   65,   'g',   11 FROM recipe_2 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Basil, fresh'),                                       40,   'g',   12 FROM recipe_2;

-- Recipe 3: Penne Alla Vodka

WITH recipe_3 AS (SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka')
INSERT INTO recipe_ingredients (recipe_id, ing_id, quantity, unit, sort_order)
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, olive, salad or cooking'),                           30,   'ml',  1 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, yellow, raw'),                                0.5,  NULL,  2 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Garlic, raw'),                                        3,    NULL,  3 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Salt, table'),                                        2.5,  'g',   4 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, pepper, red or cayenne'),                     2.5,  'g',   5 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomato products, canned, paste, without salt added (Includes foods for USDA''s Food Distribution Program)'), 170, 'g', 6 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Alcoholic beverage, distilled, vodka, 80 proof'),     60,   'ml',  7 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomatoes, canned, red, ripe, diced'),                 400,  'g',   8 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Pasta, cooked, enriched, without added salt'),        450,  'g',   9 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cream, fluid, heavy whipping'),                       120,  'ml',  10 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Parsley, fresh'),                                     NULL, NULL,  11 FROM recipe_3 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cheese, parmesan, hard'),                             NULL, NULL,  12 FROM recipe_3;

-- Recipe 4: Lemon Herb Salmon with Roasted Vegetables

WITH recipe_4 AS (SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables')
INSERT INTO recipe_ingredients (recipe_id, ing_id, quantity, unit, sort_order)
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Fish, salmon, Atlantic, farmed, raw'),                600,  'g',   1 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Squash, summer, zucchini, includes skin, raw'),       2,    NULL,  2 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Peppers, sweet, red, raw'),                           1,    NULL,  3 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Peppers, sweet, yellow, raw'),                        1,    NULL,  4 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Tomatoes, grape, raw'),                               200,  'g',   5 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, olive, salad or cooking'),                       60,   'ml',  6 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Lemon juice, raw'),                                   30,   'ml',  7 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Garlic, raw'),                                        4,    NULL,  8 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, oregano, dried'),                             5,    'g',   9 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, thyme, dried'),                               5,    'g',   10 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Salt, table'),                                        5,    'g',   11 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, pepper, black'),                              2.5,  'g',   12 FROM recipe_4 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Parsley, fresh'),                                     NULL, NULL,  13 FROM recipe_4;

-- Recipe 5: Black Bean and Corn Burrito Bowls

WITH recipe_5 AS (SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls')
INSERT INTO recipe_ingredients (recipe_id, ing_id, quantity, unit, sort_order)
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Beans, black, mature seeds, cooked, boiled, without salt'), 400, 'g', 1 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Corn, sweet, yellow, raw'),                               300,  'g',   2 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Rice, brown, long-grain, cooked (Includes foods for USDA''s Food Distribution Program)'), 370, 'g', 3 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Peppers, sweet, red, raw'),                               1,    NULL,  4 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Onions, red, raw'),                                       1,    NULL,  5 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Oil, olive, salad or cooking'),                           30,   'ml',  6 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, cumin seed'),                                     10,   'g',   7 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, paprika'),                                        5,    'g',   8 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Spices, garlic powder'),                                  5,    'g',   9 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Salt, table'),                                            5,    'g',   10 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Lime juice, raw'),                                        30,   'ml',  11 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Avocados, raw, all commercial varieties'),                1,    NULL,  12 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Coriander (cilantro) leaves, raw'),                      NULL, NULL,  13 FROM recipe_5 UNION ALL
SELECT recipe_id, (SELECT ing_id FROM ingredient_catalogue WHERE name = 'Cream, sour, reduced fat, cultured'),                    NULL, NULL,  14 FROM recipe_5;