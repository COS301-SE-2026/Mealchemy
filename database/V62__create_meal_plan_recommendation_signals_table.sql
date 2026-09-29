-- =============================================================================
-- V62__create_meal_plan_recommendation_signals_table.sql
--
-- Creating meal_plan_recommendation_signals table
-- =============================================================================

CREATE TABLE meal_plan_recommendation_signals (
    signal_id BIGSERIAL PRIMARY KEY,
    entry_id BIGINT NOT NULL REFERENCES meal_plan_entries(entry_id) ON DELETE CASCADE,
    recipe_id BIGINT NOT NULL,
    cuisine VARCHAR(60) NOT NULL,
    signal_scores JSONB NOT NULL,
    captured_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_at TIMESTAMPTZ
);

CREATE INDEX idx_meal_plan_recommendation_signals_entry_id ON meal_plan_recommendation_signals(entry_id);
CREATE UNIQUE INDEX uq_meal_plan_recommendation_signals_entry_id ON meal_plan_recommendation_signals(entry_id);