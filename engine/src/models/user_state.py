from pydantic import BaseModel, Field, model_validator, field_validator
from datetime import datetime
from typing import Optional, Literal
from src.core.shared import SwipeAction

SwipeAction = Literal["LIKED", "DISLIKED", "SKIPPED"]

class PreferenceWeights(BaseModel):
    pantry_match: float = Field(ge = 0, le = 1)
    cuisine: float = Field(ge = 0, le = 1)
    nutrition: float = Field(ge = 0, le = 1)
    freshness: float = Field(ge = 0, le = 1)
    novelty: float = Field(ge = 0, le = 1)

    @model_validator(mode = "after")
    def weights_sum_to_one(self) -> "PreferenceWeights":
        total = self.pantry_match + self.cuisine + self.nutrition + self.freshness + self.novelty
        if abs(total - 1.0) > 1e-6:
            raise ValueError(f"Preference weights must sum to 1.0, but got {total}")
        return self

class PantryEntry(BaseModel):
    ing_id: int = Field(gt = 0)
    category_id: int = Field(gt = 0)
    quantity: float = Field(gt = 0)
    unit: str = Field(min_length = 1)
    added_at: datetime
    shelf_life_days: Optional[int] = Field(default = None, gt = 0, le = 1825)
    storage_location: Literal["PANTRY", "FRIDGE", "FREEZER"]

class SwipeHistoryEntry(BaseModel):
    recipe_id: int = Field(gt = 0)
    action: SwipeAction
    swiped_at: datetime
class UserState(BaseModel):
    user_id: int = Field(gt = 0)
    allergies: list[str]
    disliked_ingredients: list[str]
    dietary_restrictions: list[str]
    nutritional_goals: list[str]
    preference_weights: PreferenceWeights
    cuisine_affinities: dict[str, float] = Field(default_factory = dict)
    pantry: list[PantryEntry]
    swipe_history: list[SwipeHistoryEntry] = Field(default_factory = list)

    @field_validator(mode = "cuisine_affinities")
    @classmethod
    def affinities_in_range(cls, value: dict[str, float]) -> dict[str, float]:
        for cuisine, score in value.items():
            if not (0.0 <= score <= 1.0):
                raise ValueError(f"Cuisine affinities ['{cuisine}'] must be in the range [0.0 - 1.0], but got {score}")
        return value

