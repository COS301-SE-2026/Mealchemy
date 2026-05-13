"""Health status helpers for the Mealchemy engine."""


def get_health_status() -> dict[str, str]:
    """Return the engine's current health status."""
    return {"status": "UP"}
