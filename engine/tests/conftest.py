"""Shared pytest fixtures and factory helpers for the MeAlchemy engine test suite."""

from datetime import UTC, datetime

import pytest

from src.models.recipe import CandidatePoolEntry, Ingredient, Nutrition
from src.models.user_state import PantryEntry, PreferenceWeights, SwipeHistoryEntry, UserState


def make_ingredient(
    ing_id: int,
    category_id: int = 1,
    name: str = "Test Ingredient",
    quantity: float = 1.0,
    unit: str = "g",
) -> Ingredient:
    return Ingredient(
        ing_id=ing_id, category_id=category_id, name=name, quantity=quantity, unit=unit
    )


def make_pantry_entry(
    ing_id: int,
    category_id: int = 1,
    quantity: float = 1.0,
    unit: str = "g",
    added_at: datetime | None = None,
    shelf_life_days: int | None = 14,
    storage_location: str = "FRIDGE",
) -> PantryEntry:
    return PantryEntry(
        ing_id=ing_id,
        category_id=category_id,
        quantity=quantity,
        unit=unit,
        added_at=added_at or datetime.now(UTC),
        shelf_life_days=shelf_life_days,
        storage_location=storage_location,
    )


def make_recipe(
    recipe_id: int = 1,
    title: str = "Test Recipe",
    cuisine: str = "ITALIAN",
    dietary_tags: list[str] | None = None,
    ingredients: list[Ingredient] | None = None,
    nutrition: Nutrition | None = None,
) -> CandidatePoolEntry:
    effective_id = recipe_id if recipe_id > 0 else recipe_id + 1
    return CandidatePoolEntry(
        recipe_id=effective_id,
        title=title,
        cuisine=cuisine,
        dietary_tags=dietary_tags if dietary_tags is not None else [],
        ingredients=ingredients if ingredients is not None else [make_ingredient(1)],
        nutrition=nutrition,
    )


def make_preference_weights(**overrides: float) -> PreferenceWeights:
    base = {
        "pantry_match": 0.40,
        "cuisine": 0.25,
        "nutrition": 0.15,
        "freshness": 0.10,
        "novelty": 0.10,
    }
    base.update(overrides)
    return PreferenceWeights(**base)


def make_swipe(
    recipe_id: int,
    action: str,
    swiped_at: datetime,
) -> SwipeHistoryEntry:
    return SwipeHistoryEntry(recipe_id=recipe_id, action=action, swiped_at=swiped_at)


def make_user_state(
    user_id: int = 1,
    allergies: list[str] | None = None,
    disliked_ingredients: list[str] | None = None,
    dietary_restrictions: list[str] | None = None,
    nutritional_goals: list[str] | None = None,
    preference_weights: PreferenceWeights | None = None,
    cuisine_affinities: dict[str, float] | None = None,
    pantry: list[PantryEntry] | None = None,
    swipe_history: list[SwipeHistoryEntry] | None = None,
) -> UserState:
    return UserState(
        user_id=user_id,
        allergies=allergies if allergies is not None else [],
        disliked_ingredients=disliked_ingredients if disliked_ingredients is not None else [],
        dietary_restrictions=dietary_restrictions if dietary_restrictions is not None else [],
        nutritional_goals=nutritional_goals if nutritional_goals is not None else [],
        preference_weights=preference_weights or make_preference_weights(),
        cuisine_affinities=cuisine_affinities if cuisine_affinities is not None else {},
        pantry=pantry if pantry is not None else [],
        swipe_history=swipe_history if swipe_history is not None else [],
    )


@pytest.fixture
def ingredient_factory():
    return make_ingredient


@pytest.fixture
def pantry_entry_factory():
    return make_pantry_entry


@pytest.fixture
def recipe_factory():
    return make_recipe


@pytest.fixture
def preference_weights_factory():
    return make_preference_weights


@pytest.fixture
def swipe_factory():
    return make_swipe


@pytest.fixture
def user_state_factory():
    return make_user_state
