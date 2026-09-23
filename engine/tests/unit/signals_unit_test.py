"""signals.py unit testing"""

from datetime import UTC, datetime, timedelta

import pytest

from src.config import NEUTRAL_SIGNAL_VALUE
from src.core.signals import (
    cuisine_affinity_score,
    freshness_score,
    novelty_score,
    nutrition_score,
    pantry_coverage_score,
    nutrition_detail,
    novelty_detail,
    freshness_detail,
)
from src.models.recipe import Nutrition


class TestNoveltyScore:
    def test_never_seen_returns_full_novelty(self):
        assert novelty_score(1, []) == 1.0

    def test_liked_very_recently_is_supressed(self, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=1))
        assert novelty_score(1, [swipe]) == 0.3

    def test_liked_moderately_recently_is_partial(self, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=5))
        assert novelty_score(1, [swipe]) == 0.6

    def test_liked_long_ago_is_fully_novel_again(self, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=10))
        assert novelty_score(1, [swipe]) == 1.0

    def test_skipped_recently_is_strongly_suppressed(self, swipe_factory):
        swipe = swipe_factory(1, "SKIPPED", datetime.now(UTC) - timedelta(days=2))

        assert novelty_score(1, [swipe]) == 0.2

    def test_skippeed_long_ago_is_mostly_eligible(self, swipe_factory):
        swipe = swipe_factory(1, "SKIPPED", datetime.now(UTC) - timedelta(days=10))

        assert novelty_score(1, [swipe]) == 0.7

    def test_expired_dislike_is_neutral_not_full_novelty(self, swipe_factory):
        swipe = swipe_factory(1, "DISLIKED", datetime.now(UTC) - timedelta(days=35))

        assert novelty_score(1, [swipe]) == NEUTRAL_SIGNAL_VALUE

    def test_only_the_most_recent_swipe_on_this_recipe_matters(self, swipe_factory):
        old_like = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=20))
        recent_like = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=1))

        assert novelty_score(1, [old_like, recent_like]) == 0.3

    def test_swipes_on_other_recipes_are_ignored(self, swipe_factory):
        other_recipe_swipe = swipe_factory(2, "LIKED", datetime.now(UTC) - timedelta(days=1))

        assert novelty_score(1, [other_recipe_swipe]) == 1.0

class TestNoveltyDetail:
    def test_never_seen_returns_that_state(self):
        state, days_ago = novelty_detail(1, [])
        assert state == "never_seen"
        assert days_ago is None

    def test_recent_like_returns_that_state_and_days(self, swipe_factory):
        swipe = swipe_factory(1, "LIKED", datetime.now(UTC) - timedelta(days=1))
        state, days_ago = novelty_detail(1, [swipe])
        assert state == "recent_like"
        assert days_ago == 1

    def test_old_skip_returns_that_state(self, swipe_factory):
        swipe = swipe_factory(1, "SKIPPED", datetime.now(UTC) - timedelta(days=10))
        state, _ = novelty_detail(1, [swipe])
        assert state == "old_skip"

    def test_dislike_returns_neutral_state(self, swipe_factory):
        swipe = swipe_factory(1, "DISLIKED", datetime.now(UTC) - timedelta(days=1))
        state, _ = novelty_detail(1, [swipe])
        assert state == "neutral"

class TestPantryCoverageScore:
    def test_full_coverage_scores_one(self, ingredient_factory, pantry_entry_factory):
        ingredients = [ingredient_factory(1), ingredient_factory(2)]
        pantry = [pantry_entry_factory(1), pantry_entry_factory(2)]

        assert pantry_coverage_score(ingredients, pantry) == 1.0

    def test_partial_coverage_scores_the_ratio(self, ingredient_factory, pantry_entry_factory):
        ingredients = [
            ingredient_factory(1),
            ingredient_factory(2),
            ingredient_factory(3),
            ingredient_factory(4),
        ]
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
        assert cuisine_affinity_score("MEXICAN", {"ITALIAN": 0.9}) == NEUTRAL_SIGNAL_VALUE

    def test_empty_affinities_returns_neutral(self):
        assert cuisine_affinity_score("ITALIAN", {}) == NEUTRAL_SIGNAL_VALUE


class TestNutritionScore:
    def test_meets_high_protein_threshold_scores_one(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(
            nutrition=Nutrition(calories_kcal=400, protein_g=30, carbs_g=20, fat_g=10)
        )
        user_state = user_state_factory(nutritional_goals=["HIGH_PROTEIN"])

        assert nutrition_score(recipe, user_state) == 1.0

    def test_misses_low_carb_threshold_scores_zero(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(
            nutrition=Nutrition(calories_kcal=400, protein_g=10, carbs_g=50, fat_g=10)
        )
        user_state = user_state_factory(nutritional_goals=["LOW_CARB"])

        assert nutrition_score(recipe, user_state) == 0.0

    def test_no_goals_selected_returns_neutral(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(
            nutrition=Nutrition(calories_kcal=400, protein_g=30, carbs_g=10, fat_g=10)
        )
        user_state = user_state_factory(nutritional_goals=[])

        assert nutrition_score(recipe, user_state) == NEUTRAL_SIGNAL_VALUE

    def test_missing_nutrition_data_returns_neutral(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(nutrition=None)
        user_state = user_state_factory(nutritional_goals=["HIGH_PROTEIN"])

        assert nutrition_score(recipe, user_state) == NEUTRAL_SIGNAL_VALUE

    def test_high_protein_partial_credit_below_threshold(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(nutrition=Nutrition(calories_kcal=300, protein_g=15, carbs_g=20, fat_g=10))
        user_state = user_state_factory(nutritional_goals=["HIGH_PROTEIN"])
        assert nutrition_score(recipe, user_state) == pytest.approx(0.6)

    def test_low_carb_partial_credit_above_zero(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(nutrition=Nutrition(calories_kcal=300, protein_g=10, carbs_g=10, fat_g=10))
        user_state = user_state_factory(nutritional_goals=["LOW_CARB"])
        assert nutrition_score(recipe, user_state) == pytest.approx(0.5) 

class TestNutritionDetail:
    def test_returns_the_highest_scoring_goal(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(nutrition=Nutrition(calories_kcal=300, protein_g=30, carbs_g=25, fat_g=10))
        user_state = user_state_factory(nutritional_goals=["HIGH_PROTEIN", "LOW_CARB"])

        goal, actual, _threshold, score = nutrition_detail(recipe, user_state)

        assert goal == "HIGH_PROTEIN"
        assert actual == 30
        assert score == 1.0

    def test_returns_none_when_no_goals_set(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(nutrition=Nutrition(calories_kcal=300, protein_g=30, carbs_g=10, fat_g=10))
        assert nutrition_detail(recipe, user_state_factory(nutritional_goals=[])) is None

    def test_returns_none_when_no_nutrition_data(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(nutrition=None)
        assert nutrition_detail(recipe, user_state_factory(nutritional_goals=["HIGH_PROTEIN"])) is None

class TestFreshnessScore:
    def test_freshly_added_ingredient_scores_low_urgency(
        self, ingredient_factory, pantry_entry_factory
    ):
        ingredients = [ingredient_factory(1)]
        pantry = [pantry_entry_factory(1, shelf_life_days=10, added_at=datetime.now(UTC))]

        assert freshness_score(ingredients, pantry) == pytest.approx(0.0, abs=0.01)

    def test_ingredient_past_shelf_life_caps_at_full_urgency(
        self, ingredient_factory, pantry_entry_factory
    ):
        ingredients = [ingredient_factory(1)]
        pantry = [
            pantry_entry_factory(
                1, shelf_life_days=5, added_at=datetime.now(UTC) - timedelta(days=10)
            )
        ]

        assert freshness_score(ingredients, pantry) == 1.0

    def test_no_owned_ingredients_returns_neutral(self, ingredient_factory):
        ingredients = [ingredient_factory(1)]

        assert freshness_score(ingredients, []) == NEUTRAL_SIGNAL_VALUE

    def test_owned_ingredient_missing_shelf_life_data_returns_neutral(
        self, ingredient_factory, pantry_entry_factory
    ):
        ingredients = [ingredient_factory(1)]
        pantry = [pantry_entry_factory(1, shelf_life_days=None)]

        assert freshness_score(ingredients, pantry) == NEUTRAL_SIGNAL_VALUE

class TestFreshnessDetail:
    def test_returns_none_when_no_owned_ingredients(self, ingredient_factory):
        assert freshness_detail([ingredient_factory(1)], []) is None

    def test_returns_the_most_urgent_owned_ingredient(self, ingredient_factory, pantry_entry_factory):
        ingredients = [ingredient_factory(1, name="Milk"), ingredient_factory(2, name="Rice")]
        pantry = [
            pantry_entry_factory(1, shelf_life_days=5, added_at=datetime.now(UTC) - timedelta(days=4)),
            pantry_entry_factory(2, shelf_life_days=100, added_at=datetime.now(UTC)),
        ]

        name, urgency = freshness_detail(ingredients, pantry)

        assert name == "Milk"
        assert urgency == pytest.approx(0.8)