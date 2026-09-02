"""hard_filter.py unit testing"""

from datetime import UTC, datetime, timedelta

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
        assert (
            passes_dietary_restrictions(
                ["VEGETARIAN", "GLUTEN_FREE"], ["VEGETARIAN", "GLUTEN_FREE"]
            )
            is True
        )


class TestPassesDislikeTimeCheck:
    def test_no_history_passes(self):
        assert passes_dislike_time_check(1, []) is True

    def test_disliked_recently_fails(self, swipe_factory):
        recent_dislike = swipe_factory(1, "DISLIKED", datetime.now(UTC) - timedelta(days=10))
        assert passes_dislike_time_check(1, [recent_dislike]) is False

    def test_disliked_long_ago_passes(self, swipe_factory):
        expired_dislike = swipe_factory(1, "DISLIKED", datetime.now(UTC) - timedelta(days=35))
        assert passes_dislike_time_check(1, [expired_dislike]) is True

    def test_dislike_on_different_recipe_does_not_affect_this_one(self, swipe_factory):
        other_recipe_dislike = swipe_factory(2, "DISLIKED", datetime.now(UTC) - timedelta(days=1))

        assert passes_dislike_time_check(1, [other_recipe_dislike]) is True

    def test_recent_like_does_not_trigger_suppression(self, swipe_factory):
        recent_like = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=1))

        assert passes_dislike_time_check(1, [recent_like]) is True

    def test_exactly_at_expiry_boundary_is_still_eligible(self, swipe_factory):
        boundary_dislike = swipe_factory(
            1, "DISLIKED", datetime.now(UTC) - timedelta(days=30, hours=1)
        )

        assert passes_dislike_time_check(1, [boundary_dislike]) is True


class TestHardFilter:
    def test_recipe_passing_all_checks_survives(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(recipe_id=1, dietary_tags=[])
        user_state = user_state_factory()

        result = hard_filter([recipe], user_state)

        assert result == [recipe]

    def test_allergen_match_removes_recipe(
        self, recipe_factory, ingredient_factory, user_state_factory
    ):
        recipe = recipe_factory(recipe_id=1, ingredients=[ingredient_factory(1, category_id=11)])
        user_state = user_state_factory(allergies=["PEANUTS"])

        result = hard_filter([recipe], user_state)

        assert result == []

    def test_dietary_restriction_removes_recipe(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(recipe_id=1, dietary_tags=[])
        user_state = user_state_factory(dietary_restrictions=["VEGAN"])

        result = hard_filter([recipe], user_state)

        assert result == []

    def test_recent_dislike_removes_recipe(self, recipe_factory, user_state_factory, swipe_factory):
        recipe = recipe_factory(recipe_id=1, dietary_tags=[])
        dislike = swipe_factory(1, "DISLIKED", datetime.now(UTC) - timedelta(days=1))
        user_state = user_state_factory(swipe_history=[dislike])

        result = hard_filter([recipe], user_state)

        assert result == []

    def test_exclude_recipe_ids_removes_recipe(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(recipe_id=1, dietary_tags=[])
        user_state = user_state_factory()

        result = hard_filter([recipe], user_state, exclude_recipe_ids=[1])

        assert result == []

    def test_exclude_recipe_ids_does_not_affect_other_recipes(
        self, recipe_factory, user_state_factory
    ):
        recipe_a = recipe_factory(recipe_id=1, dietary_tags=[])
        recipe_b = recipe_factory(recipe_id=2, dietary_tags=[])
        user_state = user_state_factory()

        result = hard_filter([recipe_a, recipe_b], user_state, exclude_recipe_ids=[1])

        assert result == [recipe_b]

    def test_exclude_recipe_ids_none_is_safe(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(recipe_id=1, dietary_tags=[])
        user_state = user_state_factory()

        result = hard_filter([recipe], user_state, exclude_recipe_ids=None)

        assert result == [recipe]

    def test_mixed_pool_only_eligible_recipes_survive(
        self, recipe_factory, ingredient_factory, user_state_factory
    ):
        safe_recipe = recipe_factory(recipe_id=1, dietary_tags=[])
        allergen_recipe = recipe_factory(
            recipe_id=2, ingredients=[ingredient_factory(2, category_id=11)]
        )
        dietary_blocked_recipe = recipe_factory(recipe_id=3, dietary_tags=[])
        user_state = user_state_factory(allergies=["PEANUTS"], dietary_restrictions=["VEGAN"])

        result = hard_filter([safe_recipe, allergen_recipe, dietary_blocked_recipe], user_state)

        assert result == []

    def test_everything_filtered_returns_empty_list_not_error(
        self, recipe_factory, ingredient_factory, user_state_factory
    ):
        recipe = recipe_factory(recipe_id=1, ingredients=[ingredient_factory(1, category_id=11)])
        user_state = user_state_factory(allergies=["PEANUTS"])

        result = hard_filter([recipe], user_state)

        assert result == []
