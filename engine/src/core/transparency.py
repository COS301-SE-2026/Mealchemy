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