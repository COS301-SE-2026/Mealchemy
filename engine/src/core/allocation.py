from dataclasses import dataclass
from src.models.recommendation import RecommendationItem
from src.config import WILDCARD_SLOTS

@dataclass
class CuisineGroup:
    cuisine:str
    items: list[RecommendationItem]
    aggregate_score: float

def rank_cuisines(scored_items: list[RecommendationItem]) -> list[CuisineGroup]:
    groups_by_cuisine: dict[str, list[RecommendationItem]] = {}

    for item in scored_items:
        groups_by_cuisine.setdefault(item.cuisine_type, []).append(item)

    groups = []

    for cuisine, items in groups_by_cuisine.items():
        items.sort(key = lambda i: i.score, reverse = True)
        aggregate = sum(i.score for i in items) / len(items)
        groups.append(CuisineGroup(cuisine = cuisine, items = items, aggregate_score = aggregate))

    groups.sort(key = lambda g: g.aggregate_score, reverse = True)
    return groups

def allocate_slots(cuisine_groups: list[CuisineGroup], batch_size: int) -> dict[str, int]:
    if not cuisine_groups:
        return {}
    
    available = batch_size - WILDCARD_SLOTS
    total_score = sum(g.aggregate_score for g in cuisine_groups)

    allocation: dict[str, int] = {}
    leftover = 0

    if total_score == 0:
        even_share = available // len(cuisine_groups)
        for group in cuisine_groups:
            actual = min(even_share, len(group.items))
            allocation[group.cuisine] = actual
            leftover += even_share - actual
    else:
        for group in cuisine_groups:
            proportional = round((group.aggregate_score / total_score) * available)
            actual = min(proportional, len(group.items))
            allocation[group.cuisine] = actual
            leftover += proportional - actual

    for group in cuisine_groups:
        if leftover <= 0:
            break
        remaining_capacity = len(group.items) - allocation[group.cuisine]
        if remaining_capacity > 0:
            extra = min(leftover, remaining_capacity)
            allocation[group.cuisine] += extra
            leftover -= extra

    return allocation

def fill_wildcard(cuisine_groups: list[CuisineGroup], allocation: dict[str, int]) -> RecommendationItem | None:
    already_selected_ids = {
        item.recipe_id
        for group in cuisine_groups
        for item in sorted(group.items, key = lambda i: i.score, reverse = True)[:allocation.get(group.cuisine, 0)]
    }

    all_items_by_score = sorted(
        (item for group in cuisine_groups for item in group.items),
        key = lambda i: i.score,
        reverse = True
    )

    for item in all_items_by_score:
        if item.recipe_id not in already_selected_ids:
            return item

    return None