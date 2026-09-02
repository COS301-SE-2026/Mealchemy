-- V49__alter_enum_add_skipped.sql
--
-- alter the swipe_action_enum to also hold the SKIPPED value
-- =============================================================================

ALTER TYPE swipe_action_enum ADD VALUE 'SKIPPED';