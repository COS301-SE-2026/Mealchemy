-- =============================================================================
-- V9__create_recipes.sql
--
-- Core recipe metadata. Each recipe is owned by a user.
-- Ingredients live in recipe_ingredients (V12).
-- Steps live in recipe_steps (V13).
-- Vault assignment is handled via vault_folder_recipes (V11).
-- =============================================================================

CREATE TABLE recipes (
    recipe_id               SERIAL              PRIMARY KEY,
    owner_id                INT                 NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title                   VARCHAR(200)        NOT NULL,
    description             TEXT,
    cuisine_type            varchar(40),
    prep_time_mins          SMALLINT,
    cooking_time_mins       SMALLINT,
    serving_size            SMALLINT,

    -- URLs to Firebase Storage objects.
    -- Null until the user uploads media.
    photo_url               TEXT,
    video_url               TEXT,
    external_url            TEXT,

    -- Default false. This flag is checked by the backend when global vault is implemented
    is_community_published  BOOLEAN             NOT NULL DEFAULT FALSE,

    created_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ         NOT NULL DEFAULT NOW()
);

-- Index for fast lookup of all recipes by a user.
CREATE INDEX idx_recipes_owner_id ON recipes(owner_id);

COMMENT ON TABLE  recipes                          IS 'Core recipe metadata. Ingredients and steps are stored in their own tables.';
COMMENT ON COLUMN recipes.photo_url                IS 'URL to Firebase Storage object. Null until uploaded.';
COMMENT ON COLUMN recipes.video_url                IS 'URL to Firebase Storage object. Null until uploaded.';
COMMENT ON COLUMN recipes.is_community_published   IS 'Default false. Activates when the global vault is implemented.';
COMMENT ON COLUMN recipes.updated_at               IS 'Updated when user edits recipe';