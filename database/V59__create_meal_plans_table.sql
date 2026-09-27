-- =============================================================================
-- V59__create_meal_plans_table.sql
--
-- Meal planner for a vault
-- =============================================================================

CREATE TABLE meal_plans (
    plan_id     SERIAL      PRIMARY KEY,
    vault_id    INT         NOT NULL REFERENCES vaults(vault_id) ON DELETE CASCADE,
    created_by  INT         NOT NULL REFERENCES users(user_id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_meal_plans_vault UNIQUE (vault_id)
);

COMMENT ON TABLE meal_plans IS 'One ongoing, open-ended meal plan per vault. Not scoped to a week or fixed range.';