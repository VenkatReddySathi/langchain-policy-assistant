# app/schemas/response.py
from pydantic import BaseModel, Field
from typing import List, Dict, Any


class PolicyAnswer(BaseModel):
    answer: str
    citations: List[str] = Field(default_factory=list)
    confidence: float = Field(default=0.6, ge=0.0, le=1.0)


class AskResponse(BaseModel):
    answer: PolicyAnswer
    prompt_version: str
    route: str
    retrieved_chunks: int
    debug: Dict[str, Any] = Field(default_factory=dict)
