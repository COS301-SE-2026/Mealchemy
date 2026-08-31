from pydantic import BaseModel, Field, model_validator
from datetime import datetime
from typing import Optional, Literal

class PreferenceWeights(BaseModel):
    pantry_match: float = Field(ge = 0, le = 1)
    cuisine: float = Field(ge = 0, le = 1)
    nutrition: float = Field(ge = 0, le = 1)
    freshness: float = Field(ge = 0, le = 1)
    novelty: float = Field(ge = 0, le = 1)

    @model_validator(mode = "after")
    def weights_some_to_one(self) -> "PreferenceWeights":
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