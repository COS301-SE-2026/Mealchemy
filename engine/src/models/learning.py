from datetime import datetime

from pydantic import BaseModel, Field, field_validator

from src.models.recommendation import ScoreBreakdown
from src.models.user_state import PreferenceWeights, SwipeAction


class SwipeUpdate(BaseModel):
    recipe_id: int = Field(gt=0)
    cuisine: str
    action: SwipeAction
    signal_scores: ScoreBreakdown
    swiped_at: datetime | None = None


class LearningUpdateRequest(BaseModel):
    preference_weights: PreferenceWeights
    cuisine_affinities: dict[str, float]
    swipes: list[SwipeUpdate]
    alpha: float = Field(default=0.15, gt=0, le=1)
    state_version: int

    @field_validator("cuisine_affinities")
    @classmethod
    def affinities_in_range(cls, value: dict[str, float]) -> dict[str, float]:
        for cuisine, score in value.items():
            if not (0.0 <= score <= 1.0):
                raise ValueError(
                    f"Cuisine affinities ['{cuisine}'] must be in the range "
                    f"[0.0 - 1.0], but got {score}"
                )
        return value


class LearningUpdateResponse(BaseModel):
    preference_weights: PreferenceWeights
    cuisine_affinities: dict[str, float]
    state_version: int
