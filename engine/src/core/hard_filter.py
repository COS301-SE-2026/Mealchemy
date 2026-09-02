from datetime import datetime, timezone
from src.config import DISLIKE_EXPIRY_DAYS
from src.models.user_state import SwipeHistoryEntry, UserState
from src.models.recipe import CandidatePoolEntry
from src.core.exceptions import EmptyPoolError
from src.core.ingredient_matching import allergen_check

def passes_dietary_restrictions(dietary_tags: list[str], dietary_restrictions: list[str]) -> bool:
    return all(restriction in dietary_tags for restriction in dietary_restrictions)

def passes_dislike_time_check(recipe_id: int, swipe_history: list[SwipeHistoryEntry]) -> bool:
    now = datetime.now(timezone.utc)

    for swipe in swipe_history:
        if swipe.recipe_id != recipe_id:
            continue
        if swipe.action != "DISLIKED":
            continue

        days_since = (now - swipe.swiped_at).days
        if days_since < DISLIKE_EXPIRY_DAYS:
            return False

    return True

def hard_filter(candidate_pool: list[CandidatePoolEntry], user_state: UserState, exclude_recipe_ids: list[int] | None = None) -> list[CandidatePoolEntry]:
    exclude_set = set(exclude_recipe_ids or [])

    survivors = [
        recipe for recipe in candidate_pool
        if recipe.recipe_id not in exclude_set
        and allergen_check(recipe.ingredients, user_state.allergies)
        and passes_dietary_restrictions(recipe.dietary_tags, user_state.dietary_restrictions)
        and passes_dislike_time_check(recipe.recipe_id, user_state.swipe_history)
    ]

    if not survivors:
        return []

    return survivors