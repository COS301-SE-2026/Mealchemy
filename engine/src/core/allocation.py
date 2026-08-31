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

