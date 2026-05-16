-- =============================================================================
-- V20__seed_recipes.sql
--
-- Seeds 5 recipes owned by the admin account.
--
-- Ingredients, Steps, Folder Links in migration files to follow
-- =============================================================================

INSERT INTO recipes (owner_id, title, description, cuisine_type, prep_time_mins, cooking_time_mins, serving_size)
VALUES

(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Honey Sriracha Chicken and Broccoli',
    'A quick and healthy meal prep bowl with crispy oven-baked chicken tossed in a sweet and spicy honey sriracha sauce, served over brown rice with roasted broccoli.',
    'asian',
    10,
    20,
    8
),

(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Caprese Pasta Salad',
    'A fresh and vibrant cold pasta salad with cherry tomatoes, mini mozzarella, red onion, and basil, dressed in a bright lemon and balsamic vinaigrette with pecorino.',
    'italian',
    15,
    15,
    6
),

(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Penne Alla Vodka',
    'A classic Italian-American pasta with a rich, creamy tomato and vodka sauce finished with Parmesan and fresh herbs. Comforting and deeply flavourful.',
    'italian',
    5,
    25,
    8
),

(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Lemon Herb Salmon with Roasted Vegetables',
    'Tender oven-roasted salmon fillets on a bed of colourful roasted vegetables, finished with a garlic, lemon, and herb dressing. Light, healthy, and ready in 30 minutes.',
    'mediterranean',
    10,
    20,
    4
),

(
    (SELECT user_id FROM users WHERE email = 'admin@mealchemy.com'),
    'Black Bean and Corn Burrito Bowls',
    'A hearty and wholesome vegetarian meal prep bowl with spiced black beans and corn over brown rice, topped with avocado, fresh coriander, and sour cream.',
    'mexican',
    10,
    15,
    4
);