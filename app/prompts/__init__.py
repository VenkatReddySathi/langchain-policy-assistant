# app/prompts/__init__.py
import os


def load_prompt_file(name: str) -> str:
    path = os.path.join("app", "prompts", name)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()
