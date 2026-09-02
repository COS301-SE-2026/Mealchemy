"""allocation.py unit testing"""

from src.core.allocation import allocate_slots, build_final_list, fill_wildcard, rank_cuisines
from src.models.recommendation import RecommendationItem, ScoreBreakdown

_NEUTRAL_BREAKDOWN = ScoreBreakdown(pantry_match=0.5, cuisine=0.5, nutrition=0.5, novelty=0.5, freshness=0.5)

def make_item(recipe_id: int, cuisine_type: str, score: float) -> RecommendationItem:
    return RecommendationItem(
        recipe_id=recipe_id,
        score=score,
        cuisine_type=cuisine_type,
        score_breakdown=_NEUTRAL_BREAKDOWN,
        pantry_gap_count=0,
        missing_ingredients=[],
    )

class TestRankCuisines:
    def test_groups_items_by_cuisine(self):
        items = [
            make_item(1, "ITALIAN", 0.9),
            make_item(2, "MEXICAN", 0.5),
            make_item(3, "ITALIAN", 0.7),
        ]

        groups = rank_cuisines(items)
        cuisines = {g.cuisine for g in groups}

        assert cuisines == {"ITALIAN", "MEXICAN"}

    def test_items_within_a_group_are_sorted_descending_by_score(self):
        items = [
            make_item(1, "ITALIAN", 0.5),
            make_item(2, "ITALIAN", 0.9),
            make_item(3, "ITALIAN", 0.7),
        ]
 
        groups = rank_cuisines(items)
        italian_group = next(g for g in groups if g.cuisine == "ITALIAN")

        assert [i.score for i in italian_group.items] == [0.9, 0.7, 0.5]

    def test_aggregate_score_is_mean_of_all_items_in_group(self):
        items = [make_item(1, "ITALIAN", 0.8), make_item(2, "ITALIAN", 0.6)]

        groups = rank_cuisines(items)

        assert groups[0].aggregate_score == 0.7

    def test_groups_are_sorted_descending_by_aggregate_score(self):
        items = [
            make_item(1, "MEXICAN", 0.2),
            make_item(2, "ITALIAN", 0.9),
        ]

        groups = rank_cuisines(items)

        assert [g.cuisine for g in groups] == ["ITALIAN", "MEXICAN"]

class TestAllocateSlots:
    def test_empty_cuisine_groups_returns_empty_dict(self):
        assert allocate_slots([], batch_size=10) == {}

    def test_clean_proportional_split_with_no_capping(self):
        items_a = [make_item(i, "A", 0.6) for i in range(1, 7)]
        items_b = [make_item(i + 100, "B", 0.4) for i in range(4)]
        groups = rank_cuisines(items_a + items_b)

        allocation = allocate_slots(groups, batch_size=11)

        assert allocation == {"A": 6, "B": 4}

    def test_capping_and_overflow_redistribution(self):
        items_a = [make_item(1, "A", 0.87), make_item(2, "A", 0.87)]
        items_b = [make_item(i + 100, "B", 0.13) for i in range(8)]
        groups = rank_cuisines(items_a + items_b)

        allocation = allocate_slots(groups, batch_size=11)

        assert allocation["A"] == 2
        assert allocation["B"] == 8
        assert sum(allocation.values()) == 10

    def test_zero_total_score_falls_back_to_even_split(self):
        items_a = [make_item(i, "A", 0.0) for i in range(1, 6)]
        items_b = [make_item(i + 100, "B", 0.0) for i in range(5)]
        groups = rank_cuisines(items_a + items_b)

        allocation = allocate_slots(groups, batch_size=11)

        assert allocation == {"A": 5, "B": 5}

    def test_zero_total_score_even_split_still_respects_availability_cap(self):
        items_a = [make_item(1, "A", 0.0)]
        items_b = [make_item(i + 100, "B", 0.0) for i in range(5)]
        groups = rank_cuisines(items_a + items_b)

        allocation = allocate_slots(groups, batch_size=11)

        assert allocation["A"] == 1
        assert allocation["B"] == 5

    def test_small_production_scale_pool_degrades_gracefully(self):
        items = [
            make_item(101, "ITALIAN", 0.8),
            make_item(102, "ITALIAN", 0.7),
            make_item(103, "ASIAN", 0.6),
            make_item(104, "MEXICAN", 0.5),
            make_item(105, "MEDITERRANEAN", 0.4),
        ]
        groups = rank_cuisines(items)

        allocation = allocate_slots(groups, batch_size=20)

        assert sum(allocation.values()) == 5
        assert allocation["ITALIAN"] == 2
        assert allocation["ASIAN"] == 1
        assert allocation["MEXICAN"] == 1
        assert allocation["MEDITERRANEAN"] == 1

class TestFillWildcard:
    def test_returns_highest_scorer_not_already_allocated(self):
        items = [
            make_item(1, "A", 0.9),
            make_item(2, "A", 0.8),
            make_item(3, "B", 0.5),
        ]
        groups = rank_cuisines(items)
        allocation = {"A": 1, "B": 1}

        wildcard = fill_wildcard(groups, allocation)

        assert wildcard is not None
        assert wildcard.recipe_id == 2

    def test_returns_none_when_everything_top_scoring_is_already_allocated(self):
        items = [make_item(1, "A", 0.9)]
        groups = rank_cuisines(items)
        allocation = {"A": 1}

        wildcard = fill_wildcard(groups, allocation)

        assert wildcard is None

    def test_does_not_depend_on_pre_sorted_items(self):
        from src.core.allocation import CuisineGroup

        unsorted_items = [make_item(1, "A", 0.5), make_item(2, "A", 0.9)]
        group = CuisineGroup(cuisine="A", items=unsorted_items, aggregate_score=0.7)
        allocation = {"A": 1}

        wildcard = fill_wildcard([group], allocation)

        assert wildcard is not None
        assert wildcard.recipe_id == 1

class TestBuildFinalList:
    def test_assembles_allocated_items_per_group(self):
        items = [
            make_item(1, "A", 0.9),
            make_item(2, "A", 0.8),
            make_item(3, "B", 0.5),
        ]
        groups = rank_cuisines(items)
        allocation = {"A": 1, "B": 1}

        final_list = build_final_list(groups, allocation, wildcard=None)
        recipe_ids = {item.recipe_id for item in final_list}

        assert recipe_ids == {1, 3}

    def test_appends_wildcard_when_present(self):
        items = [make_item(1, "A", 0.9), make_item(2, "A", 0.8)]
        groups = rank_cuisines(items)
        allocation = {"A": 1}
        wildcard = items[1]

        final_list = build_final_list(groups, allocation, wildcard)
        recipe_ids = [item.recipe_id for item in final_list]

        assert recipe_ids == [1, 2]

    def test_no_wildcard_appended_when_none(self):
        items = [make_item(1, "A", 0.9)]
        groups = rank_cuisines(items)
        allocation = {"A": 1}

        final_list = build_final_list(groups, allocation, wildcard=None)

        assert len(final_list) == 1

    def test_final_list_has_no_duplicate_recipe_ids(self):
        items = [
            make_item(1, "A", 0.9),
            make_item(2, "A", 0.8),
            make_item(3, "B", 0.6),
        ]
        groups = rank_cuisines(items)
        allocation = {"A": 2, "B": 1}
        wildcard = fill_wildcard(groups, allocation)

        final_list = build_final_list(groups, allocation, wildcard)
        recipe_ids = [item.recipe_id for item in final_list]

        assert len(recipe_ids) == len(set(recipe_ids))