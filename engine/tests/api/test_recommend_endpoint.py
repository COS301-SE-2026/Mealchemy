"""api request testing"""

import pytest
from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def _valid_recipe() -> dict:
    return {
        "recipe_id": 1,
        "title": "Test Recipe",
        "cuisine": "ITALIAN",
        "dietary_tags": [],
        "ingredients": [
            {"ing_id": 1, "category_id": 4, "name": "Pasta", "quantity": 200.0, "unit": "g"},
        ],
        "nutrition": None,
    }


def _valid_user_state(**overrides) -> dict:
    base = {
        "user_id": 1,
        "allergies": [],
        "disliked_ingredients": [],
        "dietary_restrictions": [],
        "nutritional_goals": [],
        "preference_weights": {
            "pantry_match": 0.40,
            "cuisine": 0.25,
            "nutrition": 0.15,
            "freshness": 0.10,
            "novelty": 0.10,
        },
        "cuisine_affinities": {},
        "pantry": [],
        "swipe_history": [],
    }
    base.update(overrides)
    return base


def _valid_request_body(**user_state_overrides) -> dict:
    return {
        "user_state": _valid_user_state(**user_state_overrides),
        "candidate_pool": [_valid_recipe()],
        "batch_size": None,
        "exclude_recipe_ids": None,
        "seed": 1,
    }


def _valid_signal_scores(**overrides) -> dict:
    base = {
        "pantry_match": 0.5,
        "cuisine": 0.5,
        "nutrition": 0.5,
        "novelty": 0.5,
        "freshness": 0.5,
    }
    base.update(overrides)
    return base


def _valid_swipe(**overrides) -> dict:
    base = {
        "recipe_id": 1,
        "cuisine": "ITALIAN",
        "action": "LIKED",
        "signal_scores": _valid_signal_scores(),
        "swiped_at": "2026-01-01T12:00:00Z",
    }
    base.update(overrides)
    return base


def _valid_learning_update_body(**overrides) -> dict:
    base = {
        "preference_weights": {
            "pantry_match": 0.40,
            "cuisine": 0.25,
            "nutrition": 0.15,
            "freshness": 0.10,
            "novelty": 0.10,
        },
        "cuisine_affinities": {"ITALIAN": 0.75},
        "swipes": [_valid_swipe()],
        "alpha": 0.15,
        "state_version": 3,
    }
    base.update(overrides)
    return base


class TestHealthEndpoint:
    def test_returns_200_and_up_status(self):
        response = client.get("/health")

        assert response.status_code == 200
        assert response.json() == {"status": "UP"}


class TestRecommendationsHappyPath:
    def test_valid_request_returns_200_with_expected_shape(self):
        response = client.post("/recommendations", json=_valid_request_body())

        assert response.status_code == 200
        body = response.json()
        assert "recommendations" in body
        assert "cuisine_allocation" in body
        assert "total_candidates_after_filter" in body
        assert "total_recipes_considered" in body

    def test_valid_request_returns_the_one_recipe(self):
        response = client.post("/recommendations", json=_valid_request_body())

        body = response.json()
        assert body["total_recipes_considered"] == 1
        assert len(body["recommendations"]) == 1
        assert body["recommendations"][0]["recipe_id"] == 1


class TestRecommendationsInvalidCandidate:
    def test_missing_candidate_pool_returns_400_invalid_candidate(self):
        malformed_body = _valid_request_body()
        del malformed_body["candidate_pool"]

        response = client.post("/recommendations", json=malformed_body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_empty_candidate_pool_list_returns_400_invalid_candidate(self):
        body = _valid_request_body()
        body["candidate_pool"] = []

        response = client.post("/recommendations", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_weights_not_summing_to_one_returns_400_invalid_candidate(self):
        body = _valid_request_body()
        body["user_state"]["preference_weights"]["pantry_match"] = 0.99

        response = client.post("/recommendations", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_duplicate_ingredient_ids_returns_400_invalid_candidate(self):
        body = _valid_request_body()
        body["candidate_pool"][0]["ingredients"] = [
            {"ing_id": 1, "category_id": 4, "name": "Pasta", "quantity": 200.0, "unit": "g"},
            {"ing_id": 1, "category_id": 5, "name": "Duplicate", "quantity": 50.0, "unit": "g"},
        ]

        response = client.post("/recommendations", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"


class TestRecommendationsEmptyPool:
    def test_unsatisfiable_dietary_restriction_returns_422_empty_pool(self):
        body = _valid_request_body(dietary_restrictions=["HALAL"])

        response = client.post("/recommendations", json=body)

        assert response.status_code == 422
        assert response.json()["error_code"] == "EMPTY_POOL"

    def test_excluding_the_only_recipe_returns_422_empty_pool(self):
        body = _valid_request_body()
        body["exclude_recipe_ids"] = [1]

        response = client.post("/recommendations", json=body)

        assert response.status_code == 422
        assert response.json()["error_code"] == "EMPTY_POOL"


class TestLearningUpdateHappyPath:
    def test_valid_request_returns_200_with_expected_shape(self):
        response = client.post("/learning/update", json=_valid_learning_update_body())

        assert response.status_code == 200
        body = response.json()
        assert "preference_weights" in body
        assert "cuisine_affinities" in body
        assert "state_version" in body

    def test_state_version_is_echoed_back_unchanged(self):
        response = client.post(
            "/learning/update", json=_valid_learning_update_body(state_version=42)
        )

        assert response.json()["state_version"] == 42

    def test_returned_weights_sum_to_one(self):
        response = client.post("/learning/update", json=_valid_learning_update_body())

        weights = response.json()["preference_weights"]
        assert sum(weights.values()) == pytest.approx(1.0)

    def test_empty_swipes_list_returns_weights_unchanged(self):
        body = _valid_learning_update_body(swipes=[])

        response = client.post("/learning/update", json=body)

        assert response.status_code == 200
        assert response.json()["preference_weights"] == body["preference_weights"]
        assert response.json()["cuisine_affinities"] == body["cuisine_affinities"]

    def test_liked_swipe_increases_matching_cuisine_affinity(self):
        body = _valid_learning_update_body(
            cuisine_affinities={"ITALIAN": 0.5},
            swipes=[_valid_swipe(cuisine="ITALIAN", action="LIKED")],
        )

        response = client.post("/learning/update", json=body)

        assert response.json()["cuisine_affinities"]["ITALIAN"] > 0.5


class TestLearningUpdateInvalidBody:
    def test_missing_swipes_field_returns_400_invalid_candidate(self):
        malformed_body = _valid_learning_update_body()
        del malformed_body["swipes"]

        response = client.post("/learning/update", json=malformed_body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_missing_state_version_returns_400_invalid_candidate(self):
        malformed_body = _valid_learning_update_body()
        del malformed_body["state_version"]

        response = client.post("/learning/update", json=malformed_body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_invalid_swipe_action_returns_400_invalid_candidate(self):
        body = _valid_learning_update_body(swipes=[_valid_swipe(action="NOT_A_REAL_ACTION")])

        response = client.post("/learning/update", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_weights_not_summing_to_one_returns_400_invalid_candidate(self):
        body = _valid_learning_update_body()
        body["preference_weights"]["pantry_match"] = 0.99

        response = client.post("/learning/update", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_cuisine_affinity_out_of_range_returns_400_invalid_candidate(self):
        body = _valid_learning_update_body(cuisine_affinities={"ITALIAN": 1.5})

        response = client.post("/learning/update", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"

    def test_alpha_above_one_returns_400_invalid_candidate(self):
        body = _valid_learning_update_body(alpha=1.5)

        response = client.post("/learning/update", json=body)

        assert response.status_code == 400
        assert response.json()["error_code"] == "INVALID_CANDIDATE"
