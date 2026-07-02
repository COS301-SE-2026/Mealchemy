-- =============================================================================
-- V2__create_enums.sql
-- Creating custom enums that will be used in other tables
--
-- Can alter later but never drop
-- =============================================================================

-- Vault types: private (per user), shared (multi-user), global (community/discovery).
CREATE TYPE vault_type_enum AS ENUM (
    'PRIVATE',
    'SHARED',
    'GLOBAL'
);

-- User's preferred unit of measurement
CREATE TYPE preferred_unit_enum AS ENUM (
    'METRIC',
    'IMPERIAL'
);

-- User's role: admin, general (different privileges)
CREATE TYPE user_role_enum AS ENUM (
    'ADMIN',
    'USER'
);

-- Flagged recipes possible statuses
CREATE TYPE flagged_status_enum AS ENUM (
    'PENDING',
    'REVIEWED',
    'RESOLVED'
);