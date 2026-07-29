-- =============================================================================
-- V40__alter_recipe_column_types.sql
--
-- edits prep_time_mins, cooking_time_mins, and serving_size types after a hibernate type mismatch. Widens smallint to int
-- =============================================================================

ALTER TABLE recipes ALTER COLUMN prep_time_mins TYPE integer;
ALTER TABLE recipes ALTER COLUMN cooking_time_mins TYPE integer;
ALTER TABLE recipes ALTER COLUMN serving_size TYPE integer;