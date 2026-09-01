from pydantic import BaseModel, Field
from datetime import datetime
from src.models.recommendation import ScoreBreakdown
from src.models.user_state import PreferenceWeights, SwipeAction

class SwipeUpdate(BaseModel):
    recipe_id: int = Field(gt = 0)
    cuisine: str
    action: SwipeAction
    signal_scores: ScoreBreakdown
    swiped_at: datetime

class LearningUpdateRequest(BaseModel):
    preference_weights: PreferenceWeights
    cuisine_affinities: dict[str, float]
    swipes: list[SwipeUpdate]
    alpha: float = Field(default = 0.15, gt = 0, le = 1)
    state_version: int

class LearningUpdateResponse(BaseModel):
    preference_weights: PreferenceWeights
    cuisine_affinities: dict[str, float]
    state_version: int
