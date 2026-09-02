-- =============================================================================
-- V45__add_type_to_unit_of_measurement.sql
--
-- adds either WEIGHT or VOLUME - needed for different conversion logic
-- General measurements will have a nullable type (aren't converted)
-- =============================================================================

CREATE TYPE measurement_type_enum AS ENUM (
    'WEIGHT',
    'VOLUME'
);


ALTER TABLE units_of_measurement
    ADD COLUMN type measurement_type_enum;

COMMENT ON COLUMN units_of_measurement.type IS 'WEIGHT or VOLUME classification. Used for the correct conversion factor';