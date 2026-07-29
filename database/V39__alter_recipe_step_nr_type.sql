-- =============================================================================
-- V39__alter_recipe_step_nr_type.sql
--
-- edits the step_nr field type after a hibernate type mismatch. Widens smallint to int
-- =============================================================================

ALTER TABLE recipe_steps ALTER COLUMN step_nr TYPE integer;