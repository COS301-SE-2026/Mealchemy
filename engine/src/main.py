"""Mealchemy recommendation engine entry point."""

import os
import uvicorn
from src.api.routes import router
from src.api.errors import ErrorResponse, ERROR_CODE_INVALID_CANDIDATE
from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.requests import Request
from fastapi.responses import JSONResponse

# create app and mount router
app = FastAPI(title = "Mealchemy Recommendation Engine")
app.include_router(router)

# invalid candidate handler
@app.exception_handler(RequestValidationError)
async def handle_validation_error(request: Request, exc: RequestValidationError) -> JSONResponse:
    error = ErrorResponse(error_code = ERROR_CODE_INVALID_CANDIDATE, message = str(exc))
    return JSONResponse(status_code = 400, content = error.model_dump())

# uvicorn launch
def main() -> None:
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host = "0.0.0.0", port = port)

if __name__ == "__main__":
    main()