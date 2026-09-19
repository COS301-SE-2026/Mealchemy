-- =============================================================================
-- V54__alter_flagged_recipes.sql
--
-- 1. Convert flagged_recipes.reason from free TEXT into a validated value referencing flag_reason_options(value)
-- 2. Adds a partial unique index so the same user cannot hold two PENDING flags against the same recipe at once
-- =============================================================================
 
-- 1.
ALTER TABLE flagged_recipes
    ALTER COLUMN reason TYPE VARCHAR(50),
    ALTER COLUMN reason SET NOT NULL;
 

ALTER TABLE flagged_recipes
    ADD CONSTRAINT fk_flagged_recipes_reason
    FOREIGN KEY (reason) REFERENCES flag_reason_options(value);
 

COMMENT ON COLUMN flagged_recipes.reason IS 'Reason category selected by the reporting user, references flag_reason_options(value).';
 

-- 2.
CREATE UNIQUE INDEX uq_flagged_recipes_pending_per_user
    ON flagged_recipes (recipe_id, flagged_by_user_id)
    WHERE status = 'PENDING';
 