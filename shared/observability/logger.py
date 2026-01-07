from __future__ import annotations

import json
import logging
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict, Optional

from .context import ObsContext

_LOGGER_NAME = os.getenv("SERVICE_NAME", "cryptobotrading")
_LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload: Dict[str, Any] = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }

        if hasattr(record, "obs") and isinstance(record.obs, dict):
            payload.update(record.obs)

        if record.exc_info:
            payload["exc_info"] = self.formatException(record.exc_info)

        return json.dumps(payload, ensure_ascii=False)


def get_logger(name: Optional[str] = None) -> logging.Logger:
    logger = logging.getLogger(name or _LOGGER_NAME)
    logger.setLevel(_LOG_LEVEL)

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(JsonFormatter())
        logger.addHandler(handler)

    logger.propagate = False
    return logger


def bind_context(logger: logging.Logger, ctx: ObsContext):
    """
    Adds ObsContext fields to all logs emitted via `logger`.
    """
    class _Adapter(logging.LoggerAdapter):
        def process(self, msg, kwargs):
            extra = kwargs.get("extra", {})
            obs_fields = ctx.as_log_fields()
            extra["obs"] = {**obs_fields, **extra.get("obs", {})}
            kwargs["extra"] = extra
            return msg, kwargs

    return _Adapter(logger, {})
