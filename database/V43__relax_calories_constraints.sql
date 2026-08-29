-- =============================================================================
-- V43__relax_calories_constraints.sql
--
-- removing the not null constraint on calories so external USDA ingredients can be added to the catalogue
-- =============================================================================

ALTER TABLE ingredient_catalogue ALTER COLUMN calories_kcal DROP NOT NULL;