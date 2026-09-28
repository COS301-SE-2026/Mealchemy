-- =============================================================================
-- V61__add_unliked_to_swipeaction.sql
--
-- Adding UNLIKED to swipe_action_enum
-- =============================================================================

ALTER TYPE swipe_action_enum ADD VALUE 'UNLIKED';