-- =============================================================================
-- V42__seed_units_of_measurement.sql
--
-- inserts the most common units of measurement used in cooking and classifies them as metric/imperial
-- =============================================================================

INSERT INTO units_of_measurement (name, system)
VALUES
    -- metric
    ('g', 'METRIC'),
    ('kg', 'METRIC'),
    ('ml', 'METRIC'),
    ('l', 'METRIC'),

    -- imperial
    ('oz', 'IMPERIAL'),
    ('lb', 'IMPERIAL'),
    ('cup', 'IMPERIAL'),
    ('fl_oz', 'IMPERIAL'),

    -- general
    ('tbsp', NULL),
    ('tsp', NULL),
    ('ct', NULL),
    ('pinch', NULL),
    ('piece', NULL),
    ('clove', NULL),
    ('slice', NULL),
    ('can', NULL),
    ('packet', NULL),
    ('bunch', NULL),
    ('stick', NULL);