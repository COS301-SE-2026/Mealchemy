-- =============================================================================
-- V60__create_meal_plan_entries_table.sql
--
-- Meal plan entries assign to a meal plan (vault)
-- =============================================================================

-- enums for entries
CREATE TYPE meal_slot AS ENUM ('BREAKFAST', 'LUNCH', 'DINNER', 'SNACK');

CREATE TYPE meal_plan_entry_source AS ENUM ('MANUAL', 'RECOMMENDED');


CREATE TABLE meal_plan_entries (
    entry_id    SERIAL                  PRIMARY KEY,
    plan_id     INT                     NOT NULL REFERENCES meal_plans(plan_id) ON DELETE CASCADE,
    recipe_id   INT                     NOT NULL REFERENCES recipes(recipe_id),
    entry_date  DATE                    NOT NULL,
    meal_slot   meal_slot               NOT NULL,
    meal_time   TIME                    NOT NULL,
    title       VARCHAR(200),
    note        VARCHAR(500),
    source      meal_plan_entry_source  NOT NULL DEFAULT 'MANUAL',
    added_by    INT                     NOT NULL REFERENCES users(user_id),
    created_at  TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_meal_plan_entry_slot UNIQUE (plan_id, entry_date, meal_slot)
);

CREATE INDEX idx_meal_plan_entries_plan_id ON meal_plan_entries(plan_id);
CREATE INDEX idx_meal_plan_entries_date ON meal_plan_entries(entry_date);

COMMENT ON COLUMN meal_plan_entries.title IS 'Optional override of the recipe display title for this entry.';
COMMENT ON COLUMN meal_plan_entries.note  IS 'Optional annotation, e.g. "Dessert" on a SNACK entry.';