-- =============================================================================
-- V56__collaborative_vaults.sql
--
-- For collaborative vault features
--
-- Adds: vault_member.role, vault_invitations, notifications, recipe_edit_locks
-- =============================================================================
 

-- =============================================================================
-- vault_members.role
-- =============================================================================

ALTER TABLE vault_members
    ADD COLUMN role vault_member_role_enum NOT NULL DEFAULT 'VIEWER';
 
COMMENT ON COLUMN vault_members.role IS 'EDITOR or VIEWER. OWNER is derived from vaults.owner_id and never stored here.';
 

-- =============================================================================
-- vault_invitations
-- =============================================================================

CREATE TABLE vault_invitations (
    invitation_id        SERIAL                  PRIMARY KEY,
    vault_id             INT                     NOT NULL REFERENCES vaults(vault_id) ON DELETE CASCADE,
    invited_user_id      INT                     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    invited_by_user_id   INT                     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    invitation_status    invitation_status_enum  NOT NULL DEFAULT 'PENDING',
    created_at           TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    expires_at           TIMESTAMPTZ             NOT NULL,
    responded_at         TIMESTAMPTZ
);
 
CREATE INDEX idx_vault_invitations_invited_user_id ON vault_invitations(invited_user_id);
CREATE INDEX idx_vault_invitations_vault_id ON vault_invitations(vault_id);
 
-- User can only have one pending invitation per vault at a time
CREATE UNIQUE INDEX uq_vault_invitations_pending_per_user
    ON vault_invitations (vault_id, invited_user_id)
    WHERE invitation_status = 'PENDING';
 
COMMENT ON TABLE  vault_invitations                 IS 'Pending/accepted/declined/cancelled/expired invitations to join a shared vault.';
COMMENT ON COLUMN vault_invitations.responded_at    IS 'Null while PENDING. Set when the invitee accepts/declines or the owner cancels.';


-- =============================================================================
-- notifications
-- =============================================================================

CREATE TABLE notifications (
    notification_id      SERIAL                  PRIMARY KEY,
    recipient_user_id    INT                     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    actor_user_id        INT                     REFERENCES users(user_id) ON DELETE SET NULL,
    notification_type    notification_type_enum  NOT NULL,
    is_read              BOOLEAN                 NOT NULL DEFAULT FALSE,
    message              TEXT,
 
    -- Plain INT columns not foreign keys, should still show if e.g. recipe has since been deleted
    ref_vault_id          INT,
    ref_recipe_id         INT,
    ref_invitation_id     INT,
 
    created_at            TIMESTAMPTZ             NOT NULL DEFAULT NOW()
);
 
CREATE INDEX idx_notifications_recipient_user_id ON notifications(recipient_user_id);
CREATE INDEX idx_notifications_ref_vault_id ON notifications(ref_vault_id);
 
COMMENT ON TABLE  notifications               IS 'Per-recipient inbox entries. Query ref_vault_id to render a vault activity feed.';
COMMENT ON COLUMN notifications.actor_user_id IS 'Null if the account that triggered the event has since been deleted, or the event has no clear actor.';
COMMENT ON COLUMN notifications.message       IS 'Server-generated display text, e.g. "Sofia added Penne Alla Vodka", stored so it never needs recomputing on read.';


-- =============================================================================
-- recipe_edit_lock
-- =============================================================================

CREATE TABLE recipe_edit_locks (
    -- recipe_id IS the PK (not a separate generated id): one lock per recipe
    recipe_id             INT                     PRIMARY KEY REFERENCES recipes(recipe_id) ON DELETE CASCADE,
    locked_by_user_id     INT                     NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    acquired_at           TIMESTAMPTZ             NOT NULL DEFAULT NOW(),
    expires_at            TIMESTAMPTZ             NOT NULL
);
 
COMMENT ON TABLE recipe_edit_locks IS 'Soft edit lock for shared-vault recipes. Row is deleted on release.';