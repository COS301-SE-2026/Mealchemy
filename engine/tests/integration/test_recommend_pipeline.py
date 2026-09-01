"""recommend_pipeline.py integration test making use of small_pool fixture"""

import json
from pathlib import Path

import pytest

from src.core.exceptions import EmptyPoolError
from src.core.recommend_pipeline import recommend
from src.models.recipe import CandidatePoolEntry

FIXTURES_DIR = Path(__file__).parent.parent / "fixtures"


def load_small_pool() -> list[CandidatePoolEntry]:
    with open(FIXTURES_DIR / "small_pool.json") as f:
        data = json.load(f)
    return [CandidatePoolEntry(**entry) for entry in data["candidate_pool"]]

class TestRecommendHappyPath:
    def test_full_pool_produces_recommendations(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        result = recommend(candidate_pool, user_state, seed=1)

        assert len(result.recommendations) > 0
        assert result.total_recipes_considered == 5
        assert result.total_candidates_after_filter == 5

    def test_no_duplicate_recipes_in_final_list(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        result = recommend(candidate_pool, user_state, seed=1)
        recipe_ids = [item.recipe_id for item in result.recommendations]

        assert len(recipe_ids) == len(set(recipe_ids))

    def test_cuisine_allocation_is_present_and_sums_reasonably(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        result = recommend(candidate_pool, user_state, seed=1)

        assert result.cuisine_allocation
        assert sum(result.cuisine_allocation.values()) <= 5

    def test_small_pool_returns_at_most_five_recommendations_regardless_of_batch_size(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        result = recommend(candidate_pool, user_state, batch_size=20, seed=1)

        assert len(result.recommendations) <= 5

    def test_deterministic_with_same_seed(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        first = recommend(candidate_pool, user_state, seed=7)
        second = recommend(candidate_pool, user_state, seed=7)

        assert [i.recipe_id for i in first.recommendations] == [i.recipe_id for i in second.recommendations]

class TestRecommendEmptyPool:
    def test_dietary_restriction_no_recipe_satisfies_raises_empty_pool_error(self, user_state_factory):
        candidate_pool = load_small_pool()

        user_state = user_state_factory(dietary_restrictions=["HALAL"])

        with pytest.raises(EmptyPoolError):
            recommend(candidate_pool, user_state, seed=1)

    def test_allergy_blocking_every_recipe_raises_empty_pool_error(self, user_state_factory):
        candidate_pool = load_small_pool()

        user_state = user_state_factory(allergies=["SESAME"])

        with pytest.raises(EmptyPoolError):
            recommend(candidate_pool, user_state, seed=1)

class TestRecommendExcludeRecipeIds:
    def test_excluded_recipes_do_not_appear_in_results(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        result = recommend(candidate_pool, user_state, exclude_recipe_ids=[101, 102, 103, 104], seed=1)
        recipe_ids = [item.recipe_id for item in result.recommendations]

        assert 101 not in recipe_ids
        assert 102 not in recipe_ids
        assert 103 not in recipe_ids
        assert 104 not in recipe_ids

    def test_excluding_all_but_one_recipe_still_returns_that_one(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        result = recommend(candidate_pool, user_state, exclude_recipe_ids=[101, 102, 103, 104], seed=1)

        assert result.total_candidates_after_filter == 1
        assert [item.recipe_id for item in result.recommendations] == [105]

    def test_excluding_every_recipe_raises_empty_pool_error(self, user_state_factory):
        candidate_pool = load_small_pool()
        user_state = user_state_factory()

        with pytest.raises(EmptyPoolError):
            recommend(candidate_pool, user_state, exclude_recipe_ids=[101, 102, 103, 104, 105], seed=1)