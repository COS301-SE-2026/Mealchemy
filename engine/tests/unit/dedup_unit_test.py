"""dedup.py unit testing"""

from src.core.dedup import dedup
 
class TestDedup:
    def test_output_equals_input_for_populated_list(self, recipe_factory, user_state_factory):
        from src.core.scoring import build_recommendation_item

        recipe_a = recipe_factory(recipe_id=1)
        recipe_b = recipe_factory(recipe_id=2)
        user_state = user_state_factory()
        items = [
            build_recommendation_item(recipe_a, user_state),
            build_recommendation_item(recipe_b, user_state),
        ]

        result = dedup(items)

        assert result == items

    def test_output_equals_input_for_empty_list(self):
        assert dedup([]) == []

    def test_does_not_reorder_items(self, recipe_factory, user_state_factory):
        from src.core.scoring import build_recommendation_item

        user_state = user_state_factory()
        items = [build_recommendation_item(recipe_factory(recipe_id=i), user_state) for i in range(5)]

        result = dedup(items)

        assert [item.recipe_id for item in result] == [item.recipe_id for item in items]