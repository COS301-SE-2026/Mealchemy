-- =============================================================================
-- V46__seed_unit_of_measurement_type.sql
--
-- adds either WEIGHT or VOLUME - needed for different conversion logic
-- General measurements will have a nullable type (aren't converted)
-- =============================================================================

UPDATE units_of_measurement SET type = 'WEIGHT' WHERE name IN ('g', 'kg', 'oz', 'lb');
UPDATE units_of_measurement SET type = 'VOLUME' WHERE name IN ('ml', 'l', 'cup', 'fl_oz');