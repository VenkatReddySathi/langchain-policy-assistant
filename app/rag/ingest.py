# app/rag/ingest.py
import os
from langchain_core.documents import Document
from langchain_community.vectorstores import FAISS

from app.config import settings
from app.rag.chunking import chunk_text
from app.rag.embeddings import embeddings_model
from app.rag.vectorstore import save_vectorstore


#
def ingest():
    docs = []

    # 1. Check if the directory even exists
    if not os.path.exists(settings.POLICIES_DIR):
        print(f"Error: Directory '{settings.POLICIES_DIR}' does not exist.")
        return

    for fname in os.listdir(settings.POLICIES_DIR):
        if not fname.endswith(".txt"):
            continue
        path = os.path.join(settings.POLICIES_DIR, fname)
        with open(path, "r", encoding="utf-8") as f:
            text = f.read()

        chunks = chunk_text(text)
        if not chunks:
            print(f"Warning: No chunks generated for file {fname}")
            continue

        for i, chunk in enumerate(chunks):
            docs.append(Document(page_content=chunk, metadata={
                        "source": fname, "chunk_id": i}))

    # 2. THE CRITICAL FIX: Check if docs list is empty before creating FAISS
    if not docs:
        print(
            "Error: No documents found to ingest. Check your folder and file extensions.")
        return

    # Now it's safe to run FAISS
    vs = FAISS.from_documents(docs, embeddings_model())
    save_vectorstore(vs, settings.INDEX_DIR)
    print(f"Success: Ingested {len(docs)} chunks into '{settings.INDEX_DIR}'")
