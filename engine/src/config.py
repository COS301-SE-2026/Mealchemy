# Central configuration for the the recommendation engine.

# Import
from typing import Any

# Default preference weights
DEFAULT_PREFERENCE_WEIGHTS = {
    "pantry_match": 0.40,
    "cuisine": 0.25,
    "nutrition": 0.15,
    "novelty": 0.10,
    "freshness": 0.10,
}

# Learning loop weights
LEARNING_RATE = 0.15
SKIPPED_LEARNING_RATE_MULTIPLIER = 0.3
LIKE_REINFORCE_THRESHOLD = 0.7

# HARD FILTERING DURATION
DISLIKE_EXPIRY_DAYS = 30

# Allergen category match table
ALLERGEN_CATEGORY_MAP: dict[str, set[int]] = {
    "PEANUTS": {11},
    "TREE_NUTS": {11},
    "SESAME": {11, 6},
    "GLUTEN": {4, 1},
    "DAIRY": {5},
    "EGGS": {5},
    "SOY": {10},
    "SHELLFISH": {7},
    "FISH": {7},
    "MOLLUSCS": {7},
    "MUSTARD": {17},
    "CELERY": {19, 17},
    "SULPHITES": {3, 8},
    "LUPIN": {1, 10},
}

# Sampling
TOURNAMENT_SAMPLE_SIZE = 100

# Signals

# Novelty
NOVELTY_LIKED_RECENT_DAYS = 3  # Suppress if < 3
NOVELTY_LIKED_ACCEPTABLE_DAYS = 7  # Partial if < 7
NOVELTY_SKIPPED_RECENT_DAYS = 7  # Suppress if < 7

NOVELTY_SCORE_LIKED_RECENT = 0.3
NOVELTY_SCORE_LIKED_ACCEPTABLE = 0.6
NOVELTY_SCORE_LIKED_OLD = 1.0
NOVELTY_SCORE_SKIPPED_RECENT = 0.2
NOVELTY_SCORE_SKIPPED_OLD = 0.7
NOVELTY_SCORE_NEVER_SEEN = 1.0

# Nutrition
NUTRITION_HIGH_PROTEIN_MIN_G = 25
NUTRITION_LOW_CARB_MAX_G = 20

# Transparency cards
TRANSPARENCY_STRONG_THRESHOLD = 0.8

MESSAGE_TEMPLATES: dict[str, Any] = {
    "pantry_match": {
        "strong": [
            "Matched {matched} of {total} ingredients you already have on hand.",
            "Your pantry already covers {matched} of {total} ingredients here.",
        ],
        "moderate": [
            "You've got {matched} of the {total} ingredients this recipe needs.",
            "{matched} out of {total} ingredients are already in your pantry.",
        ],
    },
    "cuisine": {
        "strong": [
            "You've consistently enjoyed {cuisine} recipes.",
            "{cuisine} is one of your favourite cuisines.",
        ],
        "moderate": [
            "Based on your swipes, you tend to like {cuisine} food.",
            "You've shown some interest in {cuisine} recipes before.",
        ],
    },
    "nutrition": {
        "HIGH_PROTEIN": {
            "strong": [
                "Packs {actual}g of protein, well above your high-protein goal.",
                "A high-protein pick at {actual}g per serving.",
            ],
            "moderate": [
                "Contains {actual}g of protein toward your high-protein goal.",
            ],
        },
        "LOW_CARB": {
            "strong": [
                "Well under your low-carb goal at just {actual}g of carbs.",
                "Only {actual}g of carbs, comfortably within your low-carb goal.",
            ],
            "moderate": [
                "Contains {actual}g of carbs, working toward your low-carb goal.",
            ],
        },
        "none": [
            "Fits your typical preferences.",
            "A solid all-round nutritional fit.",
        ],
    },
    "novelty": {
        "never_seen": [
            "You haven't tried this recipe before, seems like something you would like.",
            "A brand new recipe for you.",
        ],
        "recent_like": [
            "You liked this recently, keeping it familiar",
        ],
        "acceptable_like": [
            "You enjoyed this one a little while back.",
        ],
        "old_like": [
            "You liked this a while ago, let's see if it still tickles your fancy.",
        ],
        "recent_skip": [
            "You skipped this recently, but it's still worth another look.",
        ],
        "old_skip": [
            "It's been a while since you last skipped this one, maybe give it another look.",
        ],
        "neutral": [
            "Something a little different from your recent picks.",
        ],
    },
    "freshness": {
        "strong": [
            "Uses {ingredient}, which is close to its use-by date in your pantry.",
            "A good way to use up the {ingredient} you already already have before it turns.",
        ],
        "moderate": [
            "Uses {ingredient} from your pantry.",
        ],
        "none": [
            "Doesn't rely on anything nearing its use-by date.",
        ],
    },
}

# Neutrality
NEUTRAL_SIGNAL_VALUE = 0.5
SCORE_MIN = 0.0
SCORE_MAX = 1.0

# Batch size and slot selection
DEFAULT_BATCH_SIZE = 20
WILDCARD_SLOTS = 1
