from src.models.recipe import CandidatePoolEntry
from src.models.user_state import UserState, PreferenceWeights, SwipeAction

# stub function
def update_weights_from_swipe(current_weights: PreferenceWeights, recipe: CandidatePoolEntry, action: SwipeAction, user_state: UserState) -> PreferenceWeights:
    return current_weights

# stub function
def update_cuisine_affinity_from_swipe(current_affinities: dict[str, float], recipe: CandidatePoolEntry, action: SwipeAction) -> dict[str, float]:
    return current_affinities