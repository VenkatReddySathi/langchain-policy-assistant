# app/rag/sanitize.py
import re
from typing import List

PATTERNS = [
    r"ignore (all|previous) instructions",
    r"system prompt",
    r"reveal.*(secret|key|prompt)"
]


def looks_injecty(t: str) -> bool:
    low = t.lower()
    return any(re.search(p, low) for p in PATTERNS)


def sanitize_chunks(chunks: List[str]) -> List[str]:
    return ["[SUSPECTED_INJECTION_REMOVED]" if looks_injecty(c) else c for c in chunks]
