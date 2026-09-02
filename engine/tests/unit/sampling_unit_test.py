"""sampling.py unit testing"""

from src.config import TOURNAMENT_SAMPLE_SIZE
from src.core.sampling import sample_for_tournament


class TestSampleForTournament:
    def test_pool_smaller_than_sample_size_returns_entire_pool(self, recipe_factory):
        pool = [recipe_factory(recipe_id=i) for i in range(5)]

        result = sample_for_tournament(pool, seed=1)

        assert len(result) == 5
        assert {r.recipe_id for r in result} == {r.recipe_id for r in pool}

    def test_pool_larger_than_sammple_size_returns_capped_sample(self, recipe_factory):
        pool = [recipe_factory(recipe_id=i) for i in range(TOURNAMENT_SAMPLE_SIZE + 50)]

        result = sample_for_tournament(pool, seed=1)

        assert len(result) == TOURNAMENT_SAMPLE_SIZE

    def test_empty_pool_returns_empty_list_without_crashing(self):
        result = sample_for_tournament([], seed=1)
        assert result == []

    def test_same_seed_produces_same_sample(self, recipe_factory):
        pool = [recipe_factory(recipe_id=i) for i in range(TOURNAMENT_SAMPLE_SIZE + 50)]

        first = sample_for_tournament(pool, seed=42)
        second = sample_for_tournament(pool, seed=42)

        assert [r.recipe_id for r in first] == [r.recipe_id for r in second]

    def test_no_seed_still_returns_valid_sample(self, recipe_factory):
        pool = [recipe_factory(recipe_id=i) for i in range(10)]

        result = sample_for_tournament(pool, seed=None)

        assert len(result) == 10
