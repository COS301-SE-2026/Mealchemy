"""scoring.py unit testing"""

from src.config import NEUTRAL_SIGNAL_VALUE
from src.core.scoring import build_recommendation_item, compute_score_breakdown, score_recipe
from src.models.recommendation import ScoreBreakdown

class TestComputeScoreBreakdown:
    def test_pantry_match_reflects_actual_coverage(self, recipe_factory, ingredient_factory, pantry_entry_factory, user_state_factory):
        recipe = recipe_factory(ingredients = [ingredient_factory(1), ingredient_factory(2)])
        user_state = user_state_factory(pantry = [pantry_entry_factory(1)])

        breakdown, missing_ids = compute_score_breakdown(recipe, user_state)

        assert breakdown.pantry_match == 0.5
        assert missing_ids == {2}

    def test_nutrition_and_freshness_are_neutral_in_phase_a(self, recipe_factory, user_state_factory):
        recipe = recipe_factory()
        user_state = user_state_factory()

        breakdown, _= compute_score_breakdown(recipe, user_state)

        assert breakdown.nutrition == NEUTRAL_SIGNAL_VALUE
        assert breakdown.freshness == NEUTRAL_SIGNAL_VALUE

    def test_cuisine_uses_the_recipes_own_cuisine_type(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(cuisine = "ITALIAN")
        user_state = user_state_factory(cuisine_affinities = {"ITALIAN": 0.8, "MEXICAN": 0.2})

        breakdown, _ = compute_score_breakdown(recipe, user_state)

        assert breakdown.cuisine == 0.8

    def test_missing_ids_and_pantry_match_agree_with_each_other(self, recipe_factory, ingredient_factory, pantry_entry_factory, user_state_factory):
        recipe = recipe_factory(ingredients = [ingredient_factory(1), ingredient_factory(2), ingredient_factory(3)])
        user_state = user_state_factory(pantry = [pantry_entry_factory(1), pantry_entry_factory(3)])

        breakdown, missing_ids = compute_score_breakdown(recipe, user_state)

        owned_count = len(recipe.ingredients) - len(missing_ids)
        assert breakdown.pantry_match == owned_count / len(recipe.ingredients)
        assert missing_ids == {2}

class TestScoreRecipe:
    def test_dot_product_matches_manual_calculation(self, preference_weights_factory):
        breakdown = ScoreBreakdown(pantry_match = 0.8, cuisine = 0.6, nutrition = 0.5, novelty = 1.0, freshness = 0.2)
        weights = preference_weights_factory(pantry_match = 0.40, cuisine = 0.25, nutrition = 0.15, novelty = 0.10, freshness = 0.10)

        expected = (0.8 * 0.40) + (0.6 * 0.25) + (0.5 * 0.15) + (1.0 * 0.10) + (0.2 * 0.10)

        assert score_recipe(breakdown, weights) == expected

    def test_all_neutral_signals_with_default_weights_scores_neutral(self, preference_weights_factory):
        breakdown = ScoreBreakdown(pantry_match = 0.5, cuisine = 0.5, nutrition = 0.5, novelty = 0.5, freshness = 0.5)
        weights = preference_weights_factory()

        assert score_recipe(breakdown, weights) == 0.5

    def test_result_is_within_bounds(self, preference_weights_factory):
        breakdown = ScoreBreakdown(pantry_match = 1.0, cuisine = 1.0, nutrition = 1.0, novelty = 1.0, freshness = 1.0)
        weights = preference_weights_factory()

        result = score_recipe(breakdown, weights)

        assert 0.0 <= result <= 1.0
