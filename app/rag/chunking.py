# app/rag/chunking.py
from typing import List


def chunk_text(text: str, chunk_size: int = 900, overlap: int = 150) -> List[str]:
    text = text.replace("\r\n", "\n")
    chunks = []
    i = 0
    while i < len(text):
        end = min(i + chunk_size, len(text))
        chunk = text[i:end].strip()
        if chunk:
            chunks.append(chunk)
        if end == len(text):
            break
        i = max(0, end - overlap)
    return chunks
