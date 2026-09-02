from src.config import (
    DEFAULT_PREFERENCE_WEIGHTS,
    LIKE_REINFORCE_THRESHOLD,
    NEUTRAL_SIGNAL_VALUE,
    SKIPPED_LEARNING_RATE_MULTIPLIER,
)
from src.models.learning import LearningUpdateRequest, LearningUpdateResponse
from src.models.recommendation import ScoreBreakdown
from src.models.user_state import PreferenceWeights, SwipeAction


def update_weights_from_swipe(
    current_weights: dict[str, float],
    action: SwipeAction,
    signal_scores: ScoreBreakdown,
    alpha: float,
) -> dict[str, float]:
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


def update_cuisine_affinity_from_swipe(
    current_affinities: dict[str, float], cuisine: str, action: SwipeAction, alpha: float
) -> dict[str, float]:
    new_affinities = dict(current_affinities)

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


def renormalise(weights: dict[str, float]) -> dict[str, float]:
    total = sum(weights.values())

    if total == 0:
        return dict(DEFAULT_PREFERENCE_WEIGHTS)

    return {k: v / total for k, v in weights.items()}


def process_swipes(request: LearningUpdateRequest) -> LearningUpdateResponse:
    weights = dict(request.preference_weights.model_dump())
    affinities = dict(request.cuisine_affinities)

    for swipe in request.swipes:
        weights = update_weights_from_swipe(
            current_weights=weights,
            action=swipe.action,
            signal_scores=swipe.signal_scores,
            alpha=request.alpha,
        )
        affinities = update_cuisine_affinity_from_swipe(
            current_affinities=affinities,
            cuisine=swipe.cuisine,
            action=swipe.action,
            alpha=request.alpha,
        )

    weights = renormalise(weights)

    return LearningUpdateResponse(
        preference_weights=PreferenceWeights(**weights),
        cuisine_affinities=affinities,
        state_version=request.state_version,
    )
