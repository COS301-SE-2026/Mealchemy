-- =============================================================================
-- V21__seed_recipe_ingredients.sql
--
-- Seeds all ingredients for all 5 recipes
-- name_raw stores the ingredient exactly as it appears in the recipe
-- sort_order controls the display sequence in the app - frontend must adhere to this
-- NULL quantity/unit where the recipe does not specify an exact amount
-- =============================================================================

-- Recipe 1: Honey Sriracha Chicken and Broccoli 

WITH recipe_1 AS (SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli')
INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
SELECT recipe_id, 'Olive oil spray',                  NULL,  NULL,     1 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Chicken breasts, diced (2.5cm)',   680,   'g',      2 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Egg whites, beaten',               2,     NULL,     3 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Corn starch',                      60,    'g',      4 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Kosher salt',                      12,    'g',      5 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Broccoli, cut into small florets', 2,     'heads',  6 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Sesame oil',                       20,    'ml',     7 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Cooked brown rice',                740,   'g',      8 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Honey',                            60,    'ml',     9 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Sriracha sauce',                   60,    'ml',     10 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Seasoned rice vinegar',            10,    'ml',     11 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Sesame oil (sauce)',               10,    'ml',     12 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Scallions, sliced',                4,     NULL,     13 FROM recipe_1 UNION ALL
SELECT recipe_id, 'Black and white sesame seeds',     10,    'g',      14 FROM recipe_1;

-- Recipe 2: Caprese Pasta Salad 

WITH recipe_2 AS (SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad')
INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
SELECT recipe_id, 'Cavatappi pasta',                  225,   'g',      1 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Extra-virgin olive oil',           80,    'ml',     2 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Fresh lemon juice',                30,    'ml',     3 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Balsamic vinegar',                 15,    'ml',     4 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Pecorino cheese, grated',          25,    'g',      5 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Pecorino cheese, shaved',          25,    'g',      6 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Garlic cloves, grated',            2,     NULL,     7 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Sea salt',                         5,     'g',      8 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Freshly ground black pepper',      NULL,  NULL,     9 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Cherry tomatoes, halved',          450,   'g',      10 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Mini mozzarella balls, halved',    150,   'g',      11 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Red onion, thinly sliced',         65,    'g',      12 FROM recipe_2 UNION ALL
SELECT recipe_id, 'Fresh basil leaves, torn',         40,    'g',      13 FROM recipe_2;

-- Recipe 3: Penne Alla Vodka

WITH recipe_3 AS (SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka')
INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
SELECT recipe_id, 'Extra-virgin olive oil',           30,    'ml',     1 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Yellow onion, chopped',            0.5,   NULL,     2 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Garlic cloves, thinly sliced',     3,     NULL,     3 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Sea salt',                         2.5,   'g',      4 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Red pepper flakes',                2.5,   'g',      5 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Tomato paste',                     170,   'g',      6 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Vodka',                            60,    'ml',     7 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Whole peeled tomatoes, crushed',   400,   'g',      8 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Penne or rigatoni',                450,   'g',      9 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Heavy cream',                      120,   'ml',     10 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Fresh parsley or basil, chopped',  NULL,  NULL,     11 FROM recipe_3 UNION ALL
SELECT recipe_id, 'Parmesan cheese, for serving',     NULL,  NULL,     12 FROM recipe_3;

-- Recipe 4: Lemon Herb Salmon with Roasted Vegetables

WITH recipe_4 AS (SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables')
INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
SELECT recipe_id, 'Salmon fillets',                   600,   'g',      1 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Zucchini, sliced',                 2,     NULL,     2 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Red bell pepper, sliced',          1,     NULL,     3 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Yellow bell pepper, sliced',       1,     NULL,     4 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Cherry tomatoes',                  200,   'g',      5 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Olive oil',                        60,    'ml',     6 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Fresh lemon juice',                30,    'ml',     7 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Garlic cloves, minced',            4,     NULL,     8 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Dried oregano',                    5,     'g',      9 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Dried thyme',                      5,     'g',      10 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Sea salt',                         5,     'g',      11 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Black pepper',                     2.5,   'g',      12 FROM recipe_4 UNION ALL
SELECT recipe_id, 'Fresh parsley, for garnish',       NULL,  NULL,     13 FROM recipe_4;

-- Recipe 5: Black Bean and Corn Burrito Bowls

WITH recipe_5 AS (SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls')
INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
SELECT recipe_id, 'Black beans, canned, drained and rinsed', 400, 'g',  1 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Frozen corn, thawed',              300,   'g',      2 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Cooked brown rice',                370,   'g',      3 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Red bell pepper, diced',           1,     NULL,     4 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Red onion, diced',                 1,     NULL,     5 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Olive oil',                        30,    'ml',     6 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Ground cumin',                     10,    'g',      7 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Smoked paprika',                   5,     'g',      8 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Garlic powder',                    5,     'g',      9 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Sea salt',                         5,     'g',      10 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Fresh lime juice',                 30,    'ml',     11 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Avocado, sliced',                  1,     NULL,     12 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Fresh coriander leaves',           NULL,  NULL,     13 FROM recipe_5 UNION ALL
SELECT recipe_id, 'Sour cream, for serving',          NULL,  NULL,     14 FROM recipe_5;