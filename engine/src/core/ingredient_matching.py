from src.models.recipe import Ingredient
from src.models.user_state import PantryEntry

# pantry match function, will return set of owned ingredients as well as a set of not owned ingredients
def pantry_ingredient_match(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> tuple[set[int], set[int]]:
    recipe_ids = {ing.ing_id for ing in recipe_ingredients}
    pantry_ids = {entry.ing_id for entry in pantry}

    owned_ids = recipe_ids & pantry_ids
    missing_ids = recipe_ids - pantry_ids

    return owned_ids, missing_ids