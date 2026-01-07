from __future__ import annotations

from typing import Any, Dict

from shared.observability import instrument_lambda, emit_counter


@instrument_lambda("audit-logger")
def handler(event: Any, context: Any, logger, obs_ctx):
    logger.info("audit_event", extra={"obs": {"service": "audit-logger", "event_type": (event or {}).get("type", "unknown")}})
    emit_counter("AuditEvents", 1, ctx=obs_ctx, dimensions={"service": "audit-logger"})
    return {"ok": True}
