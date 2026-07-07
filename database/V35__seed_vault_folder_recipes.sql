-- =============================================================================
-- V35__seed_vault_folder_recipes.sql
--
-- Places all 5 seeded recipes into the admin's General folder.
-- =============================================================================

WITH general_folder AS (
    SELECT folder_id FROM vault_folders WHERE name = 'General'
)

INSERT INTO vault_folder_recipes (folder_id, recipe_id)
SELECT folder_id, (SELECT recipe_id FROM recipes WHERE title = 'Honey Sriracha Chicken and Broccoli')       FROM general_folder UNION ALL
SELECT folder_id, (SELECT recipe_id FROM recipes WHERE title = 'Caprese Pasta Salad')                       FROM general_folder UNION ALL
SELECT folder_id, (SELECT recipe_id FROM recipes WHERE title = 'Penne Alla Vodka')                          FROM general_folder UNION ALL
SELECT folder_id, (SELECT recipe_id FROM recipes WHERE title = 'Lemon Herb Salmon with Roasted Vegetables') FROM general_folder UNION ALL
SELECT folder_id, (SELECT recipe_id FROM recipes WHERE title = 'Black Bean and Corn Burrito Bowls')         FROM general_folder;