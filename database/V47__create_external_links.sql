-- =============================================================================
-- V47__create_external_links.sql
--
-- create a table that allows users to store external recipe, photo and video links
-- =============================================================================

CREATE TABLE external_links (
    link_id        SERIAL        PRIMARY KEY,
    user_id        INT           NOT NULL REFERENCES users(user_id),
    name           TEXT          NOT NULL,
    url            TEXT          NOT NULL,
    created_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ
);

COMMENT ON TABLE  external_links            IS 'Stores exernal recipe, photo and video links that the user can upload.';