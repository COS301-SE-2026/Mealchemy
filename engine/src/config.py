# Central configuration for the the recommendation engine.

# Default preference weights
DEFAULT_PREFERENCE_WEIGHTS = {
    "pantry_match" : 0.40,
    "cuisine" : 0.25,
    "nutrition" : 0.15,
    "novelty" : 0.10,
    "freshness" : 0.10,
}

# Learning loop weights
LEARNING_RATE = 0.15
SKIPPED_LEARNING_RATE_MULTIPLIER = 0.3

# HARD FILTERING DURATION
DISLIKE_EXPIRY_DAYS = 30

# Allergen category match table
# Needs discussion

# Sampling
TOURNAMENT_SAMPLE_SIZE = 100

# Signals

# Novelty
NOVELTY_LIKED_RECENT_DAYS = 3           # Suppress if < 3
NOVELTY_LIKED_ACCEPTABLE_DAYS = 7       # Partial if < 7
NOVELTY_SKIPPED_RECENT_DAYS = 7         # Suppress if < 7

NOVELTY_SCORE_LIKED_RECENT = 0.3
NOVELTY_SCORE_LIKED_ACCEPTABLE = 0.6
NOVELTY_SCORE_LIKED_OLD = 1.0
NOVELTY_SCORE_SKIPPED_RECENT = 0.2
NOVELTY_SCORE_SKIPPED_OLD = 0.7
NOVELTY_SCORE_NEVER_SEEN = 1.0

# Nutrition
NUTRITION_HIGH_PROTEIN_MIN_G = 25
NUTRITION_LOW_CARB_MAX_G = 20
NUTRITION_LOW_CALORIE_MAX_KCAL = 400
NUTRITION_HIGH_FIBRE_MIN_G = 8
NUTRITION_BALANCED_KCAL_RANGE = (300, 600)

# Neutrality
NEUTRAL_SIGNAL_VALUE = 0.5
SCORE_MIN = 0.0
SCORE_MAX = 1.0

# Batch size and slot selection
DEFAULT_BATCH_SIZE = 20
WILDCARD_SLOTS = 1