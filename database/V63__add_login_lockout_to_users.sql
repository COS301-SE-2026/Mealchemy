-- =============================================================================
-- V63__add_login_lockout_to_users.sql
--
-- Additions to user table for rate limiting, preventing brute force attacks
-- =============================================================================

ALTER TABLE users
    ADD COLUMN failed_login_count   INTEGER    NOT NULL DEFAULT 0,
    ADD COLUMN locked_until         TIMESTAMPTZ;

COMMENT ON COLUMN users.failed_login_count IS 'Consecutive failed logins. Resets on success or after account lock expires.';
COMMENT ON COLUMN users.locked_until       IS 'Login rejected until this time. Null if not locked.';