from __future__ import annotations

from typing import Any, Dict

from shared.observability import instrument_lambda, emit_counter, emit_metric


@instrument_lambda("execution-router")
def handler(event: Any, context: Any, logger, obs_ctx):
    # Example routing logic placeholder (keep your existing routing logic here)
    action = (event or {}).get("action", "route")
    broker = (event or {}).get("broker", "unknown")

    logger.info("routing_request", extra={"obs": {"action": action, "broker": broker}})

    # Business metrics examples
    emit_counter("OrdersRouted", 1, ctx=obs_ctx, dimensions={"service": "execution-router", "broker": broker})

    # If you compute slippage later:
    # emit_metric("SlippageBps", slippage_bps, unit="None", ctx=obs_ctx, dimensions={"service":"execution-router","broker":broker})

    return {"ok": True, "action": action, "broker": broker}
