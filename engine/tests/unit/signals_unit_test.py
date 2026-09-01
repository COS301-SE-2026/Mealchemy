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