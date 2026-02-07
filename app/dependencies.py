# app/dependencies.py
from functools import lru_cache
from app.config import settings
from app.rag.vectorstore import load_vectorstore
from app.llm.models import get_chat_model


@lru_cache
def vectorstore():
    return load_vectorstore(settings.INDEX_DIR)


@lru_cache
def chat_model():
    return get_chat_model()
