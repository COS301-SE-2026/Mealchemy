from pydantic import BaseModel, Field 

class ScoreBreakdown(BaseModel):
    pantry_match: float = Field(ge = 0, le = 1)
    cuisine: float = Field(ge = 0, le = 1)
    nutrition: float = Field(ge = 0, le = 1)
    novelty: float = Field(ge = 0, le = 1)
    freshness: float = Field(ge = 0, le = 1)