"""seeding.py unit testing"""

from src.core.seeding import derive_seed


class TestDeriveSeed:
    def test_none_base_seed_always_returns_none(self):
        assert derive_seed(None, "sampling") is None
        assert derive_seed(None, "novelty") is None

    def test_same_seed_and_purpose_is_deterministic(self):
        assert derive_seed(42, "sampling") == derive_seed(42, "sampling")

    def test_different_purposes_produce_different_derived_seeds(self):
        assert derive_seed(42, "sampling") != derive_seed(42, "novelty")

    def test_different_base_seeds_produce_different_derived_seeds(self):
        assert derive_seed(1, "sampling") != derive_seed(2, "sampling")

    def test_return_type_is_an_int_when_seeded(self):
        result = derive_seed(42, "sampling")
        assert isinstance(result, int)
        assert result != 42
