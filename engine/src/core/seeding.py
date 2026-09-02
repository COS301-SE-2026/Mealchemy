import hashlib

def derive_seed(base_seed: int | None, label: str) -> int | None:
    if base_seed is None:
        return None
    payload = f"{base_seed}:{label}".encode()
    digest = hashlib.sha256(payload).hexdigest()
    return int(digest, 16)