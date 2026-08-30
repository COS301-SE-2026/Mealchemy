from pydantic import BaseModel

class Ingredient(BaseModel):
    ing_id: int
    categoty_id: int
    name: str
    quantity: float
    unit: str