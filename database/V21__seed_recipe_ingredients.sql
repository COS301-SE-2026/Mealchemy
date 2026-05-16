-- =============================================================================
-- V21__seed_recipe_ingredients.sql
--
-- Seeds all ingredients for all 5 recipes
-- name_raw stores the ingredient exactly as it appears in the recipe
-- sort_order controls the display sequence in the app - frontend must adhere to this
-- NULL quantity/unit where the recipe does not specify an exact amount
-- =============================================================================

-- Recipe 1: Honey Sriracha Chicken and Broccoli 

INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
VALUES
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Olive oil spray',                    NULL,  NULL,  1),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Chicken breasts, diced (2.5cm)',     680,   'g',   2),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Egg whites, beaten',                 2,     NULL,  3),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Corn starch',                        60,    'g',   4),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Kosher salt',                        12,    'g',   5),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Broccoli, cut into small florets',   2,     'heads',6),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Sesame oil',                         20,    'ml',  7),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Cooked brown rice',                  740,   'g',   8),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Honey',                              60,    'ml',  9),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Sriracha sauce',                     60,    'ml',  10),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Seasoned rice vinegar',              10,    'ml',  11),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Sesame oil (sauce)',                 10,    'ml',  12),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Scallions, sliced',                  4,     NULL,  13),
((SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli'), 'Black and white sesame seeds',       10,    'g',   14);

-- Recipe 2: Caprese Pasta Salad 

INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
VALUES
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Cavatappi pasta',                        225,   'g',   1),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Extra-virgin olive oil',                  80,    'ml',  2),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Fresh lemon juice',                       30,    'ml',  3),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Balsamic vinegar',                        15,    'ml',  4),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Pecorino cheese, grated',                 25,    'g',   5),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Pecorino cheese, shaved',                 25,    'g',   6),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Garlic cloves, grated',                   2,     NULL,  7),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Sea salt',                                5,     'g',   8),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Freshly ground black pepper',             NULL,  NULL,  9),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Cherry tomatoes, halved',                 450,   'g',   10),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Mini mozzarella balls, halved',           150,   'g',   11),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Red onion, thinly sliced',                65,    'g',   12),
((SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad'), 'Fresh basil leaves, torn',                40,    'g',   13);

-- Recipe 3: Penne Alla Vodka

INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
VALUES
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Extra-virgin olive oil',                  30,    'ml',  1),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Yellow onion, chopped',                   0.5,   NULL,  2),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Garlic cloves, thinly sliced',            3,     NULL,  3),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Sea salt',                                2.5,   'g',   4),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Red pepper flakes',                       2.5,   'g',   5),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Tomato paste',                            170,   'g',   6),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Vodka',                                   60,    'ml',  7),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Whole peeled tomatoes, crushed',          400,   'g',   8),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Penne or rigatoni',                       450,   'g',   9),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Heavy cream',                             120,   'ml',  10),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Fresh parsley or basil, chopped',         NULL,  NULL,  11),
((SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka'), 'Parmesan cheese, for serving',            NULL,  NULL,  12);

-- Recipe 4: Lemon Herb Salmon with Roasted Vegetables

INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
VALUES
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Salmon fillets',                         600,   'g',   1),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Zucchini, sliced',                       2,     NULL,  2),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Red bell pepper, sliced',                1,     NULL,  3),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Yellow bell pepper, sliced',             1,     NULL,  4),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Cherry tomatoes',                        200,   'g',   5),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Olive oil',                              60,    'ml',  6),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Fresh lemon juice',                      30,    'ml',  7),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Garlic cloves, minced',                  4,     NULL,  8),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Dried oregano',                          5,     'g',   9),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Dried thyme',                            5,     'g',   10),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Sea salt',                               5,     'g',   11),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Black pepper',                           2.5,   'g',   12),
((SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables'), 'Fresh parsley, for garnish',             NULL,  NULL,  13);

-- Recipe 5: Black Bean and Corn Burrito Bowls

INSERT INTO recipe_ingredients (recipe_id, name_raw, quantity, unit, sort_order)
VALUES
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Black beans, canned, drained and rinsed', 400,   'g',   1),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Frozen corn, thawed',                     300,   'g',   2),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Cooked brown rice',                       370,   'g',   3),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Red bell pepper, diced',                  1,     NULL,  4),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Red onion, diced',                        1,     NULL,  5),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Olive oil',                               30,    'ml',  6),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Ground cumin',                            10,    'g',   7),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Smoked paprika',                          5,     'g',   8),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Garlic powder',                           5,     'g',   9),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Sea salt',                                5,     'g',   10),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Fresh lime juice',                        30,    'ml',  11),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Avocado, sliced',                         1,     NULL,  12),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Fresh coriander leaves',                  NULL,  NULL,  13),
((SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls'), 'Sour cream, for serving',                 NULL,  NULL,  14);