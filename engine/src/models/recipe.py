from pydantic import BaseModel, Field, field_validator


class Ingredient(BaseModel):
    ing_id: int = Field(gt=0)
    category_id: int = Field(gt=0)
    name: str = Field(min_length=1)
    quantity: float = Field(gt=0)
    unit: str = Field(min_length=1)


class Nutrition(BaseModel):
    calories_kcal: int | None = Field(default=None, ge=0)
    protein_g: float | None = Field(default=None, ge=0)
    carbs_g: float | None = Field(default=None, ge=0)
    fat_g: float | None = Field(default=None, ge=0)


class CandidatePoolEntry(BaseModel):
    recipe_id: int = Field(gt=0)
    title: str = Field(min_length=1)
    cuisine: str = Field(min_length=1)
    dietary_tags: list[str]
    ingredients: list[Ingredient] = Field(min_length=1)
    nutrition: Nutrition | None = None

    @field_validator("ingredients")
    @classmethod
    def no_duplicate_ingredients(cls, value: list[Ingredient]) -> list[Ingredient]:
        ing_ids = [ing.ing_id for ing in value]
        if len(ing_ids) != len(set(ing_ids)):
            raise ValueError("Recipe ingredients must not contain duplicate ing_id values.")
        return value
