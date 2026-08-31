from src.models.recommendation import ScoreBreakdown
from src.models.recipe import CandidatePoolEntry
from src.models.user_state import UserState, PreferenceWeights
from src.core.signals import (
    pantry_coverage_score,
    cuisine_affinity_score,
    novelty_score,
    nutrition_score,
    freshness_score,
)

def compute_score_breakdown(recipe: CandidatePoolEntry, user_state: UserState) -> ScoreBreakdown:
    return ScoreBreakdown(
        pantry_match = pantry_coverage_score(recipe.ingredients, user_state.pantry),
        cuisine = cuisine_affinity_score(recipe.cuisine, user_state.cuisine_affinities),
        nutrition = nutrition_score(recipe, user_state),
        novelty = novelty_score(recipe.recipe_id, user_state.swipe_history),
        freshness = freshness_score(recipe.ingredients, user_state.pantry)
    )