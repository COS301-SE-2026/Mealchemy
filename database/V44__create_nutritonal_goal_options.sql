-- =============================================================================
-- V44__create_nutritional_goal_options.sql
--
-- create a lookup table with potential nutritianal goals and seeds them as well
-- =============================================================================

CREATE TABLE nutritional_goals_options (
    id             SERIAL   PRIMARY KEY,
    value          TEXT     NOT NULL UNIQUE,
    label          TEXT     NOT NULL,
    description    TEXT,
    is_active      BOOLEAN  NOT NULL DEFAULT TRUE
);


INSERT INTO nutritional_goals_options (value, label, description, is_active)
VALUES 
    ('HIGH_PROTEIN', 'High Protein', 'Prioritises meals with elevated protein content', TRUE),
    ('LOW_CARB',      'Low Carb',     'Limits carbohydrate-heavy ingredients and meals', TRUE)
ON CONFLICT (value) DO NOTHING;