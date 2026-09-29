"""transparency.py unit testing"""

from src.core.transparency import build_transparency_card
from src.models.recommendation import ScoreBreakdown


def _breakdown(**overrides) -> ScoreBreakdown:
    base = {
        "pantry_match": 0.5,
        "cuisine": 0.5,
        "nutrition": 0.5,
        "novelty": 0.5,
        "freshness": 0.5,
    }
    base.update(overrides)
    return ScoreBreakdown(**base)


class TestBuildTransparencyCard:
    def test_always_returns_exactly_two_highlights(self, recipe_factory, user_state_factory):
        card = build_transparency_card(recipe_factory(), user_state_factory(), _breakdown(), seed=1)
        assert len(card) == 2

    def test_returns_the_two_highest_scoring_signals_in_order(
        self, recipe_factory, user_state_factory
    ):
        breakdown = _breakdown(
            pantry_match=0.9, cuisine=0.8, nutrition=0.1, novelty=0.1, freshness=0.1
        )
        card = build_transparency_card(recipe_factory(), user_state_factory(), breakdown, seed=1)
        assert [h.signal for h in card] == ["pantry_match", "cuisine"]

    def test_percentage_matches_rounded_score(self, recipe_factory, user_state_factory):
        breakdown = _breakdown(
            pantry_match=0.873, cuisine=0.2, nutrition=0.1, novelty=0.1, freshness=0.1
        )
        card = build_transparency_card(recipe_factory(), user_state_factory(), breakdown, seed=1)
        assert card[0].percentage == 87

    def test_ties_break_by_a_fixed_signal_order(self, recipe_factory, user_state_factory):
        card = build_transparency_card(recipe_factory(), user_state_factory(), _breakdown(), seed=1)
        assert [h.signal for h in card] == ["pantry_match", "cuisine"]

    def test_same_seed_produces_the_same_messages(self, recipe_factory, user_state_factory):
        recipe, user_state = recipe_factory(), user_state_factory()
        first = build_transparency_card(recipe, user_state, _breakdown(), seed=42)
        second = build_transparency_card(recipe, user_state, _breakdown(), seed=42)
        assert [h.message for h in first] == [h.message for h in second]

    def test_pantry_match_message_cites_matched_and_total_counts(
        self, recipe_factory, ingredient_factory, pantry_entry_factory, user_state_factory
    ):
        recipe = recipe_factory(ingredients=[ingredient_factory(1), ingredient_factory(2)])
        user_state = user_state_factory(pantry=[pantry_entry_factory(1)])
        breakdown = _breakdown(
            pantry_match=0.5, cuisine=0.0, nutrition=0.0, novelty=0.0, freshness=0.0
        )

        card = build_transparency_card(recipe, user_state, breakdown, seed=1)
        message = next(h.message for h in card if h.signal == "pantry_match")

        assert "1" in message
        assert "2" in message

    def test_cuisine_message_cites_the_recipes_cuisine(self, recipe_factory, user_state_factory):
        recipe = recipe_factory(cuisine="ITALIAN")
        breakdown = _breakdown(
            pantry_match=0.0, cuisine=0.9, nutrition=0.0, novelty=0.0, freshness=0.0
        )

        card = build_transparency_card(recipe, user_state_factory(), breakdown, seed=1)
        message = next(h.message for h in card if h.signal == "cuisine")

        assert "ITALIAN" in message

    def test_nutrition_with_no_goals_uses_generic_message(self, recipe_factory, user_state_factory):
        user_state = user_state_factory(nutritional_goals=[])
        breakdown = _breakdown(
            pantry_match=0.0, cuisine=0.0, nutrition=0.5, novelty=0.9, freshness=0.0
        )

        card = build_transparency_card(recipe_factory(), user_state, breakdown, seed=1)
        message = next(h.message for h in card if h.signal == "nutrition")

        assert message

    def test_freshness_with_no_owned_ingredients_uses_generic_message(
        self, recipe_factory, user_state_factory
    ):
        user_state = user_state_factory(pantry=[])
        breakdown = _breakdown(
            pantry_match=0.0, cuisine=0.0, nutrition=0.0, novelty=0.9, freshness=0.5
        )

        card = build_transparency_card(recipe_factory(), user_state, breakdown, seed=1)
        message = next(h.message for h in card if h.signal == "freshness")

        assert message
