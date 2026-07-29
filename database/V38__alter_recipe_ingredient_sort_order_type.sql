-- =============================================================================
-- V38__alter_recipe_ingredient_sort_order_type.sql
--
-- edits the sort order field type after a hibernate type mismatch
-- =============================================================================

ALTER TABLE recipe_ingredients ALTER COLUMN sort_order TYPE integer;