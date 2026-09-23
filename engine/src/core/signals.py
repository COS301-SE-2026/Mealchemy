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
from src.models.recipe import CandidatePoolEntry, Ingredient, Nutrition
from src.models.user_state import PantryEntry, SwipeHistoryEntry, UserState

"""Returns (state_key, days_ago). days_ago is None when never seen"""


def _novelty_state(
    recipe_id: int, swipe_history: list[SwipeHistoryEntry]
) -> tuple[str, int | None]:
    relevant_swipes = [s for s in swipe_history if s.recipe_id == recipe_id]

    if not relevant_swipes:
        return "never_seen", None

    last_swipe = max(relevant_swipes, key=lambda s: s.swiped_at)
    days_ago = (datetime.now(UTC) - last_swipe.swiped_at).days

    if last_swipe.action == "LIKED":
        if days_ago < NOVELTY_LIKED_RECENT_DAYS:
            return "recent_like", days_ago
        if days_ago < NOVELTY_LIKED_ACCEPTABLE_DAYS:
            return "acceptable_like", days_ago
        return "old_like", days_ago

    if last_swipe.action == "SKIPPED":
        if days_ago < NOVELTY_SKIPPED_RECENT_DAYS:
            return "recent_skip", days_ago
        return "old_skip", days_ago

    return "neutral", days_ago


_NOVELTY_STATE_SCORES = {
    "never_seen": NOVELTY_SCORE_NEVER_SEEN,
    "recent_like": NOVELTY_SCORE_LIKED_RECENT,
    "acceptable_like": NOVELTY_SCORE_LIKED_ACCEPTABLE,
    "old_like": NOVELTY_SCORE_LIKED_OLD,
    "recent_skip": NOVELTY_SCORE_SKIPPED_RECENT,
    "old_skip": NOVELTY_SCORE_SKIPPED_OLD,
    "neutral": NEUTRAL_SIGNAL_VALUE,
}


def novelty_score(recipe_id: int, swipe_history: list[SwipeHistoryEntry]) -> float:
    state, _ = _novelty_state(recipe_id, swipe_history)
    return _NOVELTY_STATE_SCORES[state]


def novelty_detail(
    recipe_id: int, swipe_history: list[SwipeHistoryEntry]
) -> tuple[str, int | None]:
    return _novelty_state(recipe_id, swipe_history)


# Although not used in the main pipeline this isn't dead code and is left in for unit testing
def pantry_coverage_score(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> float:
    if not recipe_ingredients:
        return 0.0

    owned_ids, _ = pantry_ingredient_match(recipe_ingredients, pantry)
    return len(owned_ids) / len(recipe_ingredients)


def cuisine_affinity_score(cuisine: str, cuisine_affinities: dict[str, float]) -> float:
    return cuisine_affinities.get(cuisine, NEUTRAL_SIGNAL_VALUE)


def _score_high_protein(nutrition: Nutrition) -> float:
    if nutrition.protein_g is None:
        return NEUTRAL_SIGNAL_VALUE
    return min(nutrition.protein_g / NUTRITION_HIGH_PROTEIN_MIN_G, 1.0)


def _score_low_carb(nutrition: Nutrition) -> float:
    if nutrition.carbs_g is None:
        return NEUTRAL_SIGNAL_VALUE
    return max(1.0 - (nutrition.carbs_g / NUTRITION_LOW_CARB_MAX_G), 0.0)


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


"""Returns (goal, actual_value, threshold, goal_score) for whichever relevant goal scored 
highest individually. None when there's no nutrition data or no relevant goals."""


def nutrition_detail(
    recipe: CandidatePoolEntry, user_state: UserState
) -> tuple[str, float, float, float] | None:
    if recipe.nutrition is None:
        return None

    relevant_goals = [g for g in user_state.nutritional_goals if g in _GOAL_SCORERS]
    if not relevant_goals:
        return None

    scored = [(goal, _GOAL_SCORERS[goal](recipe.nutrition)) for goal in relevant_goals]
    best_goal, best_score = max(scored, key=lambda pair: pair[1])

    if best_goal == "HIGH_PROTEIN":
        if recipe.nutrition.protein_g is None:
            return None

        return best_goal, recipe.nutrition.protein_g, NUTRITION_HIGH_PROTEIN_MIN_G, best_score
    if best_goal == "LOW_CARB":
        if recipe.nutrition.carbs_g is None:
            return None

        return best_goal, recipe.nutrition.carbs_g, NUTRITION_LOW_CARB_MAX_G, best_score

    return None


def _owned_ingredient_urgencies(
    recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]
) -> list[tuple[int, float]]:
    owned_ids, _ = pantry_ingredient_match(recipe_ingredients, pantry)

    if not owned_ids:
        return []

    pantry_by_ing_id = {p.ing_id: p for p in pantry}
    now = datetime.now(UTC)

    urgencies = []
    for ing_id in owned_ids:
        entry = pantry_by_ing_id.get(ing_id)

        if entry is None or entry.shelf_life_days is None:
            continue
        days_stored = (now - entry.added_at).days
        urgency = min(max(days_stored / entry.shelf_life_days, 0.0), 1.0)
        urgencies.append((ing_id, urgency))

    return urgencies


def freshness_score(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> float:
    urgencies = _owned_ingredient_urgencies(recipe_ingredients, pantry)
    if not urgencies:
        return NEUTRAL_SIGNAL_VALUE
    return sum(u for _, u in urgencies) / len(urgencies)


"""Returns (ingredient_name, urgency) for the most urgent owned ingredient, or None."""


def freshness_detail(
    recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]
) -> tuple[str, float | None]:
    urgencies = _owned_ingredient_urgencies(recipe_ingredients, pantry)

    if not urgencies:
        return None

    ing_id, urgency = max(urgencies, key=lambda pair: pair[1])
    name = next((ing.name for ing in recipe_ingredients if ing.ing_id == ing_id), None)

    if name is None:
        return None

    return name, urgency
