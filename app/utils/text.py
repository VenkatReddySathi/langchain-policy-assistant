# app/utils/text.py
def clamp_text(s: str, max_chars: int) -> str:
    if len(s) <= max_chars:
        return s
    return s[:max_chars] + "\n...[TRUNCATED]..."
