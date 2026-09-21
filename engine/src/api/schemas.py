from pydantic import BaseModel, Field, field_validator

from src.models.recipe import CandidatePoolEntry
from src.models.user_state import UserState

class RecommendationRequest(BaseModel):
    user_state: UserState
    candidate_pool: list[CandidatePoolEntry] = Field(min_length=1)
    batch_size: int | None = Field(default=None, gt=0)
    exclude_recipe_ids: list[int] | None = None
    seed: int | None = None
    required_tags: list[str] | None = None

    @field_validator("required_tags")
    @classmethod
    def required_tags_not_blank(cls, value: list[str] | None) -> list[str] | None:
        if value is None:
            return value
        stripped = [tag.strip() for tag in value]
        if any(not tag for tag in stripped):
            raise ValueError("required_tags must not contain blank values.")
        return stripped 
