"""hard_filter.py unit testing"""

from datetime import datetime, timedelta, timezone
from src.core.hard_filter import hard_filter, passes_dietary_restrictions, passes_dislike_time_check

class TestPassesDietaryRestrictions:
    def test_no_restrictions_always_passes(self):
        assert passes_dietary_restrictions(["VEGAN"], []) is True

    def test_satisfied_subset_passes(self):
        assert passes_dietary_restrictions(["VEGETARIAN", "GLUTEN_FREE"], ["VEGETARIAN"]) is True

    def test_unsatisfied_restriction_fails(self):
        assert passes_dietary_restrictions(["GLUTEN_FREE"], ["VEGETARIAN"]) is False

    def test_vegan_does_not_implicitly_satisfy_vegetarian(self):
        assert passes_dietary_restrictions(["VEGAN"], ["VEGETARIAN"]) is False

    def test_multiple_restricions_all_must_be_satisfied(self):
        assert passes_dietary_restrictions(["VEGETARIAN"], ["VEGETARIAN", "GLUTEN_FREE"]) is False
        assert passes_dietary_restrictions(["VEGETARIAN", "GLUTEN_FREE"], ["VEGETARIAN", "GLUTEN_FREE"]) is True

class TestPassesDislikeTimeCheck:
    def test_no_history_passes(self):
        assert passes_dislike_time_check(1, []) is True

    def test_disliked_recently_fails(self, swipe_factory):
        recent_dislike = swipe_factory(1, "DISLIKED", datetime.now(timezone.utc) - timedelta(days = 10))
        assert passes_dislike_time_check(1, [recent_dislike]) is False

    def test_disliked_long_ago_passes(self, swipe_factory):
        expired_dislike = swipe_factory(1, "DISLIKED", datetime.now(timezone.utc) - timedelta(days = 35))

    def test_dislike_on_different_recipe_does_not_affect_this_one(self, swipe_factory):
        other_recipe_dislike = swipe_factory(2, "DISLIKED", datetime.now(timezone.utc) - timedelta(days = 1))

        assert passes_dislike_time_check(1, [other_recipe_dislike]) is True

    def test_recent_like_does_not_trigger_suppression(self, swipe_factory):
        recent_like = swipe_factory(1, "LIKED", datetime.now(timezone.utc) - timedelta(days = 1))

        assert passes_dislike_time_check(1, [recent_like]) is True

    def test_exactly_at_expiry_boundary_is_still_eligible(self, swipe_factory):
        boundary_dislike = swipe_factory(1, "DISLIKED", datetime.now(timezone.utc) - timedelta(days = 30, hours = 1))

        assert passes_dislike_time_check(1, [boundary_dislike]) is True