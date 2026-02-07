# app/schemas/request.py
from pydantic import BaseModel, Field


class AskRequest(BaseModel):
    question: str = Field(..., min_length=1)
    prompt_version: str = Field(default="v2")
    top_k: int = Field(default=5, ge=1, le=20)
