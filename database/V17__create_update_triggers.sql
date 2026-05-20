-- =============================================================================
-- V17__create_updated_at_triggers.sql
--
-- PostgreSQL trigger that automatically sets updated_at = NOW() on every UPDATE, for all tables that have an updated_at column.
--
-- Without it, updated_at columns in table would never change
-- The application layer doesn't need to set updated_at manually
-- =============================================================================

-- Shared trigger function - used by all triggers below.
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- user_profile
CREATE TRIGGER trg_user_profile_updated_at
    BEFORE UPDATE ON user_profile
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

--  user_preferences 
CREATE TRIGGER trg_user_preferences_updated_at
    BEFORE UPDATE ON user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

--  recipes 
CREATE TRIGGER trg_recipes_updated_at
    BEFORE UPDATE ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

--  pantry_ingredients 
CREATE TRIGGER trg_pantry_ingredients_updated_at
    BEFORE UPDATE ON pantry_ingredients
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();