from src.config import DEFAULT_BATCH_SIZE
from src.core.allocation import allocate_slots, build_final_list, fill_wildcard, rank_cuisines
from src.core.dedup import dedup
from src.core.exceptions import EmptyPoolError
from src.core.hard_filter import hard_filter
from src.core.sampling import sample_for_tournament
from src.core.scoring import build_recommendation_item
from src.models.recipe import CandidatePoolEntry
from src.models.recommendation import RecommendationResult
from src.models.user_state import UserState


def recommend(
    candidate_pool: list[CandidatePoolEntry],
    user_state: UserState,
    batch_size: int | None = None,
    exclude_recipe_ids: list[int] | None = None,
    seed: int | None = None,
) -> RecommendationResult:
    effective_batch_size = batch_size or DEFAULT_BATCH_SIZE
    total_recipes_considered = len(candidate_pool)

    safe_pool = hard_filter(candidate_pool, user_state, exclude_recipe_ids)
    total_candidates_after_filter = len(safe_pool)

    if not safe_pool:
        raise EmptyPoolError("No candidates remain after hard filtering.")

    sampled_pool = sample_for_tournament(safe_pool, seed)

    scored_items = [build_recommendation_item(recipe, user_state) for recipe in sampled_pool]

    deduped_items = dedup(scored_items)

    cuisine_groups = rank_cuisines(deduped_items)
    allocation = allocate_slots(cuisine_groups, effective_batch_size)
    wildcard = fill_wildcard(cuisine_groups, allocation)
    final_list = build_final_list(cuisine_groups, allocation, wildcard)

    return RecommendationResult(
        recommendations=final_list,
        cuisine_allocation=allocation,
        total_candidates_after_filter=total_candidates_after_filter,
        total_recipes_considered=total_recipes_considered,
    )
