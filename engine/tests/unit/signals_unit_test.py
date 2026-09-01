"""signals.py unit testing"""

from datetime import datetime, timedelta, timezone
from src.config import NEUTRAL_SIGNAL_VALUE
from src.core.signals import (
    cuisine_affinity_score, freshness_score, novelty_score, pantry_coverage_score
)

class TestNoveltyScore:
    def test_never_seen_returns_full_novelty(self):
        assert novelty_score(1, []) == 1.0

    def test_liked_very_recently_is_supressed(self, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(timezone.utc) - timedelta(days = 1))
        assert novelty_score(1, [swipe]) == 0.3

    def test_liked_moderately_recently_is_partial(self, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(timezone.utc) - timedelta(days = 5))
        assert novelty_score(1, [swipe]) == 0.6

    def test_liked_long_ago_is_fully_novel_again(sellf, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(timezone.utc) - timedelta(days = 10))
        assert novelty_score(1, [swipe]) == 1.0

    def test_skipped_recently_is_strongly_suppressed(self, swipe_factory):
        swipe = swipe_factory(1, "SKIPPED", datetime.now(timezone.utc) - timedelta(days = 2))

        assert novelty_score(1, [swipe]) == 0.2

    def test_skippeed_long_ago_is_mostly_eligible(self, swipe_factory):
        swipe = swipe_factory(1, "SKIPPED", datetime.now(timezone.utc) - timedelta(days = 10))

        assert novelty_score(1, [swipe]) == 0.7

    def test_expired_dislike_is_neutral_not_full_novelty(self, swipe_factory):
        swipe = swipe_factory(1, "DISLIKED", datetime.now(timezone.utc) - timedelta(days = 35))

        assert novelty_score(1, [swipe]) == NEUTRAL_SIGNAL_VALUE

    def test_only_the_most_recent_swipe_on_this_recipe_matters(self, swipe_factory):
        old_like = swipe_factory(1, "LIKED", datetime.now(timezone.utc) - timedelta(days = 20))
        recent_like = swipe_factory(1, "LIKED", datetime.now(timezone.utc) - timedelta(days = 1))

        assert novelty_score(1, [old_like, recent_like]) == 0.3

    def test_swipes_on_other_recipes_are_ignored(self, swipe_factory):
        other_recipe_swipe = swipe_factory(2, "LIKED", datetime.now(timezone.utc) - timedelta(days = 1))

        assert novelty_score(1, [other_recipe_swipe]) == 1.0

class TestPantryCoverageScore:
    def test_full_coverage_scores_one(self, ingredient_factory, pantry_entry_factory):
        ingredients = [ingredient_factory(1), ingredient_factory(2)]
        pantry = [pantry_entry_factory(1), pantry_entry_factory(2)]

        assert pantry_coverage_score(ingredients, pantry) == 1.0

    def test_partial_coverage_scores_the_ratio(self, ingredient_factory, pantry_entry_factory):
        ingredients = [ingredient_factory(1), ingredient_factory(2), ingredient_factory(3), ingredient_factory(4)]
        pantry = [pantry_entry_factory(1)]

        assert pantry_coverage_score(ingredients, pantry) == 0.25

    def test_no_coverage_scores_zero(self, ingredient_factory):
        ingredients = [ingredient_factory(1)]

        assert pantry_coverage_score(ingredients, []) == 0.0

    def test_empty_ingredients_scores_zero_not_divide_by_zero(self):
        assert pantry_coverage_score([], []) == 0.0

class TestCuisineAffinityScore:
    def test_known_cuisine_returns_stored_value(self):
        assert cuisine_affinity_score("ITALIAN", {"ITALIAN": 0.9}) == 0.9

    def test_unkown_cuisine_returns_neutral_default(self):
        assert cuisine_affinity_score("MEXICAN", {"ITALIAN: 0.9"}) == NEUTRAL_SIGNAL_VALUE

    def test_empty_affinities_returns_neutral(self):
        assert cuisine_affinity_score("ITALIAN", {}) == NEUTRAL_SIGNAL_VALUE