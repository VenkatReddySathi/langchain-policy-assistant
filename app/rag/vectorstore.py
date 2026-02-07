# app/rag/vectorstore.py
import os
from langchain_community.vectorstores import FAISS
from app.rag.embeddings import embeddings_model


def load_vectorstore(index_dir: str) -> FAISS:
    if not os.path.exists(index_dir):
        raise RuntimeError(
            "Index directory not found. Run ingestion first: python -m app.rag.ingest")
    emb = embeddings_model()
    return FAISS.load_local(index_dir, emb, allow_dangerous_deserialization=True)


def save_vectorstore(vs: FAISS, index_dir: str) -> None:
    os.makedirs(index_dir, exist_ok=True)
    vs.save_local(index_dir)
