from pydantic import BaseModel


class ErrorResponse(BaseModel):
    error_code: str
    message: str


ERROR_CODE_INVALID_CANDIDATE = "INVALID_CANDIDATE"
ERROR_CODE_EMPTY_POOL = "EMPTY_POOL"
ERROR_CODE_INVALID_SWIPE = "INVALID_SWIPE"
ERROR_CODE_STALE_STATE = "STALE_STATE"
