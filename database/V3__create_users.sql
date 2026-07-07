-- =============================================================================
-- V3__create_users.sql
--
-- Authentication and user
-- User credentials - login info
-- Separate from user_profile and user_preferences
-- user_profile linked to user_preferences via user_id
-- =============================================================================

CREATE TABLE users (
    user_id         SERIAL              PRIMARY KEY,
    email           VARCHAR(255)        NOT NULL UNIQUE,
    password_hash   VARCHAR(255)        NOT NULL,
    roles           user_role_enum[]    NOT NULL DEFAULT ARRAY['USER']::user_role_enum[],
    created_at      TIMESTAMPTZ         NOT NULL DEFAULT NOW(),

    -- Soft delete: row is retained for FK integrity and data retention.
    deleted_at      TIMESTAMPTZ -- deleted_at is null for active accounts.

    -- Nice to have fields - not active for demo 1
    --email_verified      BOOLEAN     NOT NULL DEFAULT FALSE,
    --verified_at         TIMESTAMPTZ,
    --failed_login_count  SMALLINT    NOT NULL DEFAULT 0,
    --locked_until        TIMESTAMPTZ
);

COMMENT ON TABLE  users                     IS 'User credential information (login). Separate from user preferences.';
COMMENT ON COLUMN users.password_hash       IS 'Do not store plain text.';
COMMENT ON COLUMN users.deleted_at          IS 'Null if active. Soft delete for data retention and FK integrity.';
--COMMENT ON COLUMN users.email_verified      IS 'Not active for demo 1';
--COMMENT ON COLUMN users.verified_at         IS 'Not active for demo 1. Timestamp of email verification.';
--COMMENT ON COLUMN users.failed_login_count  IS 'Not active for demo 1. Default 0.';
--COMMENT ON COLUMN users.locked_until        IS 'Not active for demo 1. Null if account is not locked.';