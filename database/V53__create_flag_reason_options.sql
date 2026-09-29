-- =============================================================================
-- V53__create_flag_reason_options.sql
--
-- Lookup table with valid reasons fo flagging a recipe in the global vault
-- Recipes that violate community guidelines
-- =============================================================================

CREATE TABLE flag_reason_options (
    reason_id   SERIAL          PRIMARY KEY,
    value       VARCHAR(50)     NOT NULL UNIQUE,
    label       VARCHAR(100)    NOT NULL,
    sort_order  INT             NOT NULL DEFAULT 0
);

COMMENT ON TABLE flag_reason_options                IS 'Fixed set of reasons a user can select when flagging a recipe in the global vault.';
COMMENT ON COLUMN flag_reason_options.value         IS 'Identifier stored on flagged_recipes.reason, e.g. SPAM_MISLEADING.';
COMMENT ON COLUMN flag_reason_options.label         IS 'Human-readable label shown in the flag-submission dropdown.';
COMMENT ON COLUMN flag_reason_options.sort_order    IS 'Display order in the flag-submission dropdown.';
 
INSERT INTO flag_reason_options (value, label, sort_order) VALUES
    ('INAPPROPRIATE_LANGUAGE', 'Inappropriate language',            1),
    ('SPAM_MISLEADING',        'Spam / misleading',                 2),
    ('COPYRIGHT',              'Copyright / stolen content',        3),
    ('UNSAFE_INSTRUCTIONS',    'Unsafe or dangerous instructions',  4),
    ('OTHER',                  'Other',                             5);