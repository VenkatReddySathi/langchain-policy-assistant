# app/llm/models.py
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from app.config import settings


def get_chat_model():
    return ChatOpenAI(
        model=settings.CHAT_MODEL,
        api_key=settings.OPENAI_API_KEY,
        temperature=0.2,
        timeout=60
    )


def get_embeddings():
    return OpenAIEmbeddings(
        model=settings.EMB_MODEL,
        api_key=settings.OPENAI_API_KEY
    )
