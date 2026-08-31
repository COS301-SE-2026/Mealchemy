from src.models.recipe import Ingredient
from src.models.user_state import PantryEntry
from src.config import ALLERGEN_CATEGORY_MAP

# pantry match function, will return set of owned ingredients as well as a set of not owned ingredients
def pantry_ingredient_match(recipe_ingredients: list[Ingredient], pantry: list[PantryEntry]) -> tuple[set[int], set[int]]:
    recipe_ids = {ing.ing_id for ing in recipe_ingredients}
    pantry_ids = {entry.ing_id for entry in pantry}

    owned_ids = recipe_ids & pantry_ids
    missing_ids = recipe_ids - pantry_ids

    return owned_ids, missing_ids

# uses ingredients' category ids to check if it falls under an allergen group
def allergen_check(recipe_ingredients: list[Ingredient], allergies: list[str]) -> bool:
    for allergen_code in allergies:
        blocked_category_ids = ALLERGEN_CATEGORY_MAP.get(allergen_code)

        # If allergen code not mapped
        if blocked_category_ids is None:
            return False

        for ingredient in recipe_ingredients:
            if ingredient.category_id in blocked_category_ids:
                return False

    return True
