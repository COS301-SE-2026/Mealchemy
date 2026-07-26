-- =============================================================================
-- V37__alter_recipes_and_vault_folder_recipes.sql
--
-- Adds two necessary columns that were forgotten about.
--
-- added_by: shows which vaultMember added the recipe, allows vaultmembers to see who can edit the recipe.
--
-- parent_recipe_id: since only recipe owners can edit their recipe, when you want to create your own version of the recipe you need to copy it,
-- this allows for tracking which recipes stem from a specific recipe and allows for copying of the initial recipe's steps and ingredients before
-- it can be edited.
-- =============================================================================

ALTER TABLE vault_folder_recipes ADD COLUMN added_by INTEGER REFERENCES users(user_id);

ALTER TABLE recipes ADD COLUMN parent_recipe_id INTEGER REFERENCES recipes(recipe_id);