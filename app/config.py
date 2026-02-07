# app/config.py
import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    APP_NAME: str = os.getenv("APP_NAME", "LangChain Policy Assistant")

    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")
    CHAT_MODEL: str = os.getenv("CHAT_MODEL", "gpt-4o-mini")
    EMB_MODEL: str = os.getenv("EMB_MODEL", "text-embedding-3-small")

    POLICIES_DIR: str = os.getenv("POLICIES_DIR", "data/policies")
    INDEX_DIR: str = os.getenv("INDEX_DIR", "index")

    DEFAULT_TOP_K: int = int(os.getenv("DEFAULT_TOP_K", "5"))
    MAX_CONTEXT_CHARS: int = int(os.getenv("MAX_CONTEXT_CHARS", "12000"))

    PROMPT_VERSION: str = os.getenv("PROMPT_VERSION", "v2")
    ROUTER_VERSION: str = os.getenv("ROUTER_VERSION", "v1")

    RATE_LIMIT_PER_MIN: int = int(os.getenv("RATE_LIMIT_PER_MIN", "60"))


settings = Settings()
