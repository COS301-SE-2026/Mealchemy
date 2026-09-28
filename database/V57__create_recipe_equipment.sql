-- =============================================================================
-- V57__create_recipe_equipment.sql
--
-- Holds the equipment needed in a particular recipe
-- =============================================================================

CREATE TABLE recipe_equipment (
    id              SERIAL  PRIMARY KEY,
    recipe_id       INT     NOT NULL REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    equipment_id    INT     NOT NULL REFERENCES equipment_options(id),

    CONSTRAINT recipe_equipment_unique UNIQUE (recipe_id, equipment_id)
);

CREATE INDEX idx_recipe_equipment_recipe_id  ON recipe_equipment(recipe_id);
CREATE INDEX idx_recipe_equipment_equipment_id     ON recipe_equipment(equipment_id);

COMMENT ON TABLE recipe_equipment IS 'Links recipes to the kitchen equipment needed to make them.';