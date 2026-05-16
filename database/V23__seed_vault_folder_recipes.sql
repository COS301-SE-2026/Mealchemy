-- =============================================================================
-- V23__seed_vault_folder_recipes.sql
--
-- Places all 5 seeded recipes into the admin's General folder.
-- =============================================================================

INSERT INTO vault_folder_recipes (folder_id, recipe_id)
VALUES
(
    (SELECT folder_id FROM vault_folders WHERE name = 'General'),
    (SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli')
),
(
    (SELECT folder_id FROM vault_folders WHERE name = 'General'),
    (SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad')
),
(
    (SELECT folder_id FROM vault_folders WHERE name = 'General'),
    (SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka')
),
(
    (SELECT folder_id FROM vault_folders WHERE name = 'General'),
    (SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables')
),
(
    (SELECT folder_id FROM vault_folders WHERE name = 'General'),
    (SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls')
);