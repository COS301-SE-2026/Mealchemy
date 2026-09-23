import random

from src.config import MESSAGE_TEMPLATES, TRANSPARENCY_STRONG_THRESHOLD
from src.core.ingredient_matching import pantry_ingredient_match
from src.core.seeding import derive_seed
from src.core.signals import freshness_detail, novelty_detail, nutrition_detail
from src.models.recipe import CandidatePoolEntry
from src.models.recommendation import ScoreBreakdown, SignalHighlight
from src.models.user_state import UserState

_SIGNALS = ("pantry_match", "cuisine", "nutrition", "novelty", "freshness")

def _tier(score: float) -> str:
    return "strong" if score >= TRANSPARENCY_STRONG_THRESHOLD else "moderate"

def _render_pantry_match(recipe: CandidatePoolEntry, user_state: UserState, score: float, rng: random.Random) -> str:
    owned_ids, _ = pantry_ingredient_match(recipe.ingredients, user_state.pantry)
    template = rng.choice(MESSAGE_TEMPLATES["pantry_match"][_tier(score)])
    return template.format(matched=len(owned_ids), total=len(recipe.ingredients))

def _render_cuisine(recipe: CandidatePoolEntry, score: float, rng: random.Random) -> str:
    template = rng.choice(MESSAGE_TEMPLATES["cuisine"][_tier(score)])
    return template.format(cuisine=recipe.cuisine)

def _render_nutrition(recipe: CandidatePoolEntry, user_state: UserState, rng: random.Random) -> str:
    detail = nutrition_detail(recipe, user_state)

    if detail is None:
        return rng.choice(MESSAGE_TEMPLATES["nutrition"]["none"])

    goal, actual, _, goal_score = detail

    template = rng.choice(MESSAGE_TEMPLATES["nutrition"][goal][_tier(goal_score)])
    return template.format(actual=round(actual))

def _render_novelty(recipe: CandidatePoolEntry, user_state: UserState, rng: random.Random) -> str:
    state, _ = novelty_detail(recipe.recipe_id, user_state.swipe_history)
    return rng.choice(MESSAGE_TEMPLATES["novelty"][state])

def _render_freshness(recipe: CandidatePoolEntry, user_state: UserState, rng: random.Random) -> str:
    detail = freshness_detail(recipe.ingredients, user_state.pantry)

    if detail is None:
        return rng.choice(MESSAGE_TEMPLATES["freshness"]["none"])

    ingredient_name, urgency = detail
    template = rng.choice(MESSAGE_TEMPLATES["freshness"][_tier(urgency)])

    return template.format(ingredient=ingredient_name)

_RENDERERS = {
    "pantry_match": lambda recipe, user_state, score, rng: _render_pantry_match(recipe, user_state, score, rng),
    "cuisine": lambda recipe, user_state, score, rng: _render_cuisine(recipe, score, rng),
    "nutrition": lambda recipe, user_state, score, rng: _render_nutrition(recipe, user_state, rng),
    "novelty": lambda recipe, user_state, score, rng: _render_novelty(recipe, user_state, rng),
    "freshness": lambda recipe, user_state, score, rng: _render_freshness(recipe, user_state, rng),
}