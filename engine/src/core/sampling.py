import random  # sonar-resolve [safe] python:S2245 "Deterministic seeding for reproducibility"  # noqa
from src.config import TOURNAMENT_SAMPLE_SIZE
from src.core.seeding import derive_seed
from src.models.recipe import CandidatePoolEntry


def sample_for_tournament(
    safe_pool: list[CandidatePoolEntry], seed: int | None = None
) -> list[CandidatePoolEntry]:
    rng = random.Random(derive_seed(seed, "sampling")) 
    sample_size = min(TOURNAMENT_SAMPLE_SIZE, len(safe_pool))
    return rng.sample(safe_pool, sample_size)
