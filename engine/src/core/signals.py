from datetime import datetime, timezone
from src.models.user_state import SwipeHistoryEntry
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