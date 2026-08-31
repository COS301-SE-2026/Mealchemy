from datetime import datetime, timezone
from src.models.user_state import SwipeHistoryEntry
from src.core.ingredient_matching import pantry_ingredient_match
from src.models.recipe import Ingredient, CandidatePoolEntry
from src.models.user_state import PantryEntry, UserState
from src.config import (
    NOVELTY_LIKED_RECENT_DAYS,
    NOVELTY_LIKED_ACCEPTABLE_DAYS,
    NOVELTY_SKIPPED_RECENT_DAYS,
    NOVELTY_SCORE_LIKED_RECENT,
    NOVELTY_SCORE_LIKED_ACCEPTABLE,
    NOVELTY_SCORE_LIKED_OLD,
    NOVELTY_SCORE_SKIPPED_RECENT,
    NOVELTY_SCORE_SKIPPED_OLD,
    NOVELTY_SCORE_NEVER_SEEN,
    NEUTRAL_SIGNAL_VALUE
)

def novelty_score(recipe_id: int, swipe_history: list[SwipeHistoryEntry]) -> float:
    relevant_swipes = [s for s in swipe_history if s.recipe_id == recipe_id]

    if not relevant_swipes:
        return NOVELTY_SCORE_NEVER_SEEN

    last_swipe = max(relevant_swipes, key = lambda s: s.swiped_at)
    days_ago = (datetime.now(timezone.utc) - last_swipe.swiped_at).days

    if last_swipe.action == "LIKED":
        if days_ago < NOVELTY_LIKED_RECENT_DAYS:
            return NOVELTY_SCORE_LIKED_RECENT
        if days_ago < NOVELTY_LIKED_ACCEPTABLE_DAYS:
            return NOVELTY_SCORE_LIKED_ACCEPTABLE
        return NOVELTY_SCORE_LIKED_OLD

    if last_swipe.action == "SKIPPED":
        if days_ago < NOVELTY_SKIPPED_RECENT_DAYS:
            return NOVELTY_SCORE_SKIPPED_RECENT
        return NOVELTY_SCORE_SKIPPED_OLD

    return NEUTRAL_SIGNAL_VALUE

def pantry_coverage_score(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> float:
    if not recipe_ingredients:
        return 0.0

    owned_ids, _ = pantry_ingredient_match(recipe_ingredients, pantry)
    return len(owned_ids) / len(recipe_ingredients)

def cuisine_affinity_score(cuisine: str, cuisine_affinities: dict[str, float]) -> float:
    return cuisine_affinities.get(cuisine, NEUTRAL_SIGNAL_VALUE)