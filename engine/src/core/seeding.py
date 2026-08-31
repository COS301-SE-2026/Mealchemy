def derive_seed(base_seed: int | None, purpose: str) -> tuple | None:
    if base_seed is None:
        return None
    return base_seed, purpose