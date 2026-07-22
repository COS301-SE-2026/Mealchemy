-- =============================================================================
-- V23__create_user_preference_weights.sql
-- 
-- Used to track and stores the learnable signal weights that will drive phase 2 of the recommendation engine.
-- Weights always sum to exactly 1.0
-- EMA used to update weights after every swipe.
-- Only enigine updates these
-- =============================================================================

CREATE TABLE user_preference_weights (
    weight_id       SERIAL          PRIMARY KEY,
    user_id         INT             NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    pantry_match    DECIMAL(5,4)    NOT NULL DEFAULT 0.4000,
    cuisine         DECIMAL(5,4)    NOT NULL DEFAULT 0.2500,   
    nutrition       DECIMAL(5,4)    NOT NULL DEFAULT 0.1000,
    freshness       DECIMAL(5,4)    NOT NULL DEFAULT 0.1500,
    novelty         DECIMAL(5,4)    NOT NULL DEFAULT 0.1000,
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE user_preference_weights                IS '5 learnable weights per user. Always sum to 1.0';
COMMENT ON COLUMN user_preference_weights.pantry_match  IS 'How much user prioritises cooking what they already have in their pantry.';
COMMENT ON COLUMN user_preference_weights.cuisine       IS 'How much cuisine type influences the recommendation.';
COMMENT ON COLUMN user_preference_weights.nutrition     IS 'How much user prioritises nutritional goal alignment.';
COMMENT ON COLUMN user_preference_weights.freshness     IS 'How much user prioritises cooking with ingredients close to their expiry date.';
COMMENT ON COLUMN user_preference_weights.novelty       IS 'How strongly the user wants variety over familiar recipes.';
