# app/llm/parsers.py
from langchain_core.output_parsers import JsonOutputParser
from app.schemas.response import PolicyAnswer


def policy_answer_parser():
    return JsonOutputParser(pydantic_object=PolicyAnswer)
