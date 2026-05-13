"""Unit tests for the Mealchemy engine."""

from src.health import get_health_status


def test_get_health_status_returns_up() -> None:
    assert get_health_status() == {"status": "UP"}
