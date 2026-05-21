-- =============================================================================
-- V3__create_roles.sql
--
-- Defines user roles and their associated permissions.
-- Seed later
-- =============================================================================

CREATE TABLE roles (
    role_id     SERIAL      PRIMARY KEY,
    role_name   VARCHAR(40) NOT NULL UNIQUE,
    permissions JSONB       NOT NULL DEFAULT '{}'::jsonb
);

COMMENT ON TABLE  roles             IS 'User roles and their permissions.';
COMMENT ON COLUMN roles.role_name   IS 'Unique role identifier. e.g. ''user'', ''admin''.';
COMMENT ON COLUMN roles.permissions IS 'JSON object describing what this role is permitted to do.';