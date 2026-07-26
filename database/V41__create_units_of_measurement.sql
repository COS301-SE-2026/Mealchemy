-- =============================================================================
-- V41__create_units_of_measurement.sql
--
-- Lookup table for the units of measurement users can select from when specifying quantities of an ingredient
-- Classified by METRIC or IMPERIAL enum decoupled from prefered_unit_enum
-- =============================================================================

CREATE TYPE measurement_system_enum AS ENUM (
    'METRIC',
    'IMPERIAL'
);

CREATE TABLE units_of_measurement (
    unit_id     SERIAL                  PRIMARY KEY,
    name        VARCHAR(30)             NOT NULL UNIQUE,
    system      measurement_system_enum     -- does not have not null, so piece/pinch etc are not classified to a system
);

COMMENT ON TABLE units_of_measurement       IS 'Lookup table of valid units of measurement, classified by metric/imperial system.';
COMMENT ON COLUMN units_of_measurement.name IS 'The unit string used to describe the unit of an ingredient quantity.';