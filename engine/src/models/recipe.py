from pydantic import BaseModel, Field
from typing import Optional

class Ingredient(BaseModel):
    ing_id: int = Field(gt = 0)
    categoty_id: int = Field(gt = 0)
    name: str = Field(min_length = 1)
    quantity: float = Field(gt = 0)
    unit: str = Field(min_length = 1)

class Nutrition(BaseModel):
    calories_kcal: Optional[int] = Field(default = None, ge = 0)
    protein_g: Optional[float] = Field(default = None, ge = 0)
    carbs_g: Optional[float] = Field(default = None, ge = 0)
    fat_g: Optional[float] = Field(default = None, ge = 0)