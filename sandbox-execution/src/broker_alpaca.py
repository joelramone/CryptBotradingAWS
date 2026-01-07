from __future__ import annotations

from typing import Any, Dict

from shared.observability import get_logger, bind_context, emit_counter


def place_order(order: Dict[str, Any], obs_ctx):
    logger = bind_context(get_logger("broker-alpaca"), obs_ctx)

    logger.info("place_order_start", extra={"obs": {"service": "broker-alpaca"}})
    emit_counter("OrdersAttempted", 1, ctx=obs_ctx, dimensions={"service": "broker-alpaca"})

    # TODO: integrate real Alpaca client
    emit_counter("OrdersFilled", 1, ctx=obs_ctx, dimensions={"service": "broker-alpaca"})
    logger.info("place_order_ok", extra={"obs": {"service": "broker-alpaca"}})

    return {"status": "FILLED", "broker": "alpaca", "order": order}
