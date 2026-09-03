from pydantic import BaseModel, Field, model_validator


class ScoreBreakdown(BaseModel):
    pantry_match: float = Field(ge=0, le=1)
    cuisine: float = Field(ge=0, le=1)
    nutrition: float = Field(ge=0, le=1)
    novelty: float = Field(ge=0, le=1)
    freshness: float = Field(ge=0, le=1)


class RecommendationItem(BaseModel):
    recipe_id: int = Field(gt=0)
    score: float = Field(ge=0, le=1)
    cuisine_type: str = Field(min_length=1)
    score_breakdown: ScoreBreakdown
    pantry_gap_count: int = Field(ge=0)
    missing_ingredients: list[str] = Field(default_factory=list)

    @model_validator(mode="after")
    def gap_count_matches_size_of_missing_ingredients_list(self) -> "RecommendationItem":
        if self.pantry_gap_count != len(self.missing_ingredients):
            raise ValueError(
                f"Pantry gap count ({self.pantry_gap_count}) must equal "
                f"len(missing_ingredients) ({len(self.missing_ingredients)})"
            )
        return self


class RecommendationResult(BaseModel):
    recommendations: list[RecommendationItem]
    cuisine_allocation: dict[str, int]
    total_candidates_after_filter: int = Field(ge=0)
    total_recipes_considered: int = Field(ge=0)
