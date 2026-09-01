from src.models.recipe import CandidatePoolEntry
from src.models.recommendation import ScoreBreakdown
from src.models.user_state import UserState, PreferenceWeights, SwipeAction
from src.config import LIKE_REINFORCE_THRESHOLD, SKIPPED_LEARNING_RATE_MULTIPLIER, NEUTRAL_SIGNAL_VALUE

def update_weights_from_swipe(current_weights: dict[str, float], action: SwipeAction, signal_scores: ScoreBreakdown, alpha: float) -> dict[str, float]:
    new_weights = dict(current_weights)

    if action == "LIKED":
        if signal_scores.pantry_match > LIKE_REINFORCE_THRESHOLD:
            new_weights["pantry_match"] = ema_update(current_weights["pantry_match"], 1.0, alpha)
        if signal_scores.cuisine > LIKE_REINFORCE_THRESHOLD:
            new_weights["cuisine"] = ema_update(current_weights["cuisine"], 1.0, alpha)
        if signal_scores.freshness > LIKE_REINFORCE_THRESHOLD:
            new_weights["freshness"] = ema_update(current_weights["freshness"], 1.0, alpha)

    elif action == "DISLIKED":
        if signal_scores.cuisine > LIKE_REINFORCE_THRESHOLD:
            new_weights["cuisine"] = ema_update(current_weights["cuisine"], 0.0, alpha)

    elif action == "SKIPPED":
        new_weights["novelty"] = ema_update(
            current_weights["novelty"], 1.0, alpha * SKIPPED_LEARNING_RATE_MULTIPLIER
        )

    return new_weights

def update_cuisine_affinity_from_swipe(current_affinities: dict[str, float], recipe: CandidatePoolEntry, action: SwipeAction, alpha: float) -> dict[str, float]:
    new_affinities = dict(current_affinities)
    cuisine = recipe.cuisine if recipe.cuisine else None

    if not cuisine:
        return new_affinities

    current = new_affinities.get(cuisine, NEUTRAL_SIGNAL_VALUE)

    if action == "LIKED":
        new_affinities[cuisine] = ema_update(current, 1.0, alpha)
    elif action == "DISLIKED":
        new_affinities[cuisine] = ema_update(current, 0.0, alpha)
    elif action == "SKIPPED":
        new_affinities[cuisine] = ema_update(current, 0.0, alpha * SKIPPED_LEARNING_RATE_MULTIPLIER)

    return new_affinities

def ema_update(old: float, target: float, alpha: float) -> float:
    return alpha * target + (1 - alpha) * old
