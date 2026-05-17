-- =============================================================================
-- V11__create_vault_folder_recipes.sql
--
-- Many-to-many between vault_folders and recipes - one folder can have many recipes.
-- A recipe can appear in multiple folders (Saved under Breakfast and Meal Prep)
-- =============================================================================

CREATE TABLE vault_folder_recipes (
    id          SERIAL      PRIMARY KEY,
    folder_id   INT         NOT NULL REFERENCES vault_folders(folder_id) ON DELETE CASCADE,
    recipe_id   INT         NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    added_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Prevent a recipe being added to the same folder twice.
    CONSTRAINT vault_folder_recipes_unique UNIQUE (folder_id, recipe_id)
);

-- Indexes for fast lookup from either direction of the relationship.
CREATE INDEX idx_vfr_folder_id ON vault_folder_recipes(folder_id);
CREATE INDEX idx_vfr_recipe_id ON vault_folder_recipes(recipe_id);

COMMENT ON TABLE vault_folder_recipes IS 'Many-to-many between vault_folders and recipes. A recipe can exist in multiple folders.';