from datetime import UTC, datetime

from src.config import (
    NEUTRAL_SIGNAL_VALUE,
    NOVELTY_LIKED_ACCEPTABLE_DAYS,
    NOVELTY_LIKED_RECENT_DAYS,
    NOVELTY_SCORE_LIKED_ACCEPTABLE,
    NOVELTY_SCORE_LIKED_OLD,
    NOVELTY_SCORE_LIKED_RECENT,
    NOVELTY_SCORE_NEVER_SEEN,
    NOVELTY_SCORE_SKIPPED_OLD,
    NOVELTY_SCORE_SKIPPED_RECENT,
    NOVELTY_SKIPPED_RECENT_DAYS,
    NUTRITION_HIGH_PROTEIN_MIN_G,
    NUTRITION_LOW_CARB_MAX_G,
)
from src.core.ingredient_matching import pantry_ingredient_match
from src.models.recipe import CandidatePoolEntry, Ingredient
from src.models.user_state import PantryEntry, SwipeHistoryEntry, UserState


def novelty_score(recipe_id: int, swipe_history: list[SwipeHistoryEntry]) -> float:
    relevant_swipes = [s for s in swipe_history if s.recipe_id == recipe_id]

    if not relevant_swipes:
        return NOVELTY_SCORE_NEVER_SEEN

    last_swipe = max(relevant_swipes, key=lambda s: s.swiped_at)
    days_ago = (datetime.now(UTC) - last_swipe.swiped_at).days

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

# Although not used in the main pipeline this isn't dead code and is left in for unit testing
def pantry_coverage_score(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> float:
    if not recipe_ingredients:
        return 0.0

    owned_ids, _ = pantry_ingredient_match(recipe_ingredients, pantry)
    return len(owned_ids) / len(recipe_ingredients)

def cuisine_affinity_score(cuisine: str, cuisine_affinities: dict[str, float]) -> float:
    return cuisine_affinities.get(cuisine, NEUTRAL_SIGNAL_VALUE)

def _score_high_protein(nutrition) -> float:
    if nutrition.protein_g is None:
        return NEUTRAL_SIGNAL_VALUE
    return 1.0 if nutrition.protein_g >= NUTRITION_HIGH_PROTEIN_MIN_G else 0.0

def _score_low_carb(nutrition) -> float:
    if nutrition.carbs_g is None:
        return NEUTRAL_SIGNAL_VALUE
    return 1.0 if nutrition.carbs_g <= NUTRITION_LOW_CARB_MAX_G else 0.0

_GOAL_SCORERS = {
    "HIGH_PROTEIN": _score_high_protein,
    "LOW_CARB": _score_low_carb,
}

def nutrition_score(recipe: CandidatePoolEntry, user_state: UserState) -> float:
    if recipe.nutrition is None:
        return NEUTRAL_SIGNAL_VALUE

    relevant_goals = [g for g in user_state.nutritional_goals if g in _GOAL_SCORERS]
    if not relevant_goals:
        return NEUTRAL_SIGNAL_VALUE

    goal_scores = [_GOAL_SCORERS[goal](recipe.nutrition) for goal in relevant_goals]
    return sum(goal_scores) / len(goal_scores)

def freshness_score(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> float:
    owned_ids, _ = pantry_ingredient_match(recipe_ingredients, pantry)
    if not owned_ids:
        return NEUTRAL_SIGNAL_VALUE

    pantry_by_ing_id = {p.ing_id: p for p in pantry}
    now = datetime.now(UTC)

    urgencies = []
    for ing_id in owned_ids:
        entry = pantry_by_ing_id.get(ing_id)
        if entry is None or entry.shelf_life_days is None:
            continue
        days_stored = (now - entry.added_at).days
        urgency = min(max(days_stored / entry.shelf_life_days, 0.0), 1.0)
        urgencies.append(urgency)

    if not urgencies:
        return NEUTRAL_SIGNAL_VALUE

    return sum(urgencies) / len(urgencies)
