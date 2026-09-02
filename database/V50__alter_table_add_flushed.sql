-- V50__alter_table_add_flushed.sql
--
-- alter the discovery_swipes so that flushed swipes can be tracked
-- =============================================================================

ALTER TABLE discovery_swipes ADD COLUMN flushed BOOLEAN NOT NULL DEFAULT false;