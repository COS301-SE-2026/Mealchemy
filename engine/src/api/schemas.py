from pydantic import BaseModel, Field

from src.models.recipe import CandidatePoolEntry
from src.models.user_state import UserState


class RecommendationRequest(BaseModel):
    user_state: UserState
    candidate_pool: list[CandidatePoolEntry] = Field(min_length=1)
    batch_size: int | None = Field(default=None, gt=0)
    exclude_recipe_ids: list[int] | None = None
    seed: int | None = None
