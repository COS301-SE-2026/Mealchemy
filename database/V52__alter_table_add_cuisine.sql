-- V51__alter_table_add_cuisine.sql
--
-- alter the discovery_swipes so that cuisine is tracked making it obvious which affinity to update
-- =============================================================================

ALTER TABLE discovery_swipes ADD COLUMN cuisine_value VARCHAR(255);