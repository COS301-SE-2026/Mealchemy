"""learning.py unit testing"""

from datetime import datetime, timezone
import pytest
from src.core.learning import (
    ema_update,
    process_swipes,
    renormalise,
    update_cuisine_affinity_from_swipe,
    update_weights_from_swipe,
)
from src.config import (
    DEFAULT_PREFERENCE_WEIGHTS,
    LIKE_REINFORCE_THRESHOLD,
    NEUTRAL_SIGNAL_VALUE,
    SKIPPED_LEARNING_RATE_MULTIPLIER,
)
from src.models.learning import LearningUpdateRequest, SwipeUpdate
from src.models.recommendation import ScoreBreakdown
from src.models.user_state import PreferenceWeights

ALPHA = 0.15

def _weights(**overrides) -> dict[str, float]:
    base = dict(DEFAULT_PREFERENCE_WEIGHTS)
    base.update(overrides)
    return base

def _signal_scores(**overrides) -> ScoreBreakdown:
    base = {
        "pantry_match": 0.5,
        "cuisine": 0.5,
        "nutrition": 0.5,
        "novelty": 0.5,
        "freshness": 0.5,
    }
    base.update(overrides)
    return ScoreBreakdown(**base)

def _swipe_update(**overrides) -> SwipeUpdate:
    base = {
        "recipe_id": 1,
        "cuisine": "ITALIAN",
        "action": "LIKED",
        "signal_scores": _signal_scores(),
        "swiped_at": datetime.now(timezone.utc),
    }
    base.update(overrides)
    return SwipeUpdate(**base)

class TestEmaUpdate:
    def test_moves_toward_target(self):
        result = ema_update(old=0.5, target=1.0, alpha=0.15)
        assert result == pytest.approx(0.15 * 1.0 + 0.85 * 0.5)

    def test_alpha_zero_returns_old_unchanged(self):
        assert ema_update(old=0.42, target=1.0, alpha=0.0) == pytest.approx(0.42)

    def test_alpha_one_returns_target_unchanged(self):
        assert ema_update(old=0.42, target=1.0, alpha=1.0) == pytest.approx(1.0)

class TestUpdateWeightsFromSwipeLiked:
    def test_reinforces_pantry_when_above_threshold(self):
        weights = _weights()
        signals = _signal_scores(pantry_match=LIKE_REINFORCE_THRESHOLD + 0.1)

        result = update_weights_from_swipe(weights, "LIKED", signals, ALPHA)

        expected = ema_update(weights["pantry_match"], 1.0, ALPHA)
        assert result["pantry_match"] == pytest.approx(expected)

    def test_does_not_reinforce_pantry_when_at_or_below_threshold(self):
        weights = _weights()
        signals = _signal_scores(pantry_match=LIKE_REINFORCE_THRESHOLD)

        result = update_weights_from_swipe(weights, "LIKED", signals, ALPHA)

        assert result["pantry_match"] == pytest.approx(weights["pantry_match"])

    def test_reinforces_cuisine_when_above_threshold(self):
        weights = _weights()
        signals = _signal_scores(cuisine=LIKE_REINFORCE_THRESHOLD + 0.1)

        result = update_weights_from_swipe(weights, "LIKED", signals, ALPHA)

        expected = ema_update(weights["cuisine"], 1.0, ALPHA)
        assert result["cuisine"] == pytest.approx(expected)

    def test_reinforces_freshness_when_above_threshold(self):
        weights = _weights()
        signals = _signal_scores(freshness=LIKE_REINFORCE_THRESHOLD + 0.1)

        result = update_weights_from_swipe(weights, "LIKED", signals, ALPHA)

        expected = ema_update(weights["freshness"], 1.0, ALPHA)
        assert result["freshness"] == pytest.approx(expected)

    def test_multiple_signals_above_threshold_all_reinforce_independently(self):
        weights = _weights()
        signals = _signal_scores(pantry_match=0.9, cuisine=0.9, freshness=0.9)

        result = update_weights_from_swipe(weights, "LIKED", signals, ALPHA)

        assert result["pantry_match"] == pytest.approx(ema_update(weights["pantry_match"], 1.0, ALPHA))
        assert result["cuisine"] == pytest.approx(ema_update(weights["cuisine"], 1.0, ALPHA))
        assert result["freshness"] == pytest.approx(ema_update(weights["freshness"], 1.0, ALPHA))

    def test_nutrition_and_novelty_untouched_on_liked(self):
        weights = _weights()
        signals = _signal_scores(pantry_match=0.9, cuisine=0.9, freshness=0.9)

        result = update_weights_from_swipe(weights, "LIKED", signals, ALPHA)

        assert result["nutrition"] == pytest.approx(weights["nutrition"])
        assert result["novelty"] == pytest.approx(weights["novelty"])

class TestUpdateWeightsFromSwipeDisliked:
    def test_pushes_cuisine_down_when_above_threshold(self):
        weights = _weights()
        signals = _signal_scores(cuisine=LIKE_REINFORCE_THRESHOLD + 0.1)

        result = update_weights_from_swipe(weights, "DISLIKED", signals, ALPHA)

        expected = ema_update(weights["cuisine"], 0.0, ALPHA)
        assert result["cuisine"] == pytest.approx(expected)

    def test_does_not_touch_cuisine_when_below_threshold(self):
        weights = _weights()
        signals = _signal_scores(cuisine=0.2)

        result = update_weights_from_swipe(weights, "DISLIKED", signals, ALPHA)

        assert result["cuisine"] == pytest.approx(weights["cuisine"])

    def test_disliked_never_touches_pantry_or_freshness(self):
        weights = _weights()
        signals = _signal_scores(pantry_match=0.95, freshness=0.95, cuisine=0.95)

        result = update_weights_from_swipe(weights, "DISLIKED", signals, ALPHA)

        assert result["pantry_match"] == pytest.approx(weights["pantry_match"])
        assert result["freshness"] == pytest.approx(weights["freshness"])

class TestUpdateWeightsFromSwipeSkipped:
    def test_nudges_novelty_with_damped_rate(self):
        weights = _weights()
        signals = _signal_scores()

        result = update_weights_from_swipe(weights, "SKIPPED", signals, ALPHA)

        expected = ema_update(weights["novelty"], 1.0, ALPHA * SKIPPED_LEARNING_RATE_MULTIPLIER)
        assert result["novelty"] == pytest.approx(expected)

    def test_skipped_does_not_touch_other_weights(self):
        weights = _weights()
        signals = _signal_scores(pantry_match=0.95, cuisine=0.95, freshness=0.95)

        result = update_weights_from_swipe(weights, "SKIPPED", signals, ALPHA)

        assert result["pantry_match"] == pytest.approx(weights["pantry_match"])
        assert result["cuisine"] == pytest.approx(weights["cuisine"])
        assert result["freshness"] == pytest.approx(weights["freshness"])
        assert result["nutrition"] == pytest.approx(weights["nutrition"])

class TestUpdateCuisineAffinityFromSwipe:
    def test_liked_pushes_affinity_toward_one(self):
        affinities = {"ITALIAN": 0.5}

        result = update_cuisine_affinity_from_swipe(affinities, "ITALIAN", "LIKED", ALPHA)

        assert result["ITALIAN"] == pytest.approx(ema_update(0.5, 1.0, ALPHA))

    def test_disliked_pushes_affinity_toward_zero(self):
        affinities = {"ITALIAN": 0.5}

        result = update_cuisine_affinity_from_swipe(affinities, "ITALIAN", "DISLIKED", ALPHA)

        assert result["ITALIAN"] == pytest.approx(ema_update(0.5, 0.0, ALPHA))

    def test_skipped_pushes_affinity_toward_zero_with_damped_rate(self):
        affinities = {"ITALIAN": 0.5}

        result = update_cuisine_affinity_from_swipe(affinities, "ITALIAN", "SKIPPED", ALPHA)

        expected = ema_update(0.5, 0.0, ALPHA * SKIPPED_LEARNING_RATE_MULTIPLIER)
        assert result["ITALIAN"] == pytest.approx(expected)

    def test_unseen_cuisine_defaults_to_neutral_before_update(self):
        affinities: dict[str, float] = {}

        result = update_cuisine_affinity_from_swipe(affinities, "JAPANESE", "LIKED", ALPHA)

        expected = ema_update(NEUTRAL_SIGNAL_VALUE, 1.0, ALPHA)
        assert result["JAPANESE"] == pytest.approx(expected)

    def test_does_not_mutate_other_cuisines(self):
        affinities = {"ITALIAN": 0.9, "INDIAN": 0.6}

        result = update_cuisine_affinity_from_swipe(affinities, "ITALIAN", "LIKED", ALPHA)

        assert result["INDIAN"] == pytest.approx(0.6)

    def test_does_not_mutate_input_dict(self):
        affinities = {"ITALIAN": 0.5}

        update_cuisine_affinity_from_swipe(affinities, "ITALIAN", "LIKED", ALPHA)

        assert affinities["ITALIAN"] == 0.5

    def test_empty_cuisine_string_returns_affinities_unchanged(self):
        affinities = {"ITALIAN": 0.5}

        result = update_cuisine_affinity_from_swipe(affinities, "", "LIKED", ALPHA)

        assert result == {"ITALIAN": 0.5}

class TestRenormalise:
    def test_already_normal_weights_are_unchanged(self):
        weights = _weights()

        result = renormalise(weights)

        assert sum(result.values()) == pytest.approx(1.0)
        for key in weights:
            assert result[key] == pytest.approx(weights[key])

    def test_drifted_weights_are_rescaled_to_sum_to_one(self):
        drifted = _weights(pantry_match=0.50, cuisine=0.30)

        result = renormalise(drifted)

        assert sum(result.values()) == pytest.approx(1.0)
        assert result["pantry_match"] / result["cuisine"] == pytest.approx(
            drifted["pantry_match"] / drifted["cuisine"]
        )

    def test_zero_sum_falls_back_to_default_weights(self):
        zeroed = {k: 0.0 for k in DEFAULT_PREFERENCE_WEIGHTS}

        result = renormalise(zeroed)

        assert result == dict(DEFAULT_PREFERENCE_WEIGHTS)

    def test_zero_sum_fallback_does_not_return_live_config_reference(self):
        zeroed = {k: 0.0 for k in DEFAULT_PREFERENCE_WEIGHTS}

        result = renormalise(zeroed)
        result["pantry_match"] = 999.0

        assert DEFAULT_PREFERENCE_WEIGHTS["pantry_match"] != 999.0

class TestProcessSwipes:
    def test_single_liked_swipe_updates_weights_and_affinities(self):
        request = LearningUpdateRequest(
            preference_weights=PreferenceWeights(**DEFAULT_PREFERENCE_WEIGHTS),
            cuisine_affinities={"ITALIAN": 0.75},
            swipes=[
                _swipe_update(
                    cuisine="ITALIAN",
                    action="LIKED",
                    signal_scores=_signal_scores(pantry_match=0.8, cuisine=0.75, freshness=0.1),
                )
            ],
            alpha=ALPHA,
            state_version=3,
        )

        result = process_swipes(request)

        assert sum(result.preference_weights.model_dump().values()) == pytest.approx(1.0)
        assert result.cuisine_affinities["ITALIAN"] == pytest.approx(ema_update(0.75, 1.0, ALPHA))

    def test_state_version_is_echoed_back_unchanged(self):
        request = LearningUpdateRequest(
            preference_weights=PreferenceWeights(**DEFAULT_PREFERENCE_WEIGHTS),
            cuisine_affinities={},
            swipes=[_swipe_update()],
            alpha=ALPHA,
            state_version=42,
        )

        result = process_swipes(request)

        assert result.state_version == 42

    def test_empty_swipe_list_returns_renormalised_weights_unchanged(self):
        request = LearningUpdateRequest(
            preference_weights=PreferenceWeights(**DEFAULT_PREFERENCE_WEIGHTS),
            cuisine_affinities={"ITALIAN": 0.6},
            swipes=[],
            alpha=ALPHA,
            state_version=1,
        )

        result = process_swipes(request)

        assert result.preference_weights.model_dump() == pytest.approx(DEFAULT_PREFERENCE_WEIGHTS)
        assert result.cuisine_affinities == {"ITALIAN": 0.6}

    def test_swipes_are_applied_in_order_not_independently(self):
        request = LearningUpdateRequest(
            preference_weights=PreferenceWeights(**DEFAULT_PREFERENCE_WEIGHTS),
            cuisine_affinities={"ITALIAN": 0.5},
            swipes=[
                _swipe_update(recipe_id=1, cuisine="ITALIAN", action="LIKED"),
                _swipe_update(recipe_id=2, cuisine="ITALIAN", action="LIKED"),
            ],
            alpha=ALPHA,
            state_version=1,
        )

        result = process_swipes(request)

        after_first = ema_update(0.5, 1.0, ALPHA)
        after_second = ema_update(after_first, 1.0, ALPHA)
        assert result.cuisine_affinities["ITALIAN"] == pytest.approx(after_second)

    def test_full_weight_sum_still_one_after_multiple_swipes(self):
        request = LearningUpdateRequest(
            preference_weights=PreferenceWeights(**DEFAULT_PREFERENCE_WEIGHTS),
            cuisine_affinities={"ITALIAN": 0.5, "JAPANESE": 0.5},
            swipes=[
                _swipe_update(recipe_id=1, cuisine="ITALIAN", action="LIKED",
                              signal_scores=_signal_scores(pantry_match=0.9, cuisine=0.9)),
                _swipe_update(recipe_id=2, cuisine="JAPANESE", action="DISLIKED",
                              signal_scores=_signal_scores(cuisine=0.9)),
                _swipe_update(recipe_id=3, cuisine="ITALIAN", action="SKIPPED"),
            ],
            alpha=ALPHA,
            state_version=1,
        )

        result = process_swipes(request)

        assert sum(result.preference_weights.model_dump().values()) == pytest.approx(1.0)

    def test_different_cuisines_in_one_batch_both_update_independently(self):
        request = LearningUpdateRequest(
            preference_weights=PreferenceWeights(**DEFAULT_PREFERENCE_WEIGHTS),
            cuisine_affinities={"ITALIAN": 0.5, "JAPANESE": 0.5},
            swipes=[
                _swipe_update(recipe_id=1, cuisine="ITALIAN", action="LIKED"),
                _swipe_update(recipe_id=2, cuisine="JAPANESE", action="DISLIKED"),
            ],
            alpha=ALPHA,
            state_version=1,
        )

        result = process_swipes(request)

        assert result.cuisine_affinities["ITALIAN"] == pytest.approx(ema_update(0.5, 1.0, ALPHA))
        assert result.cuisine_affinities["JAPANESE"] == pytest.approx(ema_update(0.5, 0.0, ALPHA))