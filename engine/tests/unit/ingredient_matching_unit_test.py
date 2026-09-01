"""ingredient_matching.py unit testing"""

from src.core.ingredient_matching import allergen_check, get_missing_ingredients, pantry_ingredient_match

class TestPantryIngredientMatch:
    def test_full_overlap(self, ingredient_factory, pantry_entry_factory):
        recipe_ingredients = [ingredient_factory(1), ingredient_factory(2)]
        pantry = [pantry_entry_factory(1), pantry_entry_factory(2)]

        owned, missing = pantry_ingredient_match(recipe_ingredients, pantry)

        assert owned == {1, 2}
        assert missing == set()

    def test_partial_overlap(self, ingredient_factory, pantry_entry_factory):
        recipe_ingredients = [ingredient_factory(1), ingredient_factory(2), ingredient_factory(3)]
        pantry = [pantry_entry_factory(1)]

        owned, missing = pantry_ingredient_match(recipe_ingredients, pantry)

        assert owned == {1}
        assert missing == {2, 3}

    def test_no_overlap(self, ingredient_factory, pantry_entry_factory):
        recipe_ingredients = [ingredient_factory(1)]
        pantry = [pantry_entry_factory(99)]

        owned, missing = pantry_ingredient_match(recipe_ingredients, pantry)

        assert owned == set()
        assert missing == {1}

    def test_empty_pantry(serlf, ingredient_factory):
        recipe_ingredients = [ingredient_factory(1), ingredient_factory(2)]

        owned, missing = pantry_ingredient_match(recipe_ingredients, [])

        assert owned == set()
        assert missing == {1, 2}

    # Checks that owning a different ingredient in the same category doesn't count as a match
    def test_matching_is_by_ing_id_not_category(self, ingredient_factory, pantry_entry_factory):
        recipe_ingredients = [ingredient_factory(1, category_id = 5)]
        pantry = [pantry_entry_factory(2, category_id = 5)]

        owned, missing = pantry_ingredient_match(recipe_ingredients, pantry)

        assert owned == set()
        assert missing == {1}