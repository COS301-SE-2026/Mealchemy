from src.models.recommendation import ScoreBreakdown, RecommendationItem
from src.models.recipe import CandidatePoolEntry
from src.models.user_state import UserState, PreferenceWeights
from src.core.ingredient_matching import pantry_ingredient_match
from src.core.signals import (
    cuisine_affinity_score,
    novelty_score,
    nutrition_score,
    freshness_score,
)

def compute_score_breakdown(recipe: CandidatePoolEntry, user_state: UserState) -> tuple[ScoreBreakdown, set[int]]:
    owned_ids, missing_ids = pantry_ingredient_match(recipe.ingredients, user_state.pantry)
    pantry_match = len(owned_ids) / len(recipe.ingredients) if recipe.ingredients else 0.0

    breakdown = ScoreBreakdown(
        pantry_match = pantry_match,
        cuisine = cuisine_affinity_score(recipe.cuisine, user_state.cuisine_affinities),
        nutrition = nutrition_score(recipe, user_state),
        novelty = novelty_score(recipe.recipe_id, user_state.swipe_history),
        freshness = freshness_score(recipe.ingredients, user_state.pantry)
    )

    return breakdown, missing_ids

def score_recipe(breakdown: ScoreBreakdown, weights: PreferenceWeights) -> float:
    return (
        breakdown.pantry_match * weights.pantry_match 
        + breakdown.cuisine * weights.cuisine 
        + breakdown.nutrition * weights.nutrition
        + breakdown.novelty * weights.novelty
        + breakdown.freshness * weights.freshness
    )

def build_recommendation_item(recipe: CandidatePoolEntry, user_state: UserState) -> RecommendationItem:
    breakdown, missing_ids = compute_score_breakdown(recipe, user_state)
    total_score = score_recipe(breakdown, user_state.preference_weights)
    missing = [ing.name for ing in recipe.ingredients if ing.ing_id in missing_ids]

    return RecommendationItem(
        recipe_id = recipe.recipe_id,
        score = total_score,
        cuisine_type = recipe.cuisine,
        score_breakdown = breakdown,
        pantry_gap_count = len(missing),
        missing_ingredients = missing,
    )