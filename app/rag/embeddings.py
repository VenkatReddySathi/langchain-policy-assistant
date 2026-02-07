# app/rag/embeddings.py
from app.llm.models import get_embeddings


def embeddings_model():
    return get_embeddings()
