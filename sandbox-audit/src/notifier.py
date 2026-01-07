from __future__ import annotations

from typing import Any, Dict

from shared.observability import instrument_lambda, emit_counter


@instrument_lambda("audit-notifier")
def handler(event: Any, context: Any, logger, obs_ctx):
    severity = (event or {}).get("severity", "info")
    logger.info("notify", extra={"obs": {"service": "audit-notifier", "severity": severity}})
    emit_counter("Notifications", 1, ctx=obs_ctx, dimensions={"service": "audit-notifier", "severity": severity})
    return {"ok": True}
