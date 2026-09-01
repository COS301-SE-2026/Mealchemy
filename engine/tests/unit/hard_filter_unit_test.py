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