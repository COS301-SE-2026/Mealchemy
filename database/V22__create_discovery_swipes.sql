-- =============================================================================
-- V22__create_dicovery_swipes.sql
-- 
-- Records swipe action on a recipe when a user is in a dicovery session.
-- Swipe behaviour needed for the recommendation engine
-- =============================================================================

CREATE TABLE discovery_swipes (
    swipe_id            SERIAL              PRIMARY KEY,
    user_id             INT                 NOT NULL REFERENCES users(user_id)      ON DELETE CASCADE,
    recipe_id           INT                 NOT NULL REFERENCES recipes(recipe_id)  ON DELETE CASCADE,
    action              swipe_action_enum   NOT NULL,
    swiped_at           TIMESTAMPTZ         NOT NULL DEFAULT NOW(),
    weights_snapshot    JSONB
);

CREATE INDEX idx_discovery_swipes_user_id ON discovery_swipes(user_id);
CREATE INDEX idx_discovery_swipe_recipe_id ON discovery_swipes(recipe_id);

COMMENT ON TABLE discovery_swipes                   IS 'Actions recorded from the swipe dicovery interface. Will be used to adjust the weights for the recommendation engine.';
COMMENT ON COLUMN discovery_swipes.action           IS 'LIKED, DISLIKED.';
COMMENT ON COLUMN discovery_swipes.swiped_at        IS 'Never null - used to keep track of how long ago recipe was swiped on - used in recommendation engine.';
COMMENT ON COLUMN discovery_swipes.weights_snapshot IS 'Optional - captures preference weights at swipe time.';