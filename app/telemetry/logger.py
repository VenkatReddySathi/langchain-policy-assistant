# app/telemetry/logger.py
import json
import time
from typing import Any, Dict


def log_event(event: str, payload: Dict[str, Any]):
    record = {"ts": time.time(), "event": event, **payload}
    print(json.dumps(record, ensure_ascii=False))
