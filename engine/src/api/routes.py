from fastapi import APIRouter, Response
from fastapi.responses import JSONResponse

from src.api.errors import ERROR_CODE_EMPTY_POOL, ErrorResponse
from src.api.schemas import RecommendationRequest
from src.core.exceptions import EmptyPoolError
from src.core.learning import process_swipes
from src.core.recommend_pipeline import recommend
from src.models.learning import LearningUpdateRequest, LearningUpdateResponse
from src.models.recommendation import RecommendationResult

router = APIRouter()


@router.post("/recommendations", response_model=RecommendationResult)
def post_recommendations(request: RecommendationRequest) -> Response:
    try:
        result = recommend(
            candidate_pool=request.candidate_pool,
            user_state=request.user_state,
            batch_size=request.batch_size,
            exclude_recipe_ids=request.exclude_recipe_ids,
            seed=request.seed,
        )
    except EmptyPoolError as e:
        error = ErrorResponse(error_code=ERROR_CODE_EMPTY_POOL, message=str(e))
        return JSONResponse(status_code=422, content=error.model_dump())

    return JSONResponse(status_code=200, content=result.model_dump())


@router.get("/health")
def get_health() -> dict[str, str]:
    return {"status": "UP"}


@router.post("/learning/update", response_model=LearningUpdateResponse)
def post_learning_update(request: LearningUpdateRequest) -> Response:
    result = process_swipes(request)
    return JSONResponse(status_code=200, content=result.model_dump())
